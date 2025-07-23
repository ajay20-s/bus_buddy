import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddBusPage extends StatefulWidget {
  @override
  _AddBusPageState createState() => _AddBusPageState();
}

class _AddBusPageState extends State<AddBusPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController busNumberController;
  late TextEditingController fromLocationController;
  late TextEditingController toLocationController;
  late TextEditingController outTimeController;
  late TextEditingController totalSeatsController;
  late TextEditingController busTypeController;

  @override
  void initState() {
    busNumberController = TextEditingController();
    fromLocationController = TextEditingController();
    toLocationController = TextEditingController();
    outTimeController = TextEditingController();
    totalSeatsController = TextEditingController();
    busTypeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    busNumberController.dispose();
    fromLocationController.dispose();
    toLocationController.dispose();
    outTimeController.dispose();
    totalSeatsController.dispose();
    busTypeController.dispose();
    super.dispose();
  }

  Future<void> addBus() async {
    if (_formKey.currentState!.validate()) {
      final busNumber = busNumberController.text;
      final fromLocation = fromLocationController.text;
      final toLocation = toLocationController.text;
      final outTime = outTimeController.text;
      final totalSeats = int.tryParse(totalSeatsController.text);
      final busType = busTypeController.text;

      try {
        await supabaseClient.from('buses').insert({
          'bus_number': busNumber,
          'from_location': fromLocation,
          'to_location': toLocation,
          'outtime_time': outTime,
          'total_seats': totalSeats,
          'bus_type': busType,
        });
        context.showSnackbar(
          message: 'Bus added successfully!',
          backgroundColor: Colors.green,
        );
        Navigator.pop(context);
      } on AuthException catch (e) {
        context.showSnackbar(
          message: 'Error: ${e.message}',
          backgroundColor: Colors.red,
        );
      } catch (e) {
        context.showSnackbar(
          message: 'An error occurred: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Bus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: busNumberController,
                decoration: InputDecoration(labelText: 'Bus Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the bus number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: fromLocationController,
                decoration: InputDecoration(labelText: 'From Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the from location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: toLocationController,
                decoration: InputDecoration(labelText: 'To Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the to location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: outTimeController,
                decoration: InputDecoration(labelText: 'Out Time (HH:MM:SS)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the out time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: totalSeatsController,
                decoration: InputDecoration(labelText: 'Total Seats'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the total seats';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: busTypeController,
                decoration: InputDecoration(labelText: 'Bus Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the bus type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addBus,
                child: Text('Add Bus'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension SnackbarExtension on BuildContext {
  void showSnackbar({
    required String message,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
