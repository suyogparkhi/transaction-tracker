import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/sms_service.dart';
import '../services/parser_service.dart';
import '../services/storage_service.dart';
import '../widgets/transaction_list.dart';
import '../widgets/summary_widget.dart';
import 'transaction_details_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SmsService _smsService = SmsService();
  final ParserService _parserService = ParserService();
  final StorageService _storageService = StorageService();
  
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
  
  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });
    
    // First try to load from storage
    List<Transaction> savedTransactions = await _storageService.getTransactions();
    
    if (savedTransactions.isNotEmpty) {
      setState(() {
        _transactions = savedTransactions;
        _isLoading = false;
      });
    } else {
      _refreshTransactions();
    }
  }
  
  Future<void> _refreshTransactions() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get bank SMS messages
      final bankSms = await _smsService.getBankSms();
      
      // Parse transactions from SMS
      final parsedTransactions = _parserService.parseTransactions(bankSms);
      
      // Save to storage
      await _storageService.saveTransactions(parsedTransactions);
      
      setState(() {
        _transactions = parsedTransactions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading transactions: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank SMS Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary widget (today's spending, monthly total, etc.)
                SummaryWidget(transactions: _transactions),
                
                // Transaction list
                Expanded(
                  child: _transactions.isEmpty
                      ? Center(
                          child: Text('No transactions found. Pull down to refresh.'),
                        )
                      : TransactionList(
                          transactions: _transactions,
                          onTap: (transaction) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionDetailsScreen(
                                  transaction: transaction,
                                  onCategoryChanged: (String newCategory) async {
                                    await _storageService.updateTransactionCategory(
                                      transaction.id,
                                      newCategory,
                                    );
                                    _loadTransactions();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshTransactions,
        tooltip: 'Refresh Transactions',
        child: Icon(Icons.refresh),
      ),
    );
  }
} 