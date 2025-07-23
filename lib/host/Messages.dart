import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  bool isLoading = false;

  static const String recipientId = 'b1fe43e6-90d7-4ff5-bb8d-f15f30139b84';

  void sendMessage() async {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message cannot be empty')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        print('User ID: $userId');
        final response = await supabaseClient.from('messages').insert({
          'sender_id': userId,
          'recipient_id': recipientId,
          'message_text': _messageController.text,
        }).single();

        print('Response: $response');

        // Check if response is null or has an error
        if (response == null || response['error'] != null) {
          throw response['error'] ?? 'Unknown error occurred';
        }

        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message sent successfully')),
        );
      } else {
        print('User ID is null');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User is not authenticated')),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Type your message',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: sendMessage,
                    child: Text('Send'),
                  ),
          ],
        ),
      ),
    );
  }
}
