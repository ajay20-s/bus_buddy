import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewTicketPage extends StatefulWidget {
  final List<String> ticketIds;

  ViewTicketPage({required this.ticketIds});

  @override
  _ViewTicketPageState createState() => _ViewTicketPageState();
}

class _ViewTicketPageState extends State<ViewTicketPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  final String supabaseUrl =
      'https://slegdqmdyihkvwjvtpva.supabase.co'; // Replace with your Supabase URL
  final String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsZWdkcW1keWloa3Z3anZ0cHZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE5NzAyNTgsImV4cCI6MjAyNzU0NjI1OH0.B6rB3CiBZq0dZMtj93de_2GPWi3WYTqhhgl_d_Q62-k'; // Replace with your Supabase anon key

  Map<String, String?> qrCodeImages = {};
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchQRCodes();
    fetchCurrentUserId();
  }

  Future<void> fetchCurrentUserId() async {
    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      setState(() {
        userId = user.id;
      });
    } else {
      print('Failed to fetch user ID');
    }
  }

  Future<void> fetchQRCodes() async {
    for (var ticketId in widget.ticketIds) {
      String lastTwoDigits = ticketId.substring(ticketId.length - 2);
      await fetchQRCodeImage(lastTwoDigits);
    }
  }

  Future<void> fetchQRCodeImage(String lastTwoDigits) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$supabaseUrl/rest/v1/qrcodes?select=id,qr_code_image&or=(id.ilike.*$lastTwoDigits)'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            qrCodeImages[lastTwoDigits] = data[0]['qr_code_image'];
          });
        } else {
          setState(() {
            qrCodeImages[lastTwoDigits] = null;
          });
          print('QR code not found for id ending with: $lastTwoDigits');
        }
      } else {
        print('Failed to fetch QR code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching QR code: $e');
    }
  }

  Future<void> updateAccRewards(String userId) async {
    try {
      // Step 1: Check if the user already exists in the accrewards table
      final response = await supabaseClient
          .from('accreward')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      // If the user does not exist, insert a new record
      if (response == null) {
        await insertNewUserAccRewards(userId);
      }

      // Fetch a single reward
      final rewardCoins = await fetchSingleReward();

      // Update the rewards for the user
      await updateExistingAccRewards(userId, rewardCoins);
    } catch (e) {
      print('Error updating accrewards: $e');
    }
  }

  Future<void> insertNewUserAccRewards(String userId) async {
    try {
      final insertResponse = await supabaseClient.from('accreward').insert({
        'user_id': userId,
        'mark': null,
        'r1': 0,
        'r2': 0,
        'r3': 0,
        'r4': 0,
        'r5': 0,
        'r6': 0,
        'r7': 0,
        'r8': 0,
        'r9': 0,
        'r10': 0,
        'r11': 0,
        'r12': 0,
        'r13': 0,
        'r14': 0,
        'r15': 0,
        'r16': 0,
        'r17': 0,
        'r18': 0,
        'r19': 0,
        'r20': 0,
        'r21': 0,
        'r22': 0,
        'r23': 0,
        'r24': 0,
        'r25': 0,
        'r26': 0,
        'r27': 0,
        'r28': 0,
        'r29': 0,
        'r30': 0,
      });

      if (insertResponse.error != null) {
        print(
            'Error inserting new accrewards record: ${insertResponse.error!.message}');
      }
    } catch (e) {
      print('Error inserting new accrewards record: $e');
    }
  }

  Future<void> updateExistingAccRewards(String userId, int rewardCoins) async {
    try {
      // Fetch the existing rewards data
      final response = await supabaseClient
          .from('accreward')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        print('No existing rewards found for user $userId');
        return;
      }

      final existingRewards = response['data'] as Map<String, dynamic>?;

      // Print the fetched coins
      print('Fetched coins: $rewardCoins');

      // Determine the next available r field (r1 to r30) where the value is 0 or null
      String? nextRField;
      for (int i = 1; i <= 30; i++) {
        final rField = 'r$i';
        if (existingRewards?[rField] == null || existingRewards?[rField] == 0) {
          nextRField = rField;
          break;
        }
      }

      if (nextRField == null) {
        print('No available r fields to update');
        return;
      }

      final updateResponse = await supabaseClient.from('accreward').update({
        nextRField: rewardCoins,
      }).eq('user_id', userId);

      if (updateResponse.error != null) {
        print('Failed to update accrewards: ${updateResponse.error!.message}');
      } else {
        print('Rewards updated successfully.');
        showUpdateSuccessMessage();
      }
    } catch (e) {
      print('Error updating accrewards: $e');
    }
  }

  Future<int> fetchSingleReward() async {
    final rewardOptions = [50, 100, 150, 200, 250];
    final random = Random();
    return rewardOptions[random.nextInt(rewardOptions.length)];
  }

  Future<void> triggerRewardShift(String userId) async {
    try {
      final response = await supabaseClient
          .rpc('shift_rewards_for_user', params: {'user_id_param': userId});

      if (response.error != null) {
        print('Error triggering reward shift: ${response.error!.message}');
      } else {
        print('Reward shift triggered successfully.');
      }
    } catch (e) {
      print('Error triggering reward shift: $e');
    }
  }

  void showUpdateSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rewards updated successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showScratchCardMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You won a scratch card!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) async {
      // Delay before fetching rewards
      await Future.delayed(Duration(seconds: 1));

      if (userId != null) {
        // Await updateAccRewards to ensure it completes before redirecting
        await updateAccRewards(userId!);

        // Trigger the reward shift
        await triggerRewardShift(userId!);
      }

      // Wait for 5 seconds and then redirect to the Dashboard
      await Future.delayed(Duration(seconds: 5));

      Navigator.pushReplacementNamed(context, '/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Tickets'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Tickets',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Column(
                children: widget.ticketIds.map((ticketId) {
                  String lastTwoDigits =
                      ticketId.substring(ticketId.length - 2);
                  return Column(
                    children: [
                      Text(ticketId, style: TextStyle(fontSize: 16)),
                      qrCodeImages.containsKey(lastTwoDigits)
                          ? (qrCodeImages[lastTwoDigits] != null
                              ? Image.memory(
                                  base64Decode(qrCodeImages[lastTwoDigits]!),
                                  width: 200,
                                  height: 200,
                                )
                              : Text('No QR Code available'))
                          : CircularProgressIndicator(),
                      SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showScratchCardMessage,
        child: Icon(Icons.card_giftcard),
      ),
    );
  }
}
