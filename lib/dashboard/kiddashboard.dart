import 'package:bus_buddy/dashboard/Fetchmessage.dart';
import 'package:bus_buddy/dashboard/dashboard.dart';
import 'package:bus_buddy/dashboard/kiddashboard.dart';
import 'package:bus_buddy/dashboard/rewardpage.dart';
import 'package:bus_buddy/dashboard/wallet_page.dart';
import 'package:bus_buddy/profile/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bus_details_page.dart';

class Kiddashboard extends StatefulWidget {
  const Kiddashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Kiddashboard> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> busList = [];
  bool isLoading = true;
  String message = '';

  @override
  void initState() {
    super.initState();
    fetchBusList();
  }

  void fetchBusList() async {
    try {
      final DateTime now = DateTime.now();
      final String day = DateFormat('EEEE').format(now);

      if (day == 'Sunday') {
        setState(() {
          message = 'Today there are no school buses available.';
          isLoading = false;
        });
        return; // Skip fetching buses on Sunday
      }

      final response = await supabaseClient
          .from('buses')
          .select('*')
          .order('outtime_time', ascending: true);

      setState(() {
        busList = List<Map<String, dynamic>>.from(response)
            .where((bus) => bus['bus_type'] == 'school')
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
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
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
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/sclbus.png', // Replace with your image asset path
              height: 30,
            ),
            const SizedBox(width: 10),
            Text(
              'Bus Buddy - Kids',
              style: GoogleFonts.bangers(fontSize: 24, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
        actions: [
          Row(
            children: [
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
                color: Colors.teal,
              ),
              child: Text(
                'Menu',
                style: GoogleFonts.bangers(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.teal),
              title: Text('Home', style: GoogleFonts.fredoka()),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.teal),
              title: Text('Profile', style: GoogleFonts.fredoka()),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: Colors.teal),
              title: Text('Messages', style: GoogleFonts.fredoka()),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FetchMessagesPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.wallet, color: Colors.teal),
              title: Text('Wallet', style: GoogleFonts.fredoka()),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WalletPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.money, color: Colors.teal),
              title: Text('Rewards', style: GoogleFonts.fredoka()),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RewardsPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: Colors.teal),
              title: Text('Dashboard', style: GoogleFonts.fredoka()),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Dashboard()));
              },
            ),
            // Add more list tiles for other menu items
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              color: Colors.lightBlueAccent,
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : message.isNotEmpty
                  ? Center(
                      child: Text(message,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.bold)))
                  : SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          greeting,
                                          style: GoogleFonts.bangers(
                                              fontSize: 28,
                                              color: Colors.teal,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Book Tickets',
                                          style: GoogleFonts.fredoka(
                                              fontSize: 20,
                                              color: Colors.deepOrange,
                                              fontWeight: FontWeight.w900),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '$day, $formattedDate',
                                          style: GoogleFonts.fredoka(
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
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              child: busList.isEmpty
                                  ? Center(
                                      child: Text('No buses available',
                                          style: GoogleFonts.fredoka(
                                              fontSize: 18,
                                              color: Colors.black)))
                                  : Column(
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
                                                          bus['booked_seats'] ??
                                                              0,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 6,
                                                      offset: Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Bus No: ${bus['bus_number']}',
                                                          style: GoogleFonts
                                                              .fredoka(
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .blueGrey),
                                                        ),
                                                        Text(
                                                          'From: ${bus['from_location']}',
                                                          style: GoogleFonts
                                                              .fredoka(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black87),
                                                        ),
                                                        Text(
                                                          'To: ${bus['to_location']}',
                                                          style: GoogleFonts
                                                              .fredoka(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black87),
                                                        ),
                                                        Text(
                                                          'Departure: ${bus['outtime_time']}',
                                                          style: GoogleFonts
                                                              .fredoka(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black87),
                                                        ),
                                                      ],
                                                    ),
                                                    Icon(Icons.arrow_forward,
                                                        color: Colors.teal),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
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
