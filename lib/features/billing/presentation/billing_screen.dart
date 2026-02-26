import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../inventory/logic/inventory_provider.dart';
import '../../inventory/models/product.dart';
import '../logic/cart_provider.dart';
import '../models/cart_item.dart';
import '../models/invoice.dart';

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final inventoryState = ref.watch(inventoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        actions: [
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: cartState.isLoading,
        child: Column(
          children: [
            // Product picker
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      'Add Products',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    child: inventoryState.products.isEmpty
                        ? const Center(child: Text('No products available'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: inventoryState.products.length,
                            itemBuilder: (context, i) {
                              final product = inventoryState.products[i];
                              return _ProductTile(product: product);
                            },
                          ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Cart
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        Text(
                          'Cart (${cartState.itemCount} items)',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  if (cartState.items.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Cart is empty.\nAdd products above.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: cartState.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, i) {
                          return _CartItemTile(item: cartState.items[i]);
                        },
                      ),
                    ),

                    // Summary section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: Column(
                        children: [
                          // Discount row
                          Row(
                            children: [
                              const Text('Discount (%):'),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  initialValue: '0',
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    isDense: true,
                                  ),
                                  onChanged: (v) => ref
                                      .read(cartProvider.notifier)
                                      .setDiscount(double.tryParse(v) ?? 0),
                                ),
                              ),
                              const Spacer(),
                              // Payment type
                              DropdownButton<PaymentType>(
                                value: cartState.paymentType,
                                underline: const SizedBox(),
                                onChanged: (t) => ref
                                    .read(cartProvider.notifier)
                                    .setPaymentType(t!),
                                items: PaymentType.values.map((t) {
                                  return DropdownMenuItem(
                                    value: t,
                                    child: Row(
                                      children: [
                                        Icon(_paymentIcon(t), size: 18),
                                        const SizedBox(width: 4),
                                        Text(t.name.toUpperCase(),
                                            style: const TextStyle(fontSize: 13)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _SummaryRow('Subtotal', AppFormatters.currency(cartState.subtotal)),
                          _SummaryRow('Discount',
                              '-${AppFormatters.currency(cartState.discountAmount)}',
                              color: Colors.orange),
                          _SummaryRow('Tax (5%)', AppFormatters.currency(cartState.taxAmount)),
                          const Divider(),
                          _SummaryRow(
                            'Total',
                            AppFormatters.currency(cartState.grandTotal),
                            isBold: true,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: cartState.items.isEmpty
                                  ? null
                                  : () => _checkout(context, ref),
                              icon: const Icon(Icons.receipt_long_rounded),
                              label: const Text('Generate Invoice'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _paymentIcon(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Icons.money_rounded;
      case PaymentType.card:
        return Icons.credit_card_rounded;
      case PaymentType.transfer:
        return Icons.swap_horiz_rounded;
    }
  }

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    final invoice = await ref.read(cartProvider.notifier).checkout();
    if (invoice != null && context.mounted) {
      context.go('/billing/invoice', extra: invoice);
    }
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      leading: CircleAvatar(
        backgroundColor: colorScheme.primary.withOpacity(0.1),
        child: Icon(Icons.smartphone_rounded, color: colorScheme.primary, size: 20),
      ),
      title: Text(product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(AppFormatters.currency(product.retailPrice),
          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_rounded),
        color: colorScheme.primary,
        onPressed: () => ref.read(cartProvider.notifier).addProduct(product),
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(AppFormatters.currency(item.unitPrice),
                      style: TextStyle(color: colorScheme.primary, fontSize: 12)),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                  onPressed: () => ref
                      .read(cartProvider.notifier)
                      .updateQuantity(item.product.id, item.quantity - 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                Text('${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  onPressed: () => ref
                      .read(cartProvider.notifier)
                      .updateQuantity(item.product.id, item.quantity + 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Text(AppFormatters.currency(item.total),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
              onPressed: () =>
                  ref.read(cartProvider.notifier).removeProduct(item.product.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.isBold = false, this.color});

  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                fontSize: isBold ? 15 : 13,
                color: color,
              )),
          Text(value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                fontSize: isBold ? 15 : 13,
                color: color,
              )),
        ],
      ),
    );
  }
}
