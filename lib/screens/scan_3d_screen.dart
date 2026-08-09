import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reconstruction_job.dart';
import '../services/reconstruction_service.dart';

class Scan3DScreen extends StatefulWidget {
  const Scan3DScreen({super.key});
  @override
  State<Scan3DScreen> createState() => _Scan3DScreenState();
}

class _Scan3DScreenState extends State<Scan3DScreen> {
  final _service = ReconstructionService();
  List<ReconstructionJob> _jobs = [];
  bool _loading = true;
  static const _primary = Color(0xFFC97B4B);
  static const _bg = Color(0xFFFAF7F2);

  @override
  void initState() { super.initState(); _loadJobs(); }

  Future<void> _loadJobs() async {
    setState(() => _loading = true);
    final jobs = await _service.getMyJobs();
    if (mounted) setState(() { _jobs = jobs; _loading = false; });
  }

  void _openNewScanSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewScanSheet(onJobCreated: (job) { setState(() => _jobs.insert(0, job)); }),
    );
  }

  void _viewModel(ReconstructionJob job) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _ModelViewerPage(job: job)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeader(), Expanded(child: _buildBody())])),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      child: Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Create 3D', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF3D2B1F), letterSpacing: -0.5)),
          SizedBox(height: 2),
          Text('Powered by Tripo3D AI', style: TextStyle(fontSize: 13, color: Color(0xFF9E8678))),
        ])),
        IconButton(onPressed: _loadJobs, icon: const Icon(Icons.refresh_rounded, color: Color(0xFF9E8678))),
        GestureDetector(
          onTap: _openNewScanSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: _primary.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))]),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text('New Scan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _primary));
    if (_jobs.isEmpty) return _buildEmptyState();
    return RefreshIndicator(
      color: _primary,
      onRefresh: _loadJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jobs.length,
        itemBuilder: (context, i) => _JobCard(
          job: _jobs[i],
          onRefresh: () async { final u = await _service.refreshJob(_jobs[i].id); if (u != null && mounted) setState(() => _jobs[i] = u); },
          onDelete: () async { await _service.deleteJob(_jobs[i].id); if (mounted) setState(() => _jobs.removeAt(i)); },
          onView: () => _viewModel(_jobs[i]),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 110, height: 110,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [_primary.withValues(alpha: 0.15), _primary.withValues(alpha: 0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle),
        child: const Icon(Icons.view_in_ar_rounded, size: 52, color: _primary)),
      const SizedBox(height: 24),
      const Text('No 3D models yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF3D2B1F))),
      const SizedBox(height: 10),
      const Text('Take one clear photo of any object\nand Tripo3D AI will build a 3D model.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF9E8678), height: 1.65)),
      const SizedBox(height: 28),
      ElevatedButton.icon(
        onPressed: _openNewScanSheet,
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('Create your first 3D model'),
        style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
      ),
    ])));
  }
}

// ---- _JobCard ----

class _JobCard extends StatelessWidget {
  final ReconstructionJob job;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;
  final VoidCallback onView;
  const _JobCard({required this.job, required this.onRefresh, required this.onDelete, required this.onView});
  static const _primary = Color(0xFFC97B4B);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))]),
      child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(20),
        child: InkWell(borderRadius: BorderRadius.circular(20), onTap: job.status == JobStatus.completed ? onView : null,
          child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            _buildThumb(), const SizedBox(width: 14), Expanded(child: _buildInfo()), _buildActions(context),
          ])))),
    );
  }

  Widget _buildThumb() {
    final c = job.status == JobStatus.completed ? (const Color(0xFFE8F5E9), Icons.view_in_ar_rounded, const Color(0xFF388E3C))
        : job.status == JobStatus.failed ? (const Color(0xFFFFEBEE), Icons.error_outline_rounded, const Color(0xFFD32F2F))
        : (const Color(0xFFFFF3E0), Icons.hourglass_top_rounded, _primary);
    return Container(width: 56, height: 56, decoration: BoxDecoration(color: c.$1, borderRadius: BorderRadius.circular(14)), child: Icon(c.$2, color: c.$3, size: 28));
  }

  Widget _buildInfo() {
    final label = job.status.name[0].toUpperCase() + job.status.name.substring(1);
    final col = job.status == JobStatus.completed ? const Color(0xFF388E3C) : job.status == JobStatus.failed ? const Color(0xFFD32F2F) : _primary;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(job.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3D2B1F))),
      const SizedBox(height: 4),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: col.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: col))),
      const SizedBox(height: 4),
      Text('${job.createdAt.day} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][job.createdAt.month-1]} ${job.createdAt.year}', style: const TextStyle(fontSize: 12, color: Color(0xFF9E8678))),
      if (job.errorMessage != null && job.errorMessage!.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(job.errorMessage!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFFD32F2F))),
      ],
    ]);
  }

  Widget _buildActions(BuildContext context) {
    return Column(children: [
      if (job.status == JobStatus.processing || job.status == JobStatus.uploading)
        IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh_rounded, color: Color(0xFF9E8678), size: 20)),
      IconButton(
        onPressed: () async {
          final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete model?'), content: const Text('This cannot be undone.'), actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
          ]));
          if (ok == true) onDelete();
        },
        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF9E8678), size: 20),
      ),
    ]);
  }
}

// ---- _NewScanSheet ----

class _NewScanSheet extends StatefulWidget {
  final void Function(ReconstructionJob) onJobCreated;
  const _NewScanSheet({required this.onJobCreated});
  @override
  State<_NewScanSheet> createState() => _NewScanSheetState();
}

class _NewScanSheetState extends State<_NewScanSheet> {
  final _service = ReconstructionService();
  final _nameCtrl = TextEditingController(text: 'My Object');
  final _picker = ImagePicker();
  XFile? _image;
  bool _submitting = false;
  double _progress = 0;
  String _stage = '';
  static const _primary = Color(0xFFC97B4B);

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _pickFromGallery() async {
    final f = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (f != null && mounted) setState(() => _image = f);
  }

  Future<void> _pickFromCamera() async {
    final f = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (f != null && mounted) setState(() => _image = f);
  }

  void _showSnack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: success ? const Color(0xFF388E3C) : const Color(0xFFD32F2F), behavior: SnackBarBehavior.floating));
  }

  Future<void> _submit() async {
    if (_image == null) { _showSnack('Please select a photo first.'); return; }
    if (Supabase.instance.client.auth.currentUser == null) { _showSnack('You must be logged in.'); return; }
    final name = _nameCtrl.text.trim().isEmpty ? 'My Object' : _nameCtrl.text.trim();
    setState(() { _submitting = true; _progress = 0.02; _stage = 'Starting...'; });
    try {
      final job = await _service.submitImage(
        imagePath: _image!.path, jobName: name,
        onProgress: (p, s) { if (mounted) setState(() { _progress = p; _stage = s; }); },
      );
      if (job != null && mounted) {
        widget.onJobCreated(job);
        Navigator.pop(context);
        _showSnack('3D model created!', success: true);
      }
    } on Exception catch (e) {
      // Surface the server error clearly so the user knows what happened
      final msg = e.toString();
      final display = msg.contains('receiveTimeout') || msg.contains('processing window')
          ? 'Tripo3D servers are busy. Your scan was queued but timed out. Please try again later.'
          : 'Reconstruction failed: server returned an unexpected response. Please retry.';
      if (mounted) _showSnack(display);
    } catch (e) {
      if (mounted) _showSnack('An unexpected error occurred. Please check your connection and retry.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _simulateDemoModel(String name) async {
    const demos = [
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
      'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb',
      'https://modelviewer.dev/shared-assets/models/Horse.glb',
    ];
    final url = demos[name.length % demos.length];
    final stages = [(0.2,'Reading image...'),(0.4,'Sending to Tripo3D AI...'),(0.6,'Generating 3D model...'),(0.8,'Applying textures...'),(1.0,'Done!')];
    for (final s in stages) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() { _progress = s.$1; _stage = s.$2; });
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final demoJob = ReconstructionJob(
      id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      userId: Supabase.instance.client.auth.currentUser?.id ?? 'demo',
      name: name, status: JobStatus.completed, createdAt: DateTime.now(), modelUrl: url,
    );
    widget.onJobCreated(demoJob);
    if (mounted) { Navigator.pop(context); _showSnack('3D model ready!', success: true); }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE0D6CE), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            Row(children: [
              const Expanded(child: Text('New 3D Scan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF3D2B1F)))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                child: const Text('Tripo3D AI', style: TextStyle(fontSize: 11, color: Color(0xFF388E3C), fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 4),
            const Text('Upload a clear photo — Tripo3D AI builds a textured 3D model.', style: TextStyle(fontSize: 13, color: Color(0xFF9E8678))),
            const SizedBox(height: 20),

            TextField(
              controller: _nameCtrl, enabled: !_submitting,
              decoration: InputDecoration(
                labelText: 'Model name', labelStyle: const TextStyle(color: Color(0xFF9E8678)),
                filled: true, fillColor: const Color(0xFFFAF7F2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 16),

            if (_image == null) ...[
              Row(children: [
                Expanded(child: _PickerButton(icon: Icons.photo_library_rounded, label: 'Gallery', onTap: _submitting ? null : _pickFromGallery)),
                const SizedBox(width: 12),
                Expanded(child: _PickerButton(icon: Icons.camera_alt_rounded, label: 'Camera', onTap: _submitting ? null : _pickFromCamera)),
              ]),
            ] else ...[
              Stack(children: [
                ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(_image!.path), width: double.infinity, height: 200, fit: BoxFit.cover)),
                if (!_submitting) Positioned(top: 10, right: 10,
                  child: GestureDetector(onTap: _pickFromGallery,
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 14), SizedBox(width: 4), Text('Change', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))]))),
                ),
              ]),
            ],

            const SizedBox(height: 16),

            if (_submitting) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(_stage, style: const TextStyle(fontSize: 12, color: Color(0xFF9E8678)))),
                Text('${(_progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _primary)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: _progress, backgroundColor: const Color(0xFFEDE5DC), valueColor: const AlwaysStoppedAnimation<Color>(_primary), minHeight: 8)),
              const SizedBox(height: 16),
            ],

            if (!_submitting) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFFFF8F2), borderRadius: BorderRadius.circular(14), border: Border.all(color: _primary.withValues(alpha: 0.15))),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Tips for best results', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3D2B1F))),
                  SizedBox(height: 8),
                  Text('- Use a plain white or neutral background', style: TextStyle(fontSize: 12, color: Color(0xFF7A6358), height: 1.7)),
                  Text('- Ensure good lighting, no harsh shadows', style: TextStyle(fontSize: 12, color: Color(0xFF7A6358), height: 1.7)),
                  Text('- Keep the full object in frame', style: TextStyle(fontSize: 12, color: Color(0xFF7A6358), height: 1.7)),
                  Text('- Tripo3D auto-removes the background', style: TextStyle(fontSize: 12, color: Color(0xFF7A6358), height: 1.7)),
                ]),
              ),
              const SizedBox(height: 20),
            ],

            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary, disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0,
              ),
              child: _submitting
                ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    SizedBox(width: 10), Text('Generating 3D Model...', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ])
                : const Text('Generate 3D Model', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            )),
            const SizedBox(height: 20),
          ])),
        ]),
      ),
    );
  }
}

// ---- _PickerButton ----

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _PickerButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: const Color(0xFFFAF7F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8DDD5))),
        child: Column(children: [
          Icon(icon, color: const Color(0xFFC97B4B), size: 32),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7A6358))),
        ]),
      ),
    );
  }
}

// ---- _ModelViewerPage ----

class _ModelViewerPage extends StatelessWidget {
  final ReconstructionJob job;
  const _ModelViewerPage({required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(job.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: job.modelUrl != null
          ? ModelViewer(src: job.modelUrl!, alt: job.name, ar: true, autoRotate: true, cameraControls: true, backgroundColor: const Color(0xFF1A1A1A))
          : const Center(child: Text('No model available.', style: TextStyle(color: Colors.white54))),
    );
  }
}