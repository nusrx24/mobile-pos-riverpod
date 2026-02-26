import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../logic/customer_provider.dart';
import '../models/customer.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final customer = Customer(
      id: 'c${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await ref.read(customerProvider.notifier).addCustomer(customer);
    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        context.go('/customers');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add customer.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Customer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/customers'),
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
                label: 'Full Name',
                controller: _nameCtrl,
                prefixIcon: Icons.person_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Name is required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Phone Number',
                controller: _phoneCtrl,
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Phone is required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Email (optional)',
                controller: _emailCtrl,
                prefixIcon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Address (optional)',
                controller: _addressCtrl,
                prefixIcon: Icons.location_on_rounded,
                maxLines: 2,
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
                      : const Text('Add Customer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
