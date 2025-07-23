import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class ShowTicketsPage extends StatefulWidget {
  @override
  State<ShowTicketsPage> createState() => _ShowTicketsPageState();
}

class _ShowTicketsPageState extends State<ShowTicketsPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> busList = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchBusList();
  }

  void fetchBusList() async {
    setState(() {
      isLoading = true;
    });

    try {
      String dayType = (selectedDate.weekday == DateTime.saturday ||
              selectedDate.weekday == DateTime.sunday)
          ? 'weekend'
          : 'weekday';

      final List<dynamic> response = await supabaseClient
          .from('buses')
          .select('*')
          .eq('bus_type', dayType)
          .order('outtime_time', ascending: true);
      // .execute()
      /*    .then((res) {
       if (res['error'] != null) {
          throw Exception('Error fetching buses: ${res.error!.message}');
        }
        return res.data;
      }
      );
      */

      if (response != null) {
        setState(() {
          busList = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });

        // Fetch ticket counts for each bus
        for (var bus in busList) {
          final ticketCountResponse = await supabaseClient
              .from('ticketcount')
              .select('d${DateFormat('ddMMyyyy').format(selectedDate)}')
              .eq('bus_number', bus['bus_number'])
              .single()
              .then((res) {
            if (res['error'] != null) {
              print('Error fetching ticket count: ${res['error']!.message}');
              return null;
            } else if (res['data'] != null) {
              return res['data'];
            } else {
              print('No data found for ticket count');
              return null;
            }
          }).catchError((error) {
            print('Error fetching ticket count: $error');
            return null;
          });

          if (ticketCountResponse != null) {
            bus['ticket_count'] = ticketCountResponse[
                    'd${DateFormat('ddMMyyyy').format(selectedDate)}'] ??
                0;
          } else {
            bus['ticket_count'] =
                0; // Handle case where ticket count is not available
          }
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        fetchBusList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Buses'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Select Date',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => selectDate(context),
                    child: Text('Choose Date'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Available Buses on ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: busList.length,
                    itemBuilder: (context, index) {
                      final bus = busList[index];
                      int ticketCount = bus['ticket_count'] ?? 0;

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Handle bus tap
                              // For example, navigate to details or update page
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 20),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bus Number: ${bus['bus_number']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'From: ${bus['from_location']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'To: ${bus['to_location']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Departure Time: ${bus['outtime_time']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tickets Booked: $ticketCount',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Handle button press
                              // For example, navigate to edit timings page
                            },
                            child: Text('Change'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
