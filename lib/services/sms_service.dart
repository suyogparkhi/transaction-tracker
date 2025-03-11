import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class SmsService {
  final Telephony _telephony = Telephony.instance;

  // Request SMS permissions
  Future<bool> requestSmsPermission() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
      debugPrint("SMS permission requested, result: ${status.isGranted}");
    } else {
      debugPrint("SMS permission already granted");
    }
    return status.isGranted;
  }

  // Get all SMS messages
  Future<List<SmsMessage>> getAllSms() async {
    if (await requestSmsPermission()) {
      var messages = await _telephony.getInboxSms();
      debugPrint("Retrieved ${messages.length} total SMS messages");
      return messages;
    }
    debugPrint("SMS permission denied");
    return [];
  }

  // Get bank SMS messages based on sender patterns
  Future<List<SmsMessage>> getBankSms() async {
    List<SmsMessage> allSms = await getAllSms();
    
    // Filter messages from bank senders (add your bank SMS sender IDs)
    List<String> bankSenders = [
      'HDFC', 'SBI', 'ICICI', 'AXIS', 'CITI', 'HSBC', 'KOTAK', 'YESB', 'IDBI', 'PNB',
      'BOI', 'CANARA', 'UNION', 'INDUS', 'FEDERAL', 'RBL', 'DBS', 'SCB', 'BARB', 'BOB',
      'BANK', 'CARD', 'CREDIT', 'DEBIT', 'PAYMENT', 'PAYTM', 'GPAY', 'PHONEPE', 'UPI',
      // Add other bank identifiers here
    ];
    
    // Keywords that indicate transaction messages
    List<String> transactionKeywords = [
      'debited', 'credited', 'spent', 'received', 'payment', 'purchase',
      'transaction', 'transfer', 'withdraw', 'deposit', 'paid', 'debit', 'credit',
      'txn', 'a/c', 'account', 'bal', 'balance', 'amt', 'amount', 'rs', 'inr', '₹'
    ];
    
    // Keywords that indicate non-transaction messages
    List<String> nonTransactionKeywords = [
      'otp', 'password', 'verify', 'verification', 'security', 'secure', 'login',
      'access', 'authenticate', 'code'
    ];
    
    List<SmsMessage> filteredSms = allSms.where((sms) {
      String sender = sms.address?.toUpperCase() ?? '';
      String body = sms.body?.toLowerCase() ?? '';
      
      // Check if it's from a bank
      bool isFromBank = bankSenders.any((bank) => sender.contains(bank));
      
      // Check if it contains transaction keywords
      bool hasTransactionKeyword = transactionKeywords.any((keyword) => body.contains(keyword));
      
      // Check if it's likely an OTP or alert message
      bool isNonTransaction = nonTransactionKeywords.any((keyword) => 
        body.contains(keyword) && body.indexOf(keyword) < 15);
      
      // Additional check for amount patterns (INR, Rs., ₹)
      bool hasAmountPattern = RegExp(r'(?:INR|Rs\.?|₹)\s*\d+').hasMatch(body);
      
      // For debugging
      if (isFromBank) {
        debugPrint("Bank SMS found: ${sms.address}");
        debugPrint("Body: ${sms.body}");
        debugPrint("Has transaction keyword: $hasTransactionKeyword");
        debugPrint("Is non-transaction: $isNonTransaction");
        debugPrint("Has amount pattern: $hasAmountPattern");
      }
      
      // Less strict filtering - just require it to be from a bank and either have transaction keywords or amount pattern
      return isFromBank && (hasTransactionKeyword || hasAmountPattern) && !isNonTransaction;
    }).toList();
    
    debugPrint("Found ${filteredSms.length} bank transaction SMS messages");
    return filteredSms;
  }
} 