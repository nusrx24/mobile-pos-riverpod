import '../models/repair_job.dart';

class RepairService {
  final List<RepairJob> _jobs = [
    RepairJob(
      id: 'r1',
      customerName: 'Alice Brown',
      customerPhone: '+1 555-0201',
      deviceModel: 'iPhone 13',
      issue: 'Cracked screen replacement',
      status: RepairStatus.inProgress,
      estimatedCost: 150.00,
      createdAt: DateTime(2024, 3, 10),
    ),
    RepairJob(
      id: 'r2',
      customerName: 'Bob Wilson',
      customerPhone: '+1 555-0202',
      deviceModel: 'Samsung Galaxy S22',
      issue: 'Battery replacement',
      status: RepairStatus.pending,
      estimatedCost: 80.00,
      createdAt: DateTime(2024, 3, 12),
    ),
    RepairJob(
      id: 'r3',
      customerName: 'Carol Martinez',
      customerPhone: '+1 555-0203',
      deviceModel: 'Google Pixel 7',
      issue: 'Charging port repair',
      status: RepairStatus.completed,
      estimatedCost: 60.00,
      actualCost: 65.00,
      createdAt: DateTime(2024, 3, 8),
    ),
  ];

  Future<List<RepairJob>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_jobs);
  }

  Future<RepairJob> create(RepairJob job) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _jobs.add(job);
    return job;
  }

  Future<RepairJob> update(RepairJob job) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _jobs.indexWhere((j) => j.id == job.id);
    if (index != -1) _jobs[index] = job;
    return job;
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _jobs.removeWhere((j) => j.id == id);
  }
}
