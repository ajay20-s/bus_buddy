import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketWidget extends StatelessWidget {
  final int numberOfTickets;
  final List<String> ticketIDs;
  final String busNumber;
  final int farePerSeat;

  TicketWidget({
    required this.numberOfTickets,
    required this.ticketIDs,
    required this.busNumber,
    required this.farePerSeat,
  });

  String getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> confirmBooking(BuildContext context) async {
    final supabaseClient = Supabase.instance.client;
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      // Handle user not logged in
      return;
    }

    // Check if the user exists
    final userResponse = await supabaseClient
        .from('users')
        .select('id')
        .eq('auth_id', user.id)
        .single();

    if (userResponse['error'] != null) {
      // Handle error if user fetch fails
      print('Error fetching user: ${userResponse['error']!['message']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book tickets.')),
      );
      return;
    }

    if (userResponse['data'] == null || userResponse['data']!.isEmpty) {
      // User does not exist in the database
      print('User does not exist.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User does not exist.')),
      );
      return;
    }

    final userId = userResponse['data']![0]['id'] as String;

    try {
      // Fetch bus_id based on busNumber
      final busResponse = await supabaseClient
          .from('buses')
          .select('id')
          .eq('bus_number', busNumber)
          .single();

      if (busResponse['error'] != null || busResponse['data'] == null) {
        print('Error fetching bus ID: ${busResponse['error']?['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book tickets.')),
        );
        return;
      }

      final busId = busResponse['data']![0]['id'] as int;

      // Fetch current booked seats for the bus
      final response = await supabaseClient
          .from('buses')
          .select('booked_seats')
          .eq('id', busId)
          .single();

      if (response['error'] != null) {
        print('Error fetching booked seats: ${response['error']!['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book tickets.')),
        );
        return;
      }

      int currentBookedSeats =
          response['data']![0]['booked_seats'] as int? ?? 0;

      // Insert tickets into the tickets table
      for (int i = 0; i < numberOfTickets; i++) {
        await supabaseClient.from('tickets').insert({
          'user_id': userId,
          'bus_number': busNumber,
          'seat_number': currentBookedSeats + i + 1,
          'price': farePerSeat,
          'payment_method': 'cash_on_delivery',
          'status': 'booked',
        });
      }

      // Update booked seats in the buses table
      await supabaseClient.from('buses').update({
        'booked_seats': currentBookedSeats + numberOfTickets,
      }).eq('id', busId);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tickets booked successfully!')),
      );
    } catch (e) {
      print('Error booking tickets: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book tickets.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime bookedDate =
        DateTime.now(); // Get the current date as the booked date

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket Widget'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Number of Tickets Booked: $numberOfTickets'),
            SizedBox(height: 20),
            Text('Booked Date: ${getFormattedDate(bookedDate)}'),
            SizedBox(height: 20),
            Text('Ticket IDs:'),
            Column(
              children: ticketIDs.map((id) => Text(id)).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                confirmBooking(context);
              },
              child: Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
