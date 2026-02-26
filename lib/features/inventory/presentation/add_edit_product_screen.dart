import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../logic/inventory_provider.dart';
import '../models/product.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  const AddEditProductScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _retailCtrl = TextEditingController();
  final _wholesaleCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  Product? _existing;
  bool _isSaving = false;

  bool get _isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadProduct());
    }
  }

  void _loadProduct() {
    final state = ref.read(inventoryProvider);
    try {
      final product = state.products.firstWhere((p) => p.id == widget.productId);
      _existing = product;
      _nameCtrl.text = product.name;
      _brandCtrl.text = product.brand;
      _retailCtrl.text = product.retailPrice.toString();
      _wholesaleCtrl.text = product.wholesalePrice.toString();
      _quantityCtrl.text = product.quantity.toString();
      _categoryCtrl.text = product.category;
      _descCtrl.text = product.description;
      setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _retailCtrl.dispose();
    _wholesaleCtrl.dispose();
    _quantityCtrl.dispose();
    _categoryCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final id = _existing?.id ??
        'p${DateTime.now().millisecondsSinceEpoch}';

    final product = Product(
      id: id,
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      retailPrice: double.tryParse(_retailCtrl.text) ?? 0,
      wholesalePrice: double.tryParse(_wholesaleCtrl.text) ?? 0,
      quantity: int.tryParse(_quantityCtrl.text) ?? 0,
      category: _categoryCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      imeiList: _existing?.imeiList ?? [],
    );

    bool success;
    if (_isEdit) {
      success = await ref.read(inventoryProvider.notifier).updateProduct(product);
    } else {
      success = await ref.read(inventoryProvider.notifier).addProduct(product);
    }

    setState(() => _isSaving = false);
    if (mounted) {
      if (success) {
        context.go('/inventory');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save product.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Product' : 'Add Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/inventory'),
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
                label: 'Product Name',
                controller: _nameCtrl,
                prefixIcon: Icons.smartphone_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Name is required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Brand',
                controller: _brandCtrl,
                prefixIcon: Icons.branding_watermark_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Brand is required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Category',
                controller: _categoryCtrl,
                prefixIcon: Icons.category_rounded,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Retail Price',
                      controller: _retailCtrl,
                      prefixIcon: Icons.sell_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Wholesale Price',
                      controller: _wholesaleCtrl,
                      prefixIcon: Icons.price_change_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Quantity',
                controller: _quantityCtrl,
                prefixIcon: Icons.inventory_2_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Invalid';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Description',
                controller: _descCtrl,
                prefixIcon: Icons.description_rounded,
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
                      : Text(_isEdit ? 'Save Changes' : 'Add Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
