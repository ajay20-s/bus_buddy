import 'package:bus_buddy/dashboard/upipaymentpage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ticket_widget.dart';
//import 'upi_payment_page.dart';

class PaymentPage extends StatelessWidget {
  final int numberOfTickets;
  final int farePerSeat = 20;
  final List<String> selectedSeats;
  final String busNumber;
  final Function(bool) confirmBooking;

  PaymentPage({
    required this.numberOfTickets,
    required this.selectedSeats,
    required this.busNumber,
    required this.confirmBooking,
  });

  int calculateTotalFare() {
    return numberOfTickets * farePerSeat;
  }

  Future<Map<String, dynamic>> fetchBusDetails() async {
    final supabaseClient = Supabase.instance.client;

    try {
      final response = await supabaseClient
          .from('buses')
          .select('booked_seats')
          .eq('bus_number', busNumber)
          .single();

      if (response['error'] != null) {
        throw Exception(
            'Error fetching bus details: ${response['error']!['message']}');
      }

      if (response['data'] == null || response['data']!.isEmpty) {
        throw Exception('No data found for bus with bus number $busNumber');
      }

      return response['data']![0];
    } catch (e) {
      print('Error fetching bus details: $e');
      throw Exception('Failed to fetch bus details: $e');
    }
  }

  Future<List<String>> generateUniqueTicketIDs() async {
    try {
      final busDetails = await fetchBusDetails();
      if (busDetails.isEmpty) {
        throw Exception('No data found for bus with bus number $busNumber');
      }
      int currentBookedSeats = busDetails['booked_seats'] as int? ?? 0;

      DateTime now = DateTime.now();
      String date = now.day.toString().padLeft(2, '0');
      String month = now.month.toString().padLeft(2, '0');
      String year = now.year.toString();

      List<String> ticketIDs = [];
      for (int i = 0; i < numberOfTickets; i++) {
        int tempNumber = currentBookedSeats + i + 1;
        String tempNumberString = tempNumber.toString().padLeft(2, '0');
        String ticketID = '$busNumber$date$month$year$tempNumberString';
        ticketIDs.add(ticketID);
      }
      return ticketIDs;
    } catch (e) {
      print('Error generating ticket IDs: $e');
      throw Exception('Failed to generate ticket IDs: $e');
    }
  }

  void redirectToTicketWidget(BuildContext context, List<String> ticketIDs) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketWidget(
          numberOfTickets: numberOfTickets,
          ticketIDs: ticketIDs,
          busNumber: busNumber,
          farePerSeat: farePerSeat,
        ),
      ),
    );
  }

  void redirectToUPIPaymentPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UPIPaymentPage(
          totalFare: numberOfTickets * farePerSeat,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalFare = calculateTotalFare();

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Select Number of Tickets to Book: $numberOfTickets'),
            SizedBox(height: 20),
            Text('Total Fare: $totalFare Rs'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  List<String> ticketIDs = await generateUniqueTicketIDs();
                  redirectToTicketWidget(context, ticketIDs);
                  confirmBooking(true);
                } catch (e) {
                  print('Error generating ticket IDs: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to generate ticket IDs.')),
                  );
                  confirmBooking(false);
                }
              },
              child: Text('Cash on Delivery'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                redirectToUPIPaymentPage(context);
                // Implement UPI Payment logic here
              },
              child: Text('UPI Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
