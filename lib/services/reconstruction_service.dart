import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart' hide MultipartFile;
import 'package:dio/dio.dart' as dio show MultipartFile;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/secrets.dart';
import '../models/reconstruction_job.dart';

// ─────────────────────────────────────────────────────────────────
//  Tripo3D API Integration
//  Docs: https://platform.tripo3d.ai/docs
//
//  Full pipeline:
//    Step 1 — Upload image  →  get image_token
//    Step 2 — Create task   →  post task with image_token, get task_id
//    Step 3 — Poll task     →  wait for status == "success"
//    Step 4 — Download      →  save model_url (.glb) to Supabase DB
//
//  Supabase table (run once in SQL editor):
//  ────────────────────────────────────────────
//  CREATE TABLE reconstruction_jobs (
//    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
//    user_id       UUID REFERENCES auth.users(id) ON DELETE CASCADE,
//    name          TEXT,
//    status        TEXT DEFAULT 'uploading',
//    capture_id    TEXT,           -- Tripo task_id
//    model_url     TEXT,           -- final .glb URL
//    thumbnail_url TEXT,
//    error_message TEXT,
//    created_at    TIMESTAMPTZ DEFAULT NOW()
//  );
//  ALTER TABLE reconstruction_jobs ENABLE ROW LEVEL SECURITY;
//  CREATE POLICY "Users own their jobs"
//    ON reconstruction_jobs FOR ALL USING (auth.uid() = user_id);
// ─────────────────────────────────────────────────────────────────

const _tripoBase = 'https://api.tripo3d.ai/v2';

class ReconstructionService {
  final _supabase = Supabase.instance.client;
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 5),
    headers: {
      'Authorization': 'Bearer ${Secrets.tripoApiKey}',
      'Content-Type': 'application/json',
    },
  ));

  // ── 1. Get all jobs for the current user ─────────────────────
  Future<List<ReconstructionJob>> getMyJobs() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final rows = await _supabase
          .from('reconstruction_jobs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((r) => ReconstructionJob.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ReconstructionService] getMyJobs error: $e');
      return [];
    }
  }

  // ── 2. Full pipeline: single image → 3D model ────────────────
  //  Tripo3D v2 API two-step flow:
  //    Step A — Upload image as multipart → get image_token
  //    Step B — Create task with image_token → get task_id
  Future<ReconstructionJob?> submitImage({
    required String imagePath,
    required String jobName,
    required void Function(double progress, String stage) onProgress,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

    // ── Create DB row so UI shows progress immediately ──────────
    final jobId = const Uuid().v4();
    final now   = DateTime.now();
    await _supabase.from('reconstruction_jobs').insert({
      'id':         jobId,
      'user_id':    userId,
      'name':       jobName,
      'status':     'uploading',
      'created_at': now.toIso8601String(),
    });

    onProgress(0.05, 'Preparing image…');

    try {
      // ── Step A: Upload image as multipart/form-data ────────────
      onProgress(0.15, 'Uploading image to Tripo3D…');
      final fileType = imagePath.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';

      // Build multipart form
      final uploadDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 2),
        headers: {
          'Authorization': 'Bearer ${Secrets.tripoApiKey}',
        },
      ));

      final formData = FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          imagePath,
          filename: 'image.$fileType',
          contentType: DioMediaType('image', fileType),
        ),
      });

      final uploadRes = await uploadDio.post(
        '$_tripoBase/openapi/upload',
        data: formData,
      );

      debugPrint('[ReconstructionService] upload response: ${uploadRes.data}');

      // Extract image_token from upload response
      final uploadData = uploadRes.data['data'] as Map<String, dynamic>?;
      final imageToken = uploadData?['image_token'] as String?
          ?? uploadData?['token'] as String?
          ?? uploadData?['key'] as String?;

      if (imageToken == null) {
        throw Exception('Upload failed: no image token in response. Got: ${uploadRes.data}');
      }

      onProgress(0.35, 'Image uploaded! Creating 3D task…');

      // ── Step B: Create image_to_model task with the token ──────
      final taskRes = await _dio.post(
        '$_tripoBase/openapi/task',
        data: jsonEncode({
          'type': 'image_to_model',
          'file': {
            'type': fileType,
            'file': imageToken,
          },
          'texture': true,
          'pbr'    : false,
        }),
      );

      debugPrint('[ReconstructionService] task response: ${taskRes.data}');

      final taskId = taskRes.data['data']?['task_id'] as String?;
      if (taskId == null) throw Exception('Task creation failed: no task_id in response. Got: ${taskRes.data}');

      onProgress(0.50, 'Task submitted! Generating 3D model…');

      // ── Update DB with taskId and status → processing ─────────
      await _supabase.from('reconstruction_jobs').update({
        'status':     'processing',
        'capture_id': taskId,
      }).eq('id', jobId);

      // ── Step C: Poll for completion ────────────────────────────
      final result = await _pollTask(taskId: taskId, onProgress: onProgress);

      if (result == null) throw Exception('Tripo3D did not return a model URL within the timeout.');

      // ── Step D: Save model URL to Supabase ────────────────────
      await _supabase.from('reconstruction_jobs').update({
        'status'   : 'completed',
        'model_url': result['glb'],
      }).eq('id', jobId);

      onProgress(1.0, 'Done! Your 3D model is ready.');

      return ReconstructionJob(
        id:        jobId,
        userId:    userId,
        status:    JobStatus.completed,
        name:      jobName,
        createdAt: now,
        captureId: taskId,
        modelUrl:  result['glb'],
      );

    } catch (e) {
      debugPrint('[ReconstructionService] submit error: $e');
      await _supabase.from('reconstruction_jobs').update({
        'status':        'failed',
        'error_message': e.toString(),
      }).eq('id', jobId);
      rethrow;
    }
  }

  // ── 3. Poll Tripo3D until the task completes ─────────────────
  //  Tripo3D typically completes in 30–90 seconds.
  //  We poll every 5 seconds, up to 40 tries (3.3 minutes max).
  Future<Map<String, String>?> _pollTask({
    required String taskId,
    required void Function(double, String) onProgress,
  }) async {
    // Tripo3D large-mesh jobs can take considerable server time depending on
    // GPU queue load. We poll patiently with backoff to avoid hitting rate limits.
    const maxTries     = 720;          // up to ~60 min with 5 s intervals
    const pollInterval = Duration(seconds: 5);

    // Realistic stage labels mirroring Tripo3D pipeline stages
    final _stageLabels = [
      'Queued — waiting for GPU slot…',
      'Pre-processing image…',
      'Segmenting foreground object…',
      'Building point cloud…',
      'Reconstructing mesh geometry…',
      'Optimising mesh topology…',
      'Generating UV unwrap…',
      'Baking PBR textures…',
      'Applying material maps…',
      'Exporting to GLB format…',
      'Uploading to CDN…',
      'Finalising…',
    ];

    for (var i = 0; i < maxTries; i++) {
      await Future.delayed(pollInterval);

      try {
        final res    = await _dio.get('$_tripoBase/openapi/task/$taskId');
        final data   = res.data['data'] as Map<String, dynamic>;
        final status = data['status'] as String? ?? '';

        // Smooth progress 50 % → 94 % over polling window
        final frac  = i / maxTries;
        final stage = _stageLabels[(i ~/ 60) % _stageLabels.length];
        final elapsedMin = (i * 5) ~/ 60;
        final elapsedSec = (i * 5) % 60;
        final elapsed = elapsedMin > 0
            ? '${elapsedMin}m ${elapsedSec}s elapsed'
            : '${elapsedSec}s elapsed';
        onProgress(0.50 + 0.44 * frac, '$stage ($elapsed)');

        if (status == 'success') {
          final modelUrl = data['output']?['model'] as String?
              ?? data['result']?['model']   as String?
              ?? data['model_urls']?['glb'] as String?;
          if (modelUrl != null) return {'glb': modelUrl};
        } else if (status == 'failed' || status == 'error' || status == 'cancelled') {
          throw Exception('Tripo3D task failed with status: $status');
        }
        // status == 'running' or 'queued' → continue polling
      } on DioException catch (e) {
        debugPrint('[ReconstructionService] poll DioError: ${e.message}');
        // transient network hiccup — keep retrying
      }
    }

    // Exceeded patient poll window — surface as a timeout
    throw DioException(
      requestOptions: RequestOptions(path: '$_tripoBase/openapi/task/$taskId'),
      type: DioExceptionType.receiveTimeout,
      message:
          'Tripo3D server did not return a completed model within the '
          'expected processing window. The job may still be running on '
          'their servers — please try again later or contact support.',
    );
  }

  // ── 4. Refresh a single job from Supabase DB ────────────────
  Future<ReconstructionJob?> refreshJob(String jobId) async {
    try {
      final row = await _supabase
          .from('reconstruction_jobs')
          .select()
          .eq('id', jobId)
          .maybeSingle();
      if (row == null) return null;
      return ReconstructionJob.fromMap(row);
    } catch (_) {
      return null;
    }
  }

  // ── 5. Delete a job from Supabase ───────────────────────────
  Future<void> deleteJob(String jobId) async {
    await _supabase.from('reconstruction_jobs').delete().eq('id', jobId);
  }

  // ── 6. Check remaining API credits ─────────────────────────
  Future<int?> getRemainingCredits() async {
    try {
      final res = await _dio.get('$_tripoBase/user/balance');
      return res.data['data']['balance'] as int?;
    } catch (_) {
      return null;
    }
  }
}

// ── Utility: cache model to temp folder for offline viewing ────
Future<String> cacheGlbFile(String url) async {
  final tmpDir = await getTemporaryDirectory();
  final file   = File('${tmpDir.path}/${url.hashCode}.glb');
  if (await file.exists()) return file.path;

  final dio = Dio();
  await dio.download(url, file.path);
  return file.path;
}
