import 'package:bus_buddy/dashboard/cashondelivery.dart';
import 'package:bus_buddy/dashboard/upipaymentpage.dart';
import 'package:flutter/material.dart';

class ChoosePaymentPage extends StatelessWidget {
  final String busNumber;
  final String fromLocation;
  final String toLocation;
  final String outTime;
  final int numberOfTickets;
  final int bookedSeats;
  final int farePerTicket = 20;

  ChoosePaymentPage({
    required this.busNumber,
    required this.fromLocation,
    required this.toLocation,
    required this.outTime,
    required this.numberOfTickets,
    required this.bookedSeats,
  });

  int calculateTotalFare() {
    return numberOfTickets * farePerTicket;
  }

  void redirectToCashOnDelivery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CashOnDeliveryPage(
          busNumber: busNumber,
          numberOfTickets: numberOfTickets,
          bookedSeats: bookedSeats,
        ),
      ),
    );
  }

  void redirectToUPIPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UPIPaymentPage(
          totalFare: numberOfTickets * farePerTicket,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalFare = calculateTotalFare();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose Payment',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
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
                          Text(
                            'Bus Number: $busNumber',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 40, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text(
                            'From: $fromLocation',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Icon(Icons.flag, size: 40, color: Colors.greenAccent),
                          SizedBox(width: 10),
                          Text(
                            'To: $toLocation',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 40, color: Colors.orangeAccent),
                          SizedBox(width: 10),
                          Text(
                            'Out Time: $outTime',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Icon(Icons.event_seat,
                              size: 40, color: Colors.purpleAccent),
                          SizedBox(width: 10),
                          Text(
                            'Number of Tickets: $numberOfTickets',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Icon(Icons.confirmation_number,
                              size: 40, color: Colors.tealAccent),
                          SizedBox(width: 10),
                          Text(
                            'Total Fare: $totalFare Rs',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  redirectToCashOnDelivery(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Wallet',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  redirectToUPIPayment(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'UPI Payment',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
