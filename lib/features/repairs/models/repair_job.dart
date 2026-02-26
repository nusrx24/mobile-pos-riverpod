enum RepairStatus { pending, inProgress, completed, delivered, cancelled }

class RepairJob {
  const RepairJob({
    required this.id,
    required this.customerName,
    required this.deviceModel,
    required this.issue,
    required this.status,
    this.createdAt,
    this.estimatedCost = 0,
    this.actualCost = 0,
    this.notes = '',
    this.customerPhone = '',
  });

  final String id;
  final String customerName;
  final String deviceModel;
  final String issue;
  final RepairStatus status;
  final DateTime? createdAt;
  final double estimatedCost;
  final double actualCost;
  final String notes;
  final String customerPhone;

  String get statusLabel {
    switch (status) {
      case RepairStatus.pending:
        return 'Pending';
      case RepairStatus.inProgress:
        return 'In Progress';
      case RepairStatus.completed:
        return 'Completed';
      case RepairStatus.delivered:
        return 'Delivered';
      case RepairStatus.cancelled:
        return 'Cancelled';
    }
  }

  RepairJob copyWith({
    String? id,
    String? customerName,
    String? deviceModel,
    String? issue,
    RepairStatus? status,
    DateTime? createdAt,
    double? estimatedCost,
    double? actualCost,
    String? notes,
    String? customerPhone,
  }) {
    return RepairJob(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      deviceModel: deviceModel ?? this.deviceModel,
      issue: issue ?? this.issue,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      notes: notes ?? this.notes,
      customerPhone: customerPhone ?? this.customerPhone,
    );
  }
}
