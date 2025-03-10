import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class SummaryWidget extends StatelessWidget {
  final List<Transaction> transactions;
  
  const SummaryWidget({
    Key? key,
    required this.transactions,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Calculate current month's spending and income
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    
    final currentMonthTransactions = transactions.where((txn) {
      final txnMonth = DateTime(txn.date.year, txn.date.month);
      return txnMonth.isAtSameMomentAs(currentMonth);
    }).toList();
    
    double monthlySpending = 0;
    double monthlyIncome = 0;
    
    for (var txn in currentMonthTransactions) {
      if (txn.type == 'debit') {
        monthlySpending += txn.amount;
      } else {
        monthlyIncome += txn.amount;
      }
    }
    
    // Calculate today's spending and income
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayTransactions = transactions.where((txn) {
      return txn.date.isAfter(todayStart) || 
             txn.date.isAtSameMomentAs(todayStart);
    }).toList();
    
    double todaySpending = 0;
    double todayIncome = 0;
    
    for (var txn in todayTransactions) {
      if (txn.type == 'debit') {
        todaySpending += txn.amount;
      } else {
        todayIncome += txn.amount;
      }
    }
    
    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          // Month summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(now),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.arrow_downward,
                    color: Colors.green,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    currencyFormat.format(monthlyIncome),
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    Icons.arrow_upward,
                    color: Colors.red,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    currencyFormat.format(monthlySpending),
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          Divider(height: 24),
          
          // Today summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.arrow_downward,
                    color: Colors.green,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    currencyFormat.format(todayIncome),
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    Icons.arrow_upward,
                    color: Colors.red,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    currencyFormat.format(todaySpending),
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
} 