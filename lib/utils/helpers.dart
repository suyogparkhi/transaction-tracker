import 'package:intl/intl.dart';

class AppHelpers {
  // Get formatted date
  static String getFormattedDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }
  
  // Get formatted currency
  static String getFormattedCurrency(double amount, {String symbol = '₹', int decimalDigits = 0}) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }
  
  // Get simple date range for filtering
  static Map<String, DateTime> getDateRange(String range) {
    final now = DateTime.now();
    
    switch (range) {
      case 'today':
        final start = DateTime(now.year, now.month, now.day);
        return {'start': start, 'end': now};
      
      case 'week':
        final start = now.subtract(Duration(days: now.weekday - 1));
        return {'start': DateTime(start.year, start.month, start.day), 'end': now};
      
      case 'month':
        final start = DateTime(now.year, now.month, 1);
        return {'start': start, 'end': now};
      
      case 'year':
        final start = DateTime(now.year, 1, 1);
        return {'start': start, 'end': now};
      
      default:
        return {'start': DateTime(2000), 'end': now};
    }
  }
} 