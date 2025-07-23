import 'package:flutter/material.dart';
import 'package:bus_buddy/loginpage.dart';
import 'package:bus_buddy/signup_screen.dart';

class welcomescreen extends StatelessWidget {
  const welcomescreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              Color.fromARGB(255, 255, 223, 0),
              Color.fromARGB(255, 255, 255, 102),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              child: Image(
                image: AssetImage('assets/images/bus1.png'),
                height: 150,
              ),
            ),
            Text(
              'Bus_buddy',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                shadows: [
                  Shadow(
                    blurRadius: 5,
                    color: Colors.yellow,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Loginpage()));
                    },
                    style: OutlinedButton.styleFrom(
                      elevation: 5,
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    child: Text('Login'),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Signupscreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                    child: Text('Sign up'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
