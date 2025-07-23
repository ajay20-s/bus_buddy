import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ChangeBusTimingsPage extends StatefulWidget {
  final Map<String, dynamic> bus;

  const ChangeBusTimingsPage({Key? key, required this.bus}) : super(key: key);

  @override
  _ChangeBusTimingsPageState createState() => _ChangeBusTimingsPageState();
}

class _ChangeBusTimingsPageState extends State<ChangeBusTimingsPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    try {
      // Parse the outtime_time safely
      String outtime = widget.bus['outtime_time'];
      selectedTime = TimeOfDay(
          hour: int.parse(outtime.split(":")[0]),
          minute: int.parse(outtime.split(":")[1]));
    } catch (e) {
      // Handle parsing error, default to current time if parse fails
      selectedTime = TimeOfDay.fromDateTime(DateTime.now());
      print('Error parsing outtime_time: $e');
    }
  }

  Future<void> updateBusTiming() async {
    try {
      // Check if bus or bus['id'] is null
      if (widget.bus == null || widget.bus['id'] == null) {
        throw Exception('Bus details are missing or invalid');
      }

      // Format selectedTime to HH:mm format
      String formattedTime = "${selectedTime.hour}:${selectedTime.minute}";

      final response = await supabaseClient
          .from('buses')
          .update({'outtime_time': formattedTime})
          .eq('id', widget.bus['id'])
          .single();
      //.execute();

      // Check if response is null or has an error
      if (response['error'] != null) {
        throw Exception('Error updating bus timing: ${response['error']}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bus timing updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating bus timing: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Bus Timings'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Bus Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From: ${widget.bus['from_location']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'To: ${widget.bus['to_location']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Current Departure Time: ${selectedTime.format(context)}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Select New Departure Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  setState(() {
                    selectedTime = picked;
                  });
                }
              },
              child: Text('Select Time'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                updateBusTiming();
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
