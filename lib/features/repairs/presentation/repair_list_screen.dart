import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../logic/repair_provider.dart';
import '../models/repair_job.dart';

class RepairListScreen extends ConsumerWidget {
  const RepairListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(repairProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repairs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go('/repairs/add'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _StatusFilterBar(
            currentFilter: state.filterStatus,
            onFilter: ref.read(repairProvider.notifier).setFilter,
          ),
        ),
      ),
      body: state.isLoading
          ? const LoadingIndicator()
          : state.error != null
              ? Center(child: Text(state.error!))
              : state.filtered.isEmpty
                  ? const Center(
                      child: Text('No repair jobs found.',
                          style: TextStyle(color: Colors.grey)))
                  : RefreshIndicator(
                      onRefresh: ref.read(repairProvider.notifier).loadJobs,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _RepairCard(job: state.filtered[i]),
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/repairs/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Job'),
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({
    required this.currentFilter,
    required this.onFilter,
  });

  final RepairStatus? currentFilter;
  final void Function(RepairStatus?) onFilter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _FilterChip(
            label: 'All',
            isSelected: currentFilter == null,
            onTap: () => onFilter(null),
          ),
          ...RepairStatus.values.map((s) => _FilterChip(
                label: _statusLabel(s),
                isSelected: currentFilter == s,
                color: _statusColor(s),
                onTap: () => onFilter(s),
              )),
        ],
      ),
    );
  }

  String _statusLabel(RepairStatus s) {
    switch (s) {
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

  Color _statusColor(RepairStatus s) {
    switch (s) {
      case RepairStatus.pending:
        return Colors.orange;
      case RepairStatus.inProgress:
        return Colors.blue;
      case RepairStatus.completed:
        return Colors.green;
      case RepairStatus.delivered:
        return Colors.purple;
      case RepairStatus.cancelled:
        return Colors.red;
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final primary = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? primary : primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _RepairCard extends ConsumerWidget {
  const _RepairCard({required this.job});

  final RepairJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(job.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.deviceModel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                _StatusBadge(label: job.statusLabel, color: statusColor),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              job.issue,
              style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline_rounded,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(job.customerName,
                    style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.7))),
                const Spacer(),
                Icon(Icons.calendar_today_rounded,
                    size: 14,
                    color: colorScheme.onSurface.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(job.createdAt != null ? AppFormatters.date(job.createdAt!) : '-',
                    style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.7))),
              ],
            ),
            if (job.estimatedCost > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Est. Cost: ${AppFormatters.currency(job.estimatedCost)}',
                style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 12),
            _StatusUpdateRow(job: job),
          ],
        ),
      ),
    );
  }

  Color _statusColor(RepairStatus s) {
    switch (s) {
      case RepairStatus.pending:
        return Colors.orange;
      case RepairStatus.inProgress:
        return Colors.blue;
      case RepairStatus.completed:
        return Colors.green;
      case RepairStatus.delivered:
        return Colors.purple;
      case RepairStatus.cancelled:
        return Colors.red;
    }
  }
}

class _StatusUpdateRow extends ConsumerWidget {
  const _StatusUpdateRow({required this.job});

  final RepairJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Update status:',
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(width: 8),
        DropdownButton<RepairStatus>(
          value: job.status,
          isDense: true,
          underline: const SizedBox(),
          onChanged: (s) {
            if (s != null) {
              ref.read(repairProvider.notifier).updateStatus(job.id, s);
            }
          },
          items: RepairStatus.values.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(
                _label(s),
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _label(RepairStatus s) {
    switch (s) {
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
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
