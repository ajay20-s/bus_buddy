import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardsPage extends StatefulWidget {
  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  int? totalCoins;
  Map<String, int>? rewards;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserId();
  }

  Future<void> fetchCurrentUserId() async {
    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      userId = user.id;
      print('User ID: $userId'); // Log the user ID
      await fetchTotalCoins(user.id);
    } else {
      print('Failed to fetch user ID');
    }
  }

  Future<void> fetchTotalCoins(String userId) async {
    try {
      final response = await supabaseClient.rpc('fetch_user_rewards',
          params: {'user_id_param': userId}).single();

      print('Response: $response'); // Log the response

      if (response != null && response.isNotEmpty) {
        setState(() {
          totalCoins = response['total'] as int?;
          rewards = {
            for (int i = 1; i <= 30; i++) 'r$i': response['r$i'] as int? ?? 0
          };
        });
      } else {
        print('No data found for user.');
      }
    } catch (e) {
      print('Error fetching total coins: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Rewards'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: totalCoins == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/coin.png', // Make sure to have a coin image in assets/images
                      height: 100,
                      width: 100,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Total Coins',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${totalCoins ?? 0}',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Rewards Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: rewards?.length ?? 0,
                      itemBuilder: (context, index) {
                        String key = rewards!.keys.elementAt(index);
                        int value = rewards![key]!;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading:
                                Icon(Icons.star, size: 30, color: Colors.amber),
                            title: Text(
                              'Reward $key',
                              style: TextStyle(fontSize: 18),
                            ),
                            trailing: Text(
                              '$value',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
