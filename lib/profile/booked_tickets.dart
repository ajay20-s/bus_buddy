import 'package:bus_buddy/profile/displayticketpage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BookedTicketsPage extends StatefulWidget {
  @override
  _BookedTicketsPageState createState() => _BookedTicketsPageState();
}

class _BookedTicketsPageState extends State<BookedTicketsPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> ticketsList = [];
  bool isLoading = true;
  final String bt = 'Booking Time';

  @override
  void initState() {
    super.initState();
    fetchBookedTickets();
  }

  void fetchBookedTickets() async {
    setState(() {
      isLoading = true;
    });

    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      try {
        final List<dynamic> response = await supabaseClient
            .from('tickets')
            .select(
                'ticket_id, payment_method, price, booking_date, bus_number')
            .eq('user_id', user.id);

        if (response != null) {
          setState(() {
            ticketsList = List<Map<String, dynamic>>.from(response);
            isLoading = false;
          });
        } else {
          print('No tickets found for user with ID: ${user.id}');
          setState(() {
            ticketsList.clear(); // Ensure list is cleared if no data is found
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching booked tickets: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Current user is null');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatBookingDate(String isoDateTime) {
    // Parse ISO date time string
    DateTime dateTime = DateTime.parse(isoDateTime);

    // Add 5 hours and 30 minutes to the date time
    DateTime adjustedDateTime = dateTime.add(Duration(hours: 5, minutes: 30));

    // Format to show only date and time
    return DateFormat('yyyy-MM-dd HH:mm').format(adjustedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booked Tickets'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ticketsList.isEmpty
              ? Center(child: Text('No booked tickets found'))
              : ListView.builder(
                  itemCount: ticketsList.length,
                  itemBuilder: (context, index) {
                    final ticket = ticketsList[ticketsList.length - 1 - index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text('Ticket ID: ${ticket['ticket_id']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Payment Method: ${ticket['payment_method']}'),
                            Text('Price: ${ticket['price']}'),
                            Text(
                                'Booking Date: ${formatBookingDate(ticket['booking_date'])}'),
                            Text('Bus Number: ${ticket['bus_number']}'),
                          ],
                        ),
                        onTap: () {
                          // Navigate to DisplayTicketPage and pass ticket_id and bus_number
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DisplayTicketPage(
                                ticketId: ticket['ticket_id'],
                                busNumber: ticket['bus_number'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
