import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'id_ID').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
