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
    debugPrint("Building SummaryWidget with ${transactions.length} transactions");
    
    // Calculate current month's spending and income
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    
    final currentMonthTransactions = transactions.where((txn) {
      return txn.date.isAfter(currentMonth.subtract(Duration(seconds: 1))) && 
             txn.date.isBefore(nextMonth);
    }).toList();
    
    debugPrint("Current month transactions: ${currentMonthTransactions.length}");
    
    double monthlySpending = 0;
    double monthlyIncome = 0;
    
    for (var txn in currentMonthTransactions) {
      if (txn.type == 'debit') {
        monthlySpending += txn.amount;
      } else if (txn.type == 'credit') {
        monthlyIncome += txn.amount;
      }
    }
    
    debugPrint("Monthly spending: $monthlySpending, Monthly income: $monthlyIncome");
    
    // Calculate today's spending and income
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(Duration(days: 1));
    
    final todayTransactions = transactions.where((txn) {
      return txn.date.isAfter(todayStart.subtract(Duration(seconds: 1))) && 
             txn.date.isBefore(tomorrowStart);
    }).toList();
    
    debugPrint("Today's transactions: ${todayTransactions.length}");
    
    double todaySpending = 0;
    double todayIncome = 0;
    
    for (var txn in todayTransactions) {
      if (txn.type == 'debit') {
        todaySpending += txn.amount;
      } else if (txn.type == 'credit') {
        todayIncome += txn.amount;
      }
    }
    
    debugPrint("Today's spending: $todaySpending, Today's income: $todayIncome");
    
    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Transaction Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            
            // Month summary
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(now),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Income: ${currencyFormat.format(monthlyIncome)}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Spent: ${currencyFormat.format(monthlySpending)}',
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
            ),
            
            SizedBox(height: 16),
            
            // Today summary
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Income: ${currencyFormat.format(todayIncome)}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Spent: ${currencyFormat.format(todaySpending)}',
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
            ),
          ],
        ),
      ),
    );
  }
} 