import '../models/transaction.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class ParserService {
  // Extract transaction details from SMS messages
  List<Transaction> parseTransactions(List<SmsMessage> smsList) {
    List<Transaction> transactions = [];

    for (var sms in smsList) {
      Map<String, dynamic> extractedData = _extractDataFromSms(sms);
      if (extractedData.isNotEmpty) {
        transactions.add(Transaction.fromSmsMap(extractedData));
      }
    }

    return transactions;
  }

  // Extract relevant information from SMS body
  Map<String, dynamic> _extractDataFromSms(SmsMessage sms) {
    String body = sms.body ?? '';
    String sender = sms.sender ?? '';
    
    // Skip if body is empty
    if (body.isEmpty) return {};

    // Sample implementation - customize based on your bank's SMS formats
    Map<String, dynamic> data = {
      'date': sms.date,
      'account': _extractAccount(body, sender),
      'amount': _extractAmount(body),
      'type': _determineTxnType(body),
      'description': body,
      'merchantName': _extractMerchant(body),
    };

    // Add category based on merchant or description
    data['category'] = _categorizeTransaction(data['merchantName'], body);

    return data;
  }

  // Extract account information
  String _extractAccount(String body, String sender) {
    // Example patterns - customize based on your bank's SMS format
    RegExp accountRegex = RegExp(r'a/c\s*\.?:?\s*([xX*]+\d{4})', caseSensitive: false);
    var match = accountRegex.firstMatch(body);
    
    if (match != null) {
      return match.group(1) ?? 'Unknown';
    }
    
    // Alternative: try to extract last 4 digits
    RegExp lastFourRegex = RegExp(r'([xX*]+\d{4})', caseSensitive: false);
    match = lastFourRegex.firstMatch(body);
    if (match != null) {
      return match.group(1) ?? 'Unknown';
    }
    
    return sender; // Default to sender as account identifier
  }

  // Extract transaction amount
  double _extractAmount(String body) {
    // Common patterns for currency
    RegExp amountRegex = RegExp(r'(?:INR|Rs\.?|₹)\s*(\d+(?:[,.]\d+)?)', caseSensitive: false);
    var match = amountRegex.firstMatch(body);
    
    if (match != null) {
      String amount = match.group(1) ?? '0';
      // Replace comma with dot and parse
      amount = amount.replaceAll(',', '');
      return double.tryParse(amount) ?? 0.0;
    }
    
    // Alternative: look for number after 'amount' or similar words
    RegExp altAmountRegex = RegExp(r'(?:amount|amt|sum)(?:\s+of)?\s+(?:INR|Rs\.?|₹)?\s*(\d+(?:[,.]\d+)?)', caseSensitive: false);
    match = altAmountRegex.firstMatch(body);
    
    if (match != null) {
      String amount = match.group(1) ?? '0';
      amount = amount.replaceAll(',', '');
      return double.tryParse(amount) ?? 0.0;
    }
    
    return 0.0;
  }

  // Determine transaction type (debit/credit)
  String _determineTxnType(String body) {
    body = body.toLowerCase();
    
    // Credit indicators
    if (body.contains('credit') || 
        body.contains('credited') || 
        body.contains('received') ||
        body.contains('added') ||
        body.contains('deposited')) {
      return 'credit';
    }
    
    // Debit indicators
    if (body.contains('debit') || 
        body.contains('debited') || 
        body.contains('spent') ||
        body.contains('paid') ||
        body.contains('withdrawn')) {
      return 'debit';
    }
    
    // Default to debit as most bank alerts are for spending
    return 'debit';
  }

  // Extract merchant name from transaction SMS
  String _extractMerchant(String body) {
    // Common patterns for merchant names
    RegExp merchantRegex = RegExp(r'at\s+([A-Za-z0-9\s]+)', caseSensitive: false);
    var match = merchantRegex.firstMatch(body);
    
    if (match != null) {
      return match.group(1)?.trim() ?? 'Unknown';
    }
    
    // Alternative: look for text after 'to' or 'toward'
    RegExp altMerchantRegex = RegExp(r'to\s+([A-Za-z0-9\s]+)', caseSensitive: false);
    match = altMerchantRegex.firstMatch(body);
    
    if (match != null) {
      return match.group(1)?.trim() ?? 'Unknown';
    }
    
    return 'Unknown';
  }

  // Categorize transaction based on merchant or description
  String _categorizeTransaction(String merchant, String description) {
    String text = (merchant + ' ' + description).toLowerCase();
    
    Map<String, List<String>> categories = {
      'Food & Dining': ['restaurant', 'food', 'café', 'cafe', 'dining', 'swiggy', 'zomato', 'uber eats'],
      'Transportation': ['uber', 'ola', 'taxi', 'cab', 'metro', 'train', 'bus', 'fuel', 'petrol', 'diesel'],
      'Shopping': ['amazon', 'flipkart', 'mall', 'shop', 'store', 'retail', 'myntra', 'ajio'],
      'Utilities': ['electricity', 'water', 'gas', 'bill', 'recharge', 'mobile', 'phone', 'airtel', 'jio', 'utility'],
      'Entertainment': ['movie', 'cinema', 'theatre', 'netflix', 'amazon prime', 'hotstar', 'subscription'],
      'Health': ['hospital', 'medical', 'pharmacy', 'doctor', 'clinic', 'medicine', 'healthcare'],
      'Education': ['school', 'college', 'university', 'course', 'tuition', 'fee', 'education'],
      'Travel': ['hotel', 'flight', 'booking', 'trip', 'travel', 'makemytrip', 'oyo', 'airbnb'],
    };
    
    for (var category in categories.keys) {
      for (var keyword in categories[category]!) {
        if (text.contains(keyword)) {
          return category;
        }
      }
    }
    
    return 'Miscellaneous';
  }
} 