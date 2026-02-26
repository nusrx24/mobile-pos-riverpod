import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final _shortDate = DateFormat('MMM dd');

  static String currency(double amount) => _currency.format(amount);

  static String date(DateTime date) => _date.format(date);

  static String dateTime(DateTime date) => _dateTime.format(date);

  static String shortDate(DateTime date) => _shortDate.format(date);
}
