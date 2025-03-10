import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'transaction_card.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onTap;
  
  const TransactionList({
    Key? key,
    required this.transactions,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Sort transactions by date (newest first)
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    // Group transactions by date
    Map<String, List<Transaction>> groupedTransactions = {};
    
    for (var transaction in sortedTransactions) {
      final dateStr = DateFormat('dd MMM yyyy').format(transaction.date);
      
      if (!groupedTransactions.containsKey(dateStr)) {
        groupedTransactions[dateStr] = [];
      }
      
      groupedTransactions[dateStr]!.add(transaction);
    }
    
    return ListView.builder(
      itemCount: groupedTransactions.keys.length,
      itemBuilder: (context, index) {
        final dateStr = groupedTransactions.keys.elementAt(index);
        final dayTransactions = groupedTransactions[dateStr]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                dateStr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
            
            // Transaction cards for this date
            ...dayTransactions.map((transaction) {
              return TransactionCard(
                transaction: transaction,
                onTap: () => onTap(transaction),
              );
            }).toList(),
          ],
        );
      },
    );
  }
} 