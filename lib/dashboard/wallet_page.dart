import 'package:bus_buddy/dashboard/topupwalletpage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  double walletBalance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await supabaseClient
          .from('wallet')
          .select('balance')
          .eq('user_id', userId)
          .single();

      setState(() {
        walletBalance = response['balance'] ?? 0.0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Wallet Balance: \Rs$walletBalance',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TopUpWalletPage()),
                      ).then((_) {
                        _fetchWalletBalance(); // Refresh balance after top-up
                      });
                    },
                    child: Text('Top Up Wallet'),
                  ),
                ],
              ),
      ),
    );
  }
}
