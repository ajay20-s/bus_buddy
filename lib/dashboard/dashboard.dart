import 'package:bus_buddy/dashboard/Fetchmessage.dart';
import 'package:bus_buddy/dashboard/kiddashboard.dart';
import 'package:bus_buddy/dashboard/rewardpage.dart';
import 'package:bus_buddy/dashboard/wallet_page.dart';
import 'package:bus_buddy/profile/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bus_details_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> busList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBusList();
  }

  void fetchBusList() async {
    try {
      final DateTime now = DateTime.now();
      final String day = DateFormat('EEEE').format(now);
      final bool isWeekend = (day == 'Saturday' || day == 'Sunday');

      final response = await supabaseClient
          .from('buses')
          .select('*')
          .order('outtime_time', ascending: true);

      setState(() {
        busList = List<Map<String, dynamic>>.from(response)
            .where(
                (bus) => bus['bus_type'] == (isWeekend ? 'weekend' : 'weekday'))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate =
        DateFormat('dd-MM-yyyy').format(now); // Format date as dd-MM-yyyy
    String day = DateFormat('EEEE').format(now);
    String greeting = 'Good Morning';

    if (now.hour >= 12 && now.hour < 18) {
      greeting = 'Good Afternoon';
    } else if (now.hour >= 18) {
      greeting = 'Good Evening';
    }

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          'Bus Buddy.',
          style:
              GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Kiddashboard()));
                },
                icon: const Image(
                  image: AssetImage('assets/images/kid.png'),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FetchMessagesPage()));
                },
                icon: const Image(
                  image: AssetImage('assets/images/text.png'),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
                icon: const Image(
                  image: AssetImage('assets/images/pro.png'),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 235, 59),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FetchMessagesPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.wallet),
              title: Text('Wallet'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WalletPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.money),
              title: Text('Rewards'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RewardsPage()));
              },
            ),
            // Add more list tiles for other menu items
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            top: MediaQuery.of(context).size.height *
                0.5, // Start yellow from half of the screen
            child: Container(
              color: Colors.yellow, // Yellow background
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      greeting,
                                      style: TextStyle(
                                          fontSize: 28,
                                          color:
                                              Color.fromARGB(255, 255, 235, 59),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                      height: 5,
                                    ),
                                    Text(
                                      'Book Tickets',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xFF3b3b3b),
                                          fontWeight: FontWeight.w900),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '$day, $formattedDate', // Display day and formatted date
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 90,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/bus1.png'),
                                        fit: BoxFit.fitHeight),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              children: busList
                                  .map(
                                    (bus) => GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BusDetailsPage(
                                              bus: bus,
                                              bookedSeats:
                                                  bus['booked_seats'] ?? 0,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'From: ${bus['from_location']}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Departure Time: ${bus['outtime_time']}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'To: ${bus['to_location']}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
