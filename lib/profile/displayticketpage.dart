import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DisplayTicketPage extends StatefulWidget {
  final int ticketId;
  final String busNumber;

  DisplayTicketPage({required this.ticketId, required this.busNumber});

  @override
  _DisplayTicketPageState createState() => _DisplayTicketPageState();
}

class _DisplayTicketPageState extends State<DisplayTicketPage> {
  final String supabaseUrl =
      'https://slegdqmdyihkvwjvtpva.supabase.co'; // Replace with your Supabase URL
  final String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsZWdkcW1keWloa3Z3anZ0cHZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE5NzAyNTgsImV4cCI6MjAyNzU0NjI1OH0.B6rB3CiBZq0dZMtj93de_2GPWi3WYTqhhgl_d_Q62-k'; // Replace with your Supabase anon key

  late Map<String, dynamic> busDetails;
  late String qrCodeImage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBusDetails();
    fetchQRCodeImage();
  }

  Future<void> fetchBusDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$supabaseUrl/rest/v1/buses?select=from_location,to_location,outtime_time&bus_number=eq.${widget.busNumber}'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      print('Bus Details Response status: ${response.statusCode}');
      print('Bus Details Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            busDetails = data[0];
          });
        } else {
          print('Bus details not found for bus number: ${widget.busNumber}');
        }
      } else {
        print('Failed to fetch bus details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching bus details: $e');
    }
  }

  Future<void> fetchQRCodeImage() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$supabaseUrl/rest/v1/qrcodes?select=qr_code_image&or=(id.ilike.*${widget.ticketId % 100})'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      print('QR Code Response status: ${response.statusCode}');
      print('QR Code Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            qrCodeImage = data[0]['qr_code_image'];
            isLoading = false;
          });
        } else {
          setState(() {
            qrCodeImage = '';
            isLoading = false;
          });
          print('QR code not found for ticket ID: ${widget.ticketId}');
        }
      } else {
        print('Failed to fetch QR code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching QR code: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text('Display Ticket'),
          // backgroundColor: Colors.amber,
          ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'Ticket ID: ${widget.ticketId}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (qrCodeImage.isNotEmpty)
                        Center(
                          child: Image.memory(
                            base64Decode(qrCodeImage),
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Center(child: Text('No QR Code available')),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Bus Number: ${widget.busNumber}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (busDetails != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From: ${busDetails['from_location']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'To: ${busDetails['to_location']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Outtime: ${busDetails['outtime_time']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
