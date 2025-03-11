import '../models/transaction.dart';
import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';

class ParserService {
  // Extract transaction details from SMS messages
  List<Transaction> parseTransactions(List<SmsMessage> smsList) {
    List<Transaction> transactions = [];
    debugPrint("Parsing ${smsList.length} SMS messages");

    for (var sms in smsList) {
      Map<String, dynamic> extractedData = _extractDataFromSms(sms);
      if (extractedData.isNotEmpty) {
        transactions.add(Transaction.fromSmsMap(extractedData));
        debugPrint("Added transaction: ${extractedData['amount']} ${extractedData['type']} at ${extractedData['merchantName']}");
      }
    }

    debugPrint("Total transactions parsed: ${transactions.length}");
    return transactions;
  }

  // Extract relevant information from SMS body
  Map<String, dynamic> _extractDataFromSms(SmsMessage sms) {
    String body = sms.body ?? '';
    String sender = sms.address ?? '';
    
    // Skip if body is empty
    if (body.isEmpty) {
      debugPrint("Skipping empty SMS body");
      return {};
    }

    // Convert timestamp to DateTime
    DateTime dateTime = sms.date != null 
        ? DateTime.fromMillisecondsSinceEpoch(sms.date!) 
        : DateTime.now();

    double amount = _extractAmount(body);
    String type = _determineTxnType(body);
    String merchantName = _extractMerchant(body);
    
    // Skip if amount is 0 (likely not a transaction)
    if (amount == 0.0) {
      debugPrint("Skipping SMS with zero amount: $body");
      return {};
    }

    // Sample implementation - customize based on your bank's SMS formats
    Map<String, dynamic> data = {
      'id': sms.date?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'date': dateTime,
      'account': _extractAccount(body, sender),
      'amount': amount,
      'type': type,
      'description': body,
      'merchantName': merchantName,
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
    List<RegExp> amountRegexes = [
      // Standard format: Rs. 1,234.56 or ₹1,234.56
      RegExp(r'(?:INR|Rs\.?|₹)\s*(\d+(?:[,.]\d+)?)', caseSensitive: false),
      
      // Amount mentioned after keywords
      RegExp(r'(?:amount|amt|sum)(?:\s+of)?\s+(?:INR|Rs\.?|₹)?\s*(\d+(?:[,.]\d+)?)', caseSensitive: false),
      
      // Just numbers with decimal (likely to be amount)
      RegExp(r'(?:[\s:]|^)(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?)(?:\s|$)', caseSensitive: false),
      
      // UPI specific format
      RegExp(r'(?:paid|received|sent|debited|credited)\s+(?:Rs\.?|INR|₹)?\s*(\d+(?:[,.]\d+)?)', caseSensitive: false),
    ];
    
    for (var regex in amountRegexes) {
      var match = regex.firstMatch(body);
      if (match != null) {
        String amount = match.group(1) ?? '0';
        // Replace comma with empty string and parse
        amount = amount.replaceAll(',', '');
        double? parsedAmount = double.tryParse(amount);
        if (parsedAmount != null && parsedAmount > 0) {
          debugPrint("Extracted amount: $parsedAmount from: $body");
          return parsedAmount;
        }
      }
    }
    
    debugPrint("Could not extract amount from: $body");
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
    debugPrint("Extracting merchant from: $body");
    
    // Special case for bank transfers that mention names
    RegExp transferFromRegex = RegExp(r'transfer(?:\s+from)?\s+([A-Za-z0-9\s&\-\.]+?)(?:\s+Ref|\s+UPI|\s+IMPS|\s+NEFT|\s+RTGS|$)', caseSensitive: false);
    var match = transferFromRegex.firstMatch(body);
    if (match != null && match.group(1) != null) {
      String merchant = match.group(1)!.trim();
      debugPrint("Found transfer from: $merchant");
      return merchant;
    }
    
    // Special case for bank transfers that mention "to" names
    RegExp transferToRegex = RegExp(r'transfer(?:\s+to)?\s+([A-Za-z0-9\s&\-\.]+?)(?:\s+Ref|\s+UPI|\s+IMPS|\s+NEFT|\s+RTGS|$)', caseSensitive: false);
    match = transferToRegex.firstMatch(body);
    if (match != null && match.group(1) != null) {
      String merchant = match.group(1)!.trim();
      debugPrint("Found transfer to: $merchant");
      return merchant;
    }
    
    // Common patterns for merchant names
    List<RegExp> merchantRegexes = [
      // "at MERCHANT_NAME" pattern
      RegExp(r'at\s+([A-Za-z0-9\s&\-\.]+?)(?:\s+on|\s+for|\s+via|\s+using|$)', caseSensitive: false),
      
      // "to MERCHANT_NAME" pattern
      RegExp(r'to\s+([A-Za-z0-9\s&\-\.]+?)(?:\s+on|\s+for|\s+via|\s+using|$)', caseSensitive: false),
      
      // "purchase at/from MERCHANT_NAME" pattern
      RegExp(r'(?:purchase|payment|txn|transaction)(?:\s+at|\s+from|\s+to)?\s+([A-Za-z0-9\s&\-\.]+?)(?:\s+on|\s+for|\s+via|\s+using|$)', caseSensitive: false),
      
      // "MERCHANT_NAME debited/credited" pattern
      RegExp(r'([A-Za-z0-9\s&\-\.]+?)\s+(?:debited|credited|paid|received)', caseSensitive: false),
      
      // UPI specific pattern
      RegExp(r'UPI-([A-Za-z0-9\s&\-\.]+?)(?:-|$)', caseSensitive: false),
      
      // Reference number pattern (often contains merchant info)
      RegExp(r'(?:Ref|Reference)\s+(?:No|Number)?\s*:?\s*([A-Za-z0-9]+)', caseSensitive: false),
    ];
    
    for (var regex in merchantRegexes) {
      var match = regex.firstMatch(body);
      if (match != null && match.group(1) != null) {
        String merchant = match.group(1)!.trim();
        // Filter out common non-merchant words
        List<String> nonMerchantWords = ['info', 'alert', 'bank', 'notification', 'update', 'account', 'your', 'you', 'has', 'have'];
        if (merchant.length > 2 && !nonMerchantWords.contains(merchant.toLowerCase())) {
          debugPrint("Found merchant: $merchant");
          return merchant;
        }
      }
    }
    
    // Look for names in all-caps (common in bank messages)
    RegExp allCapsNameRegex = RegExp(r'([A-Z]{2,}(?:\s+[A-Z]+){1,3})');
    match = allCapsNameRegex.firstMatch(body);
    if (match != null && match.group(1) != null) {
      String possibleName = match.group(1)!.trim();
      List<String> bankWords = ['SBI', 'HDFC', 'ICICI', 'AXIS', 'BANK', 'CREDIT', 'DEBIT', 'CARD', 'ACCOUNT', 'TRANSACTION'];
      if (!bankWords.contains(possibleName) && possibleName.length > 3) {
        debugPrint("Found all-caps name: $possibleName");
        return possibleName;
      }
    }
    
    debugPrint("No merchant found, returning Unknown");
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