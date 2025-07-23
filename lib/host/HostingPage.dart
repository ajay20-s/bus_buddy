import 'package:bus_buddy/host/Addbus.dart';
import 'package:bus_buddy/host/Changebustimings.dart';
import 'package:bus_buddy/host/Messages.dart';
import 'package:bus_buddy/host/deletebuspage.dart';
import 'package:bus_buddy/host/showticketpage.dart';
import 'package:bus_buddy/host/viewbuses.dart';
import 'package:flutter/material.dart';

class HostingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hosting Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OptionButton(
              title: 'Add Bus',
              onTap: () {
                // Navigate to the Add Bus page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddBusPage()),
                );
              },
            ),
            OptionButton(
              title: 'Messages',
              onTap: () {
                // Navigate to the Messages page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessagesPage()),
                );
              },
            ),
            OptionButton(
              title: 'View Buses',
              onTap: () {
                // Navigate to the View Buses page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewBusesPage()),
                );
              },
            ),
            OptionButton(
              title: 'Delete Bus',
              onTap: () {
                // Navigate to the View Buses page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteBusPage()),
                );
              },
            ),
            OptionButton(
              title: 'Tickets', // New option for Tickets
              onTap: () {
                // Navigate to the Show Tickets page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShowTicketsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Map<String, dynamic>? bus; // Optional bus parameter

  const OptionButton({
    required this.title,
    required this.onTap,
    this.bus, // Initialize with null by default
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
