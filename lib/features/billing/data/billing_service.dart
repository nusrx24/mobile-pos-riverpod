import '../models/invoice.dart';

class BillingService {
  final List<Invoice> _invoices = [];

  Future<Invoice> saveInvoice(Invoice invoice) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _invoices.add(invoice);
    return invoice;
  }

  Future<List<Invoice>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_invoices);
  }
}
