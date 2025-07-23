import 'package:bus_buddy/dashboard/ChoosePaymentPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusDetailsPage extends StatefulWidget {
  final Map<String, dynamic> bus;
  final int bookedSeats;

  BusDetailsPage({required this.bus, required this.bookedSeats});

  @override
  _BusDetailsPageState createState() => _BusDetailsPageState();
}

class _BusDetailsPageState extends State<BusDetailsPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  int pointer = 1;

  void bookTickets(int numberOfTickets) {
    if ((widget.bookedSeats + numberOfTickets) <= widget.bus['total_seats']) {
      List<String> selectedSeatNumbers = [];
      for (int i = 0; i < numberOfTickets; i++) {
        String seatNumber =
            '${widget.bus['bus_number']}${pointer.toString().padLeft(2, '0')}';
        selectedSeatNumbers.add(seatNumber);
        pointer++;
      }

      // Navigate to ChoosePaymentPage with necessary details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChoosePaymentPage(
            busNumber: widget.bus['bus_number'],
            fromLocation: widget.bus['from_location'],
            toLocation: widget.bus['to_location'],
            outTime: widget.bus['outtime_time'],
            numberOfTickets: numberOfTickets,
            bookedSeats: widget.bookedSeats,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not enough seats available for booking!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ), /*
        title: Text('Bus Details'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),*/
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Bus Details',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.directions_bus,
                                size: 40, color: Colors.blueAccent),
                            SizedBox(width: 10),
                            Text('Bus Number: ${widget.bus['bus_number']}',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 40, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Text('From: ${widget.bus['from_location']}',
                                style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Icon(Icons.flag,
                                size: 40, color: Colors.greenAccent),
                            SizedBox(width: 10),
                            Text('To: ${widget.bus['to_location']}',
                                style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 40, color: Colors.orangeAccent),
                            SizedBox(width: 10),
                            Text('Out Time: ${widget.bus['outtime_time']}',
                                style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Icon(Icons.event_seat,
                                size: 40, color: Colors.purpleAccent),
                            SizedBox(width: 10),
                            Text('Total Seats: ${widget.bus['total_seats']}',
                                style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Icon(Icons.confirmation_number,
                                size: 40, color: Colors.tealAccent),
                            SizedBox(width: 10),
                            Text('Booked Seats: ${widget.bookedSeats}',
                                style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Select Number of Tickets'),
                        content: DropdownButton<int>(
                          value: 1,
                          items: [1, 2].map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value'),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            if (value != null) {
                              Navigator.of(context).pop(); // Close the dialog
                              bookTickets(value);
                            }
                          },
                        ),
                      ),
                    );
                  },
                  child: Text('Book Tickets'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: TextStyle(fontSize: 18), // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
