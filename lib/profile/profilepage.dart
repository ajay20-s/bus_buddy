import 'package:bus_buddy/dashboard/dashboard.dart';
import 'package:bus_buddy/loginpage.dart';
import 'package:bus_buddy/profile/booked_tickets.dart';
import 'package:bus_buddy/profile/update_profilescreen.dart';
import 'package:bus_buddy/providers/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profilemenuwidget.dart';
//import 'theme_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  String profileName = 'Loading...';
  String profileEmail = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchProfileDetails();
  }

  void fetchProfileDetails() async {
    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      try {
        final response = await supabaseClient
            .from('users')
            .select('username, email')
            .eq('auth_id', user.id)
            .limit(1) // Limit to one row
            .single();

        if (response != null) {
          setState(() {
            profileName = response['username'];
            profileEmail = response['email'];
          });
        } else {
          print('No data found for user with ID: ${user.id}');
        }
      } catch (e) {
        print('Error fetching profile details: $e');
      }
    } else {
      print('Current user is null');
    }
  }

  void updateProfileDetails(String newName, String newEmail) {
    setState(() {
      profileName = newName;
      profileEmail = newEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Redirect to the dashboard page
            Navigator.pop(context);
          },
          icon: const Icon(Icons.keyboard_arrow_left),
        ),
        title: Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Switch.adaptive(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              final provider =
                  Provider.of<ThemeProvider>(context, listen: false);
              provider.toggleTheme(value);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image(
                    image: AssetImage('assets/images/profile.png'),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                profileName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                profileEmail,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateProfileScreen(),
                    ),
                  ).then((value) {
                    if (value != null) {
                      String newName = value['name'];
                      String newEmail = value['email'];
                      updateProfileDetails(newName, newEmail);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 215, 197, 36),
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 30),
              const Divider(),
              SizedBox(height: 10),
              // Menu
              ProfileMenuWidget(
                title: 'Settings',
                icon: Icons.settings,
                onpress: () {},
              ),
              ProfileMenuWidget(
                title: 'Booked Tickets',
                icon: Icons.wallet,
                onpress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookedTicketsPage(),
                    ),
                  );
                },
              ),
              ProfileMenuWidget(
                title: 'User Management',
                icon: Icons.supervised_user_circle_sharp,
                onpress: () {},
              ),
              const Divider(),
              ProfileMenuWidget(
                title: 'Information',
                icon: Icons.info,
                onpress: () {},
              ),
              ProfileMenuWidget(
                title: 'Logout',
                icon: Icons.settings,
                endIcon: false,
                onpress: () {
                  supabaseClient.auth.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Loginpage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.onpress,
    required this.icon,
    this.endIcon = true,
    this.textcolor,
  }) : super(key: key);
  final String title;
  final IconData icon;
  final VoidCallback onpress;
  final bool endIcon;
  final Color? textcolor;

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    var iconColor = isDark ? Colors.green : Colors.yellow;

    return ListTile(
      onTap: onpress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.blue.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: Colors.blueAccent,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: endIcon
          ? Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color:
                    const Color.fromARGB(255, 108, 130, 147).withOpacity(0.1),
              ),
              child: Icon(
                Icons.keyboard_arrow_right,
                color: const Color.fromARGB(255, 116, 131, 156),
              ),
            )
          : null,
    );
  }
}
