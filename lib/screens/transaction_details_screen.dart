import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;
  final Function(String) onCategoryChanged;
  
  const TransactionDetailsScreen({
    Key? key,
    required this.transaction,
    required this.onCategoryChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Format the date and amount
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount with transaction type indicator
            Card(
              color: transaction.type == 'credit' ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.type == 'credit' ? 'Received' : 'Spent',
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    Text(
                      currencyFormat.format(transaction.amount),
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: transaction.type == 'credit' ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16.0),
            
            // Transaction information
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow('Date', dateFormat.format(transaction.date)),
                    Divider(),
                    _detailRow('Merchant', transaction.merchantName),
                    Divider(),
                    _detailRow('Account', transaction.account),
                    Divider(),
                    _detailRow('Category', transaction.category),
                    TextButton(
                      onPressed: () {
                        _showCategorySelectionDialog(context);
                      },
                      child: Text('Change Category'),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16.0),
            
            // Original message
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original Message',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16.0,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showCategorySelectionDialog(BuildContext context) {
    final categories = [
      'Food & Dining',
      'Transportation',
      'Shopping',
      'Utilities',
      'Entertainment',
      'Health',
      'Education',
      'Travel',
      'Miscellaneous',
    ];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Category'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categories[index]),
                  onTap: () {
                    onCategoryChanged(categories[index]);
                    Navigator.pop(context);
                  },
                  selected: transaction.category == categories[index],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
} 