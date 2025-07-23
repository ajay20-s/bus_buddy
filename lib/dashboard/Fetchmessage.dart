import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FetchMessagesPage extends StatefulWidget {
  const FetchMessagesPage({Key? key}) : super(key: key);

  @override
  _FetchMessagesPageState createState() => _FetchMessagesPageState();
}

class _FetchMessagesPageState extends State<FetchMessagesPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> messagesList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  void fetchMessages() async {
    try {
      final response = await supabaseClient
          .from('messages')
          .select('*')
          .eq('recipient_id', 'b1fe43e6-90d7-4ff5-bb8d-f15f30139b84')
          .order('sent_at', ascending: true);
      // .limit(10) // Adjust as per your requirement
      // .single();

      /*if (response['error'] != null) {
        throw response['error']!;
      }*/

      setState(() {
        messagesList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching messages: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('dd-MM-yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messagesList.length,
              itemBuilder: (context, index) {
                final message = messagesList[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      'Host',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('message: ${message['message_text']}'),
                        SizedBox(height: 5),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Sent at: ${formatDate(message['sent_at'])}',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
