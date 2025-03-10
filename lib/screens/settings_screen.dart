import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  final StorageService _storageService = StorageService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Clear Stored Transactions'),
            subtitle: Text('Delete all saved transaction data'),
            trailing: Icon(Icons.delete_outline),
            onTap: () {
              _showClearDataConfirmation(context);
            },
          ),
          Divider(),
          ListTile(
            title: Text('Bank SMS Filter Settings'),
            subtitle: Text('Customize which SMS are processed'),
            trailing: Icon(Icons.filter_list),
            onTap: () {
              // TODO: Implement bank filter settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('Customize Categories'),
            subtitle: Text('Edit transaction categories'),
            trailing: Icon(Icons.category),
            onTap: () {
              // TODO: Implement category customization
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('About'),
            subtitle: Text('App information and credits'),
            trailing: Icon(Icons.info_outline),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }
  
  void _showClearDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear All Data?'),
          content: Text(
            'This will delete all stored transactions. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _storageService.saveTransactions([]);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All data has been cleared')),
                );
              },
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Bank SMS Tracker',
      applicationVersion: '1.0.0',
      applicationLegalese: '©2024 Your Name',
      children: [
        SizedBox(height: 16),
        Text(
          'A Flutter application for tracking and visualizing bank transactions from SMS messages.',
        ),
      ],
    );
  }
} 