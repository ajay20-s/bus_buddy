import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UPIPaymentPage extends StatefulWidget {
  final int totalFare;

  UPIPaymentPage({required this.totalFare});

  @override
  _UPIPaymentPageState createState() => _UPIPaymentPageState();
}

class _UPIPaymentPageState extends State<UPIPaymentPage> {
  final TextEditingController upiIdController = TextEditingController();

  Future<void> onContinuePressed() async {
    String upiId = upiIdController.text;
    if (upiId.isNotEmpty) {
      String upiUrl =
          'upi://pay?pa=$upiId&pn=Your%20Name&am=${widget.totalFare}&cu=INR&tn=Payment';

      if (await canLaunch(upiUrl)) {
        await launch(upiUrl);
        showPaymentSuccessMessage();
      } else {
        print('Could not launch $upiUrl');
      }
    } else {
      print('UPI ID is empty');
    }
  }

  void showPaymentSuccessMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Successful'),
          content: Text('Your payment was completed successfully.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UPI Payment Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter UPI ID:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: upiIdController,
                decoration: InputDecoration(
                  labelText: 'UPI ID',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onContinuePressed,
                child: Text('Pay ${widget.totalFare} Rs'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
