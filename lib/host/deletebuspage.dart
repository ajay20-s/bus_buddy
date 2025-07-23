import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteBusPage extends StatefulWidget {
  @override
  _DeleteBusPageState createState() => _DeleteBusPageState();
}

class _DeleteBusPageState extends State<DeleteBusPage> {
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

  void deleteBus(int busId) async {
    try {
      await supabaseClient.from('buses').delete().eq('id', busId);
      fetchBusList(); // Refresh the list after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bus deleted successfully.'),
        ),
      );
    } catch (e) {
      print('Error deleting bus: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting bus.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Buses'),
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
                          Container(
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
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              deleteBus(bus['id']);
                            },
                            child: Text('Delete'),
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
