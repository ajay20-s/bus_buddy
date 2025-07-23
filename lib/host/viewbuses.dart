import 'package:bus_buddy/host/Changebustimings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bus_buddy/dashboard/bus_details_page.dart'; // Adjust import paths as per your project
//import 'package:bus_buddy/host/change_bus_timings_page.dart'; // Adjust import paths as per your project
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewBusesPage extends StatefulWidget {
  @override
  _ViewBusesPageState createState() => _ViewBusesPageState();
}

class _ViewBusesPageState extends State<ViewBusesPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> busList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBusList();
  }

  void fetchBusList() async {
    try {
      DateTime now = DateTime.now();
      String dayType =
          (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday)
              ? 'weekend'
              : 'weekday';

      final List<dynamic> response = await supabaseClient
          .from('buses')
          .select('*')
          .order('outtime_time', ascending: true);

      setState(() {
        busList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Buses'),
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
                    'Available Buses',
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
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeBusTimingsPage(bus: bus),
                                ),
                              );
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
                                    'From: ${bus['from_location']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'To: ${bus['to_location']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Departure Time: ${bus['outtime_time']}',
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeBusTimingsPage(bus: bus),
                                ),
                              );
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
