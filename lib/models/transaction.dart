class Transaction {
  final String id;
  final DateTime date;
  final double amount;
  final String type; // 'credit' or 'debit'
  final String account;
  final String description;
  final String merchantName;
  final String category; // Can be inferred from description

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.account,
    required this.description,
    required this.merchantName,
    this.category = 'Uncategorized',
  });

  // Factory method to create a Transaction from a parsed SMS
  factory Transaction.fromSmsMap(Map<String, dynamic> data) {
    return Transaction(
      id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: data['date'] ?? DateTime.now(),
      amount: data['amount'] ?? 0.0,
      type: data['type'] ?? 'debit',
      account: data['account'] ?? 'Unknown',
      description: data['description'] ?? '',
      merchantName: data['merchantName'] ?? 'Unknown',
      category: data['category'] ?? 'Uncategorized',
    );
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'type': type,
      'account': account,
      'description': description,
      'merchantName': merchantName,
      'category': category,
    };
  }

  // Create Transaction from storage Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    DateTime dateTime;
    
    // Handle different date formats
    if (map['date'] is int) {
      // If date is stored as timestamp (milliseconds since epoch)
      dateTime = DateTime.fromMillisecondsSinceEpoch(map['date']);
    } else if (map['date'] is String) {
      // If date is stored as ISO8601 string
      try {
        dateTime = DateTime.parse(map['date']);
      } catch (e) {
        // Fallback to current date if parsing fails
        dateTime = DateTime.now();
      }
    } else {
      // Default to current date if date is missing or in unknown format
      dateTime = DateTime.now();
    }
    
    return Transaction(
      id: map['id'] ?? '',
      date: dateTime,
      amount: (map['amount'] is int) ? (map['amount'] as int).toDouble() : (map['amount'] ?? 0.0),
      type: map['type'] ?? 'debit',
      account: map['account'] ?? 'Unknown',
      description: map['description'] ?? '',
      merchantName: map['merchantName'] ?? 'Unknown',
      category: map['category'] ?? 'Uncategorized',
    );
  }
} 