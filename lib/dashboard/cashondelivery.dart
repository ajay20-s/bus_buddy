import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'viewticket.dart'; // Assuming this is where you display the booked tickets

class CashOnDeliveryPage extends StatefulWidget {
  final String busNumber;
  final int numberOfTickets;
  final int bookedSeats;

  CashOnDeliveryPage({
    required this.busNumber,
    required this.numberOfTickets,
    required this.bookedSeats,
  });

  @override
  _CashOnDeliveryPageState createState() => _CashOnDeliveryPageState();
}

class _CashOnDeliveryPageState extends State<CashOnDeliveryPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<String> ticketIds = [];

  double walletBalance = 0.0;
  bool isBalanceLoading = true;

  @override
  void initState() {
    super.initState();
    generateTicketIds();
    fetchWalletBalance();
  }

  void generateTicketIds() {
    ticketIds.clear();
    for (int i = 0; i < widget.numberOfTickets; i++) {
      int seatNumber = widget.bookedSeats + i + 1;
      String ticketId = generateTicketId(widget.busNumber, seatNumber);
      ticketIds.add(ticketId);
    }
  }

  String generateTicketId(String busNumber, int seatNumber) {
    DateTime now = DateTime.now();
    String date = now.day.toString().padLeft(2, '0');
    String month = now.month.toString().padLeft(2, '0');
    String year = now.year.toString();
    String ticketId =
        '$busNumber$date$month${year.substring(year.length - 4)}${seatNumber.toString().padLeft(2, '0')}';
    return ticketId;
  }

  Future<void> fetchWalletBalance() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User ID is null');
      }

      final response = await supabaseClient
          .from('wallet')
          .select('balance')
          .eq('user_id', userId)
          .single();

      setState(() {
        walletBalance = response['balance'] ?? 0.0;
        isBalanceLoading = false;
      });
    } catch (e) {
      print('Error fetching wallet balance: $e');
      setState(() {
        isBalanceLoading = false;
      });
    }
  }

  Future<void> saveTicketToDatabase(String ticketId) async {
    final userId = supabaseClient.auth.currentUser?.id;

    if (userId == null) {
      print('User ID is null');
      return;
    }

    try {
      final insertResult = await supabaseClient.from('tickets').insert({
        'ticket_id': int.parse(ticketId),
        'user_id': userId,
        'bus_number': widget.busNumber,
        'seat_number': int.parse(
            ticketId.substring(10, 12)), // Extract seat number from ticketId
        'price': 20.00, // Assuming fixed price per ticket
        'payment_method': 'cash_on_delivery',
        'status': 'Booked',
      }).single();

      if (insertResult['error'] != null) {
        print('Error inserting ticket: ${insertResult['error']!.message}');
      } else {
        print('Ticket $ticketId booked successfully!');
      }
    } catch (e) {
      print('Error saving ticket: $e');
    }
  }

  Future<void> deductTotalFareFromWallet(double totalFare) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User ID is null');
      }

      final updateResult = await supabaseClient
          .from('wallet')
          .update({
            'balance': walletBalance - totalFare,
          })
          .eq('user_id', userId)
          .single();

      if (updateResult['error'] != null) {
        print(
            'Error deducting total fare from wallet: ${updateResult['error']!.message}');
      } else {
        print('Wallet balance updated successfully after ticket booking.');
        setState(() {
          walletBalance -= totalFare;
        });
      }
    } catch (e) {
      print('Error deducting total fare from wallet: $e');
    }
  }

  Future<void> saveTicketsToDatabase() async {
    double totalFare =
        widget.numberOfTickets * 20.0; // Assuming fixed price per ticket

    if (walletBalance < totalFare) {
      // Show low balance message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Low balance! Please top up your wallet.')),
      );
      return;
    }

    try {
      await deductTotalFareFromWallet(totalFare);

      for (String ticketId in ticketIds) {
        await saveTicketToDatabase(ticketId);
      }

      await updateBookedSeats();
    } catch (e) {
      print('Error saving tickets: $e');
    }
  }

  Future<void> updateBookedSeats() async {
    try {
      final response = await supabaseClient
          .from('buses')
          .update({
            'booked_seats': widget.bookedSeats + widget.numberOfTickets,
          })
          .eq('bus_number', widget.busNumber)
          .single();

      if (response['error'] != null) {
        print('Error updating booked seats: ${response['error']!.message}');
        return;
      }

      await updateTicketCount(widget.busNumber, widget.numberOfTickets);

      print('Booked seats updated successfully for bus ${widget.busNumber}');
    } catch (e) {
      print('Error updating booked seats: $e');
    }
  }

  Future<void> updateTicketCount(String busNumber, int numberOfTickets) async {
    try {
      // Generate current date in 'ddMMyyyy' format
      String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());

      // Fetch existing ticket count for today
      final ticketCountResponse = await supabaseClient
          .from('ticketcount')
          .select()
          .eq('bus_number', busNumber)
          .single();

      if (ticketCountResponse['data'] == null) {
        // No existing entry, insert a new one
        await supabaseClient.from('ticketcount').insert({
          'bus_number': busNumber,
          'd$currentDate': numberOfTickets,
        });
      } else {
        // Update the existing entry
        int currentCount = ticketCountResponse['data']['d$currentDate'] ?? 0;
        int newCount = currentCount + numberOfTickets;

        await supabaseClient.from('ticketcount').update({
          'd$currentDate': newCount,
        }).eq('bus_number', busNumber);
      }

      print('Ticket count updated successfully for bus $busNumber');
    } catch (e) {
      print('Error updating ticket count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Wallet payment ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Tickets Booked: ${widget.numberOfTickets}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Ticket IDs:',
              style: TextStyle(fontSize: 18),
            ),
            Column(
              children: ticketIds
                  .map((ticketId) =>
                      Text(ticketId, style: TextStyle(fontSize: 16)))
                  .toList(),
            ),
            SizedBox(height: 20),
            isBalanceLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      await saveTicketsToDatabase();
                      // Navigate to ViewTicketPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ViewTicketPage(ticketIds: ticketIds),
                        ),
                      );
                    },
                    child: Text('Confirm Booking'),
                  ),
          ],
        ),
      ),
    );
  }
}
