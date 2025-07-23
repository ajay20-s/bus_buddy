import 'package:bus_buddy/dashboard/viewticket.dart';
import 'package:flutter/material.dart';

class Busview extends StatelessWidget {
  final Map<String, dynamic> bus;

  const Busview({Key? key, required this.bus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: GestureDetector(
        onTap: () {
          /* Navigator.push(
              context, MaterialPageRoute(builder: (context) => ViewTicketPage())
              );*/
        },
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 229, 202, 202),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.directions_bus,
                size: 60,
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bus['from']['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        bus['outtime_time'],
                      ),
                      Text(
                        bus['to']['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
