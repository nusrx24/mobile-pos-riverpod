import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../models/invoice.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/billing'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share feature coming soon!')),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.print_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Print feature coming soon!')),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 36),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Invoice Generated!',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invoice.id,
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.dateTime(invoice.createdAt),
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Customer & Payment
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                        label: 'Customer',
                        value: invoice.customerName ?? 'Walk-in Customer'),
                    _InfoRow(label: 'Payment', value: invoice.paymentLabel),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    ...invoice.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.product.name,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                '${item.quantity} × ${AppFormatters.currency(item.unitPrice)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppFormatters.currency(item.total),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Totals
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _TotalRow('Subtotal', AppFormatters.currency(invoice.subtotal)),
                    if (invoice.discount > 0)
                      _TotalRow('Discount (${invoice.discount.toStringAsFixed(0)}%)',
                          '-${AppFormatters.currency(invoice.discountAmount)}',
                          color: Colors.orange),
                    _TotalRow('Tax (5%)', AppFormatters.currency(invoice.taxAmount)),
                    const Divider(),
                    _TotalRow(
                      'Grand Total',
                      AppFormatters.currency(invoice.grandTotal),
                      isBold: true,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/billing'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New Sale'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.value,
      {this.isBold = false, this.color});

  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: isBold ? 15 : 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: color,
              )),
          Text(value,
              style: TextStyle(
                fontSize: isBold ? 15 : 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: color,
              )),
        ],
      ),
    );
  }
}
