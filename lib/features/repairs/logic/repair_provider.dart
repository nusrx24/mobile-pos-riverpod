import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repair_service.dart';
import '../models/repair_job.dart';

final repairServiceProvider =
    Provider<RepairService>((ref) => RepairService());

class RepairState {
  const RepairState({
    this.jobs = const [],
    this.isLoading = false,
    this.error,
    this.filterStatus,
  });

  final List<RepairJob> jobs;
  final bool isLoading;
  final String? error;
  final RepairStatus? filterStatus;

  List<RepairJob> get filtered {
    if (filterStatus == null) return jobs;
    return jobs.where((j) => j.status == filterStatus).toList();
  }

  RepairState copyWith({
    List<RepairJob>? jobs,
    bool? isLoading,
    String? error,
    bool clearError = false,
    RepairStatus? filterStatus,
    bool clearFilter = false,
  }) {
    return RepairState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
    );
  }
}

class RepairNotifier extends StateNotifier<RepairState> {
  RepairNotifier(this._service) : super(const RepairState()) {
    loadJobs();
  }

  final RepairService _service;

  Future<void> loadJobs() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final jobs = await _service.fetchAll();
      state = state.copyWith(jobs: jobs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addJob(RepairJob job) async {
    try {
      final created = await _service.create(job);
      state = state.copyWith(jobs: [...state.jobs, created]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateStatus(String id, RepairStatus status) async {
    try {
      final job = state.jobs.firstWhere((j) => j.id == id);
      final updated = await _service.update(job.copyWith(status: status));
      state = state.copyWith(
        jobs: state.jobs.map((j) => j.id == id ? updated : j).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteJob(String id) async {
    try {
      await _service.delete(id);
      state = state.copyWith(
        jobs: state.jobs.where((j) => j.id != id).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  void setFilter(RepairStatus? status) {
    if (status == state.filterStatus) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterStatus: status);
    }
  }
}

final repairProvider =
    StateNotifierProvider<RepairNotifier, RepairState>((ref) {
  return RepairNotifier(ref.read(repairServiceProvider));
});
