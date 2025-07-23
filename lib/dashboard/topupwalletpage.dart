import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TopUpWalletPage extends StatefulWidget {
  @override
  _TopUpWalletPageState createState() => _TopUpWalletPageState();
}

class _TopUpWalletPageState extends State<TopUpWalletPage> {
  final TextEditingController _amountController = TextEditingController();
  final SupabaseClient supabaseClient = Supabase.instance.client;

  void _makePayment() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an amount of at least 100')),
      );
      return;
    }

    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Fetch the current wallet data
      final response = await supabaseClient
          .from('wallet')
          .select()
          .eq('user_id', userId)
          .maybeSingle(); // Use maybeSingle to handle the absence of rows

      Map<String, dynamic> walletData;

      if (response == null) {
        // Insert a new wallet row if it doesn't exist
        walletData = {
          'user_id': userId,
          'balance': amount,
          'p1': amount,
        };
        await supabaseClient.from('wallet').insert(walletData);
      } else {
        // Update existing wallet row
        walletData = response;

        // Find the first empty pX field
        String? emptyPColumn;
        for (int i = 1; i <= 10; i++) {
          if (walletData['p$i'] == null) {
            emptyPColumn = 'p$i';
            break;
          }
        }

        if (emptyPColumn == null) {
          throw Exception('All payment fields are filled');
        }

        walletData[emptyPColumn] = amount;
        walletData['balance'] = (walletData['balance'] as double) + amount;

        await supabaseClient.from('wallet').update({
          emptyPColumn: amount,
          'balance': walletData['balance']
        }).eq('user_id', userId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment of \$${amount} made successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Up Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Enter amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _makePayment,
              child: Text('Make Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
