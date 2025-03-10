import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class StorageService {
  static const String TRANSACTION_KEY = 'bank_transactions';
  
  // Save transactions to local storage
  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert transactions to JSON
    List<String> jsonTransactions = transactions
        .map((transaction) => jsonEncode(transaction.toMap()))
        .toList();
    
    await prefs.setStringList(TRANSACTION_KEY, jsonTransactions);
  }
  
  // Get transactions from local storage
  Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String>? jsonTransactions = prefs.getStringList(TRANSACTION_KEY);
    
    if (jsonTransactions == null || jsonTransactions.isEmpty) {
      return [];
    }
    
    // Convert JSON to Transaction objects
    return jsonTransactions
        .map((jsonTxn) => Transaction.fromMap(jsonDecode(jsonTxn)))
        .toList();
  }
  
  // Add a single transaction
  Future<void> addTransaction(Transaction transaction) async {
    List<Transaction> transactions = await getTransactions();
    
    // Check if transaction already exists
    bool exists = transactions.any((txn) => txn.id == transaction.id);
    
    if (!exists) {
      transactions.add(transaction);
      await saveTransactions(transactions);
    }
  }
  
  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    List<Transaction> transactions = await getTransactions();
    transactions.removeWhere((txn) => txn.id == id);
    await saveTransactions(transactions);
  }
  
  // Update transaction category
  Future<void> updateTransactionCategory(String id, String category) async {
    List<Transaction> transactions = await getTransactions();
    
    int index = transactions.indexWhere((txn) => txn.id == id);
    
    if (index != -1) {
      Transaction txn = transactions[index];
      Transaction updatedTxn = Transaction(
        id: txn.id,
        date: txn.date,
        amount: txn.amount,
        type: txn.type,
        account: txn.account,
        description: txn.description,
        merchantName: txn.merchantName,
        category: category,
      );
      
      transactions[index] = updatedTxn;
      await saveTransactions(transactions);
    }
  }
} 