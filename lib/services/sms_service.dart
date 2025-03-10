import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  final SmsQuery _query = SmsQuery();

  // Request SMS permissions
  Future<bool> requestSmsPermission() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
    }
    return status.isGranted;
  }

  // Get all SMS messages
  Future<List<SmsMessage>> getAllSms() async {
    if (await requestSmsPermission()) {
      return await _query.getAllSms;
    }
    return [];
  }

  // Get bank SMS messages based on sender patterns
  Future<List<SmsMessage>> getBankSms() async {
    List<SmsMessage> allSms = await getAllSms();
    
    // Filter messages from bank senders (add your bank SMS sender IDs)
    List<String> bankSenders = [
      'HDFC', 'SBI', 'ICICI', 'AXIS', 'CITI', 'HSBC',
      // Add other bank identifiers here
    ];
    
    return allSms.where((sms) {
      String sender = sms.sender?.toUpperCase() ?? '';
      return bankSenders.any((bank) => sender.contains(bank));
    }).toList();
  }
} 