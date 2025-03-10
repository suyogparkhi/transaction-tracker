import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  
  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Format the date and amount
    final dateFormat = DateFormat('dd MMM, hh:mm a');
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    // Category icons (you can customize these)
    final Map<String, IconData> categoryIcons = {
      'Food & Dining': Icons.restaurant,
      'Transportation': Icons.directions_car,
      'Shopping': Icons.shopping_cart,
      'Utilities': Icons.payment,
      'Entertainment': Icons.movie,
      'Health': Icons.local_hospital,
      'Education': Icons.school,
      'Travel': Icons.flight,
      'Miscellaneous': Icons.category,
    };
    
    final IconData categoryIcon = categoryIcons[transaction.category] ?? Icons.category;
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Category Icon
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  categoryIcon,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              SizedBox(width: 12),
              
              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.merchantName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      dateFormat.format(transaction.date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      transaction.category,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Amount
              Text(
                currencyFormat.format(transaction.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: transaction.type == 'credit' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 