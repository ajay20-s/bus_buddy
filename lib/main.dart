import 'dart:async';

import 'package:bus_buddy/dashboard/dashboard.dart';
import 'package:bus_buddy/firebase_options.dart';
import 'package:bus_buddy/forget_password/otpemail.dart';
import 'package:bus_buddy/providers/app_provider.dart';
import 'package:bus_buddy/providers/themeprovider.dart';
import 'package:bus_buddy/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_buddy/loginpage.dart';
import 'package:uni_links/uni_links.dart';
//import 'theme_provider.dart'; // Import the ThemeProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  /* await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((value) => Get.put(Authenticationrepository())); */
  //SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  await Supabase.initialize(
      url: 'https://slegdqmdyihkvwjvtpva.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsZWdkcW1keWloa3Z3anZ0cHZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE5NzAyNTgsImV4cCI6MjAyNzU0NjI1OH0.B6rB3CiBZq0dZMtj93de_2GPWi3WYTqhhgl_d_Q62-k');
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

/*class Core extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    );
    /* MultiProvider(
        providers: AppProviders.providers, child: const MyApp());*/
  }
}*/

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  Future<void> initUniLinks() async {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.queryParameters.containsKey('token')) {
        String token = uri.queryParameters['token']!;
        String email = uri.queryParameters['email']!;
        if (token.isNotEmpty && email.isNotEmpty) {
          // Navigate to the reset password page with the token and email
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Otpemail(email: email),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      routes: {
        '/dashboard': (context) => const Dashboard(),
        // Add other routes here
      },
      home: const Splash(),
    );
  }
}
