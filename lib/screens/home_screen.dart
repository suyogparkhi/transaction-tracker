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
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
  
  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    debugPrint("Loading transactions from storage");
    
    // First try to load from storage
    List<Transaction> savedTransactions = await _storageService.getTransactions();
    
    if (savedTransactions.isNotEmpty) {
      debugPrint("Loaded ${savedTransactions.length} transactions from storage");
      setState(() {
        _transactions = savedTransactions;
        _isLoading = false;
      });
    } else {
      debugPrint("No saved transactions found, refreshing from SMS");
      _refreshTransactions();
    }
  }
  
  Future<void> _refreshTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      debugPrint("Fetching bank SMS messages");
      // Get bank SMS messages
      final bankSms = await _smsService.getBankSms();
      debugPrint("Found ${bankSms.length} bank SMS messages");
      
      if (bankSms.isEmpty) {
        setState(() {
          _errorMessage = 'No bank SMS messages found. Make sure SMS permissions are granted.';
          _isLoading = false;
        });
        return;
      }
      
      // Parse transactions from SMS
      final parsedTransactions = _parserService.parseTransactions(bankSms);
      debugPrint("Parsed ${parsedTransactions.length} transactions");
      
      if (parsedTransactions.isEmpty) {
        setState(() {
          _errorMessage = 'Could not parse any transactions from SMS messages.';
          _isLoading = false;
        });
        return;
      }
      
      // Save to storage
      await _storageService.saveTransactions(parsedTransactions);
      debugPrint("Saved ${parsedTransactions.length} transactions to storage");
      
      setState(() {
        _transactions = parsedTransactions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading transactions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading transactions: $e')),
      );
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    debugPrint("Building HomeScreen with ${_transactions.length} transactions");
    
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
          : SafeArea(
              child: Column(
                children: [
                  // Error message if any
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(16),
                      width: double.infinity,
                      color: Colors.red.withOpacity(0.1),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  
                  // Summary widget (today's spending, monthly total, etc.)
                  if (_transactions.isNotEmpty)
                    Container(
                      child: SummaryWidget(transactions: _transactions),
                      constraints: BoxConstraints(minHeight: 150),
                    ),
                  
                  // Transaction list
                  Expanded(
                    child: _transactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('No transactions found.'),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _refreshTransactions,
                                  child: Text('Refresh Now'),
                                ),
                              ],
                            ),
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshTransactions,
        tooltip: 'Refresh Transactions',
        child: Icon(Icons.refresh),
      ),
    );
  }
} 