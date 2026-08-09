/// Represents the status of a 3D reconstruction job.
enum JobStatus { uploading, processing, completed, failed }

class ReconstructionJob {
  final String id;
  final String userId;
  final JobStatus status;
  final String? modelUrl;  // .glb download URL once completed
  final String? captureId; // Polycam capture ID for polling
  final String? thumbnailUrl;
  final String name;
  final DateTime createdAt;
  final String? errorMessage;

  const ReconstructionJob({
    required this.id,
    required this.userId,
    required this.status,
    required this.name,
    required this.createdAt,
    this.modelUrl,
    this.captureId,
    this.thumbnailUrl,
    this.errorMessage,
  });

  // ── Supabase row → ReconstructionJob ────────────────────────
  factory ReconstructionJob.fromMap(Map<String, dynamic> map) {
    return ReconstructionJob(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      status: _parseStatus(map['status'] as String? ?? 'processing'),
      modelUrl: map['model_url'] as String?,
      captureId: map['capture_id'] as String?,
      thumbnailUrl: map['thumbnail_url'] as String?,
      name: map['name'] as String? ?? 'My 3D Scan',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      errorMessage: map['error_message'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'status': status.name,
        'model_url': modelUrl,
        'capture_id': captureId,
        'thumbnail_url': thumbnailUrl,
        'name': name,
        'created_at': createdAt.toIso8601String(),
        'error_message': errorMessage,
      };

  ReconstructionJob copyWith({
    JobStatus? status,
    String? modelUrl,
    String? captureId,
    String? thumbnailUrl,
    String? errorMessage,
  }) {
    return ReconstructionJob(
      id: id,
      userId: userId,
      status: status ?? this.status,
      name: name,
      createdAt: createdAt,
      modelUrl: modelUrl ?? this.modelUrl,
      captureId: captureId ?? this.captureId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  static JobStatus _parseStatus(String s) {
    switch (s) {
      case 'uploading':   return JobStatus.uploading;
      case 'completed':   return JobStatus.completed;
      case 'failed':      return JobStatus.failed;
      default:            return JobStatus.processing;
    }
  }

  /// Human-readable label for the status chip
  String get statusLabel {
    switch (status) {
      case JobStatus.uploading:   return 'Uploading…';
      case JobStatus.processing:  return 'Generating 3D…';
      case JobStatus.completed:   return 'Ready';
      case JobStatus.failed:      return 'Failed';
    }
  }
}
