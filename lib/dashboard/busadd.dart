/*import 'package:flutter/material.dart';
//import 'package:firebase_database/firebase_database.dart';

class BusAddPage extends StatefulWidget {
  @override
  _BusAddPageState createState() => _BusAddPageState();
}

class _BusAddPageState extends State<BusAddPage> {
  //final databaseReference = FirebaseDatabase.instance.reference();

  final TextEditingController busNumberController = TextEditingController();
  final TextEditingController startingPointController = TextEditingController();
  final TextEditingController destinationPointController =
      TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController bookedTicketsController = TextEditingController();

  String? validateBusNumber(String? value) {
    if (value == null || value.isEmpty || value.length != 6) {
      return 'Please enter a 6-digit bus number';
    }
    return null;
  }

  void addBusToFirebase() {
    databaseReference.child("buses").push().set({
      'bus_number': busNumberController.text,
      'starting_point': startingPointController.text,
      'destination_point': destinationPointController.text,
      'time': timeController.text,
      'capacity': capacityController.text,
      'booked_tickets': bookedTicketsController.text,
      'date_added': DateTime.now().toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Bus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: busNumberController,
              decoration: InputDecoration(labelText: 'Bus Number (6 digits)'),
              validator: validateBusNumber,
            ),
            TextFormField(
              controller: startingPointController,
              decoration: InputDecoration(labelText: 'Starting Point'),
            ),
            TextFormField(
              controller: destinationPointController,
              decoration: InputDecoration(labelText: 'Destination Point'),
            ),
            TextFormField(
              controller: timeController,
              decoration: InputDecoration(labelText: 'Time of the Bus'),
            ),
            TextFormField(
              controller: capacityController,
              decoration: InputDecoration(labelText: 'Capacity of the Bus'),
            ),
            TextFormField(
              controller: bookedTicketsController,
              decoration: InputDecoration(labelText: 'Booked Tickets'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (Form.of(context)!.validate()) {
                  addBusToFirebase();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bus added successfully')));
                }
              },
              child: Text('Add Bus'),
            ),
          ],
        ),
      ),
    );
  }
}
*/