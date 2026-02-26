import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../logic/repair_provider.dart';
import '../models/repair_job.dart';

class AddRepairScreen extends ConsumerStatefulWidget {
  const AddRepairScreen({super.key});

  @override
  ConsumerState<AddRepairScreen> createState() => _AddRepairScreenState();
}

class _AddRepairScreenState extends ConsumerState<AddRepairScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  final _deviceCtrl = TextEditingController();
  final _issueCtrl = TextEditingController();
  final _estimatedCostCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _deviceCtrl.dispose();
    _issueCtrl.dispose();
    _estimatedCostCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final job = RepairJob(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      customerName: _customerNameCtrl.text.trim(),
      customerPhone: _customerPhoneCtrl.text.trim(),
      deviceModel: _deviceCtrl.text.trim(),
      issue: _issueCtrl.text.trim(),
      status: RepairStatus.pending,
      estimatedCost: double.tryParse(_estimatedCostCtrl.text) ?? 0,
      notes: _notesCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await ref.read(repairProvider.notifier).addJob(job);
    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        context.go('/repairs');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add repair job.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Repair Job'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/repairs'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Customer Name',
                controller: _customerNameCtrl,
                prefixIcon: Icons.person_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Customer Phone',
                controller: _customerPhoneCtrl,
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Device Model',
                controller: _deviceCtrl,
                prefixIcon: Icons.smartphone_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Issue / Problem',
                controller: _issueCtrl,
                prefixIcon: Icons.build_rounded,
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Estimated Cost',
                controller: _estimatedCostCtrl,
                prefixIcon: Icons.attach_money_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Notes (optional)',
                controller: _notesCtrl,
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Add Repair Job'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
