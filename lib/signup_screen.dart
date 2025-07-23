import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotrue/gotrue.dart';
import 'package:bus_buddy/loginpage.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<Signupscreen> {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  bool isloading = false;
  late TextEditingController emailcontroller;
  late TextEditingController passwordcontroller;
  late TextEditingController confirmPwdController;
  late TextEditingController fullnamecontroller;
  bool _obscurePassword = true; // Initially password is obscured

  @override
  void initState() {
    emailcontroller = TextEditingController();
    passwordcontroller = TextEditingController();
    confirmPwdController = TextEditingController();
    fullnamecontroller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    confirmPwdController.dispose();
    fullnamecontroller.dispose();
    super.dispose();
  }

  void signUp() async {
    setState(() {
      isloading = true;
    });
    try {
      final user = await supabaseClient.auth.signUp(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
        data: {
          'username': fullnamecontroller.text.trim().toLowerCase(),
        },
      );

      final authUserId = user.user?.id;

      // Insert user data into 'users' table after signup
      await supabaseClient.from('users').insert([
        {
          'auth_id': authUserId,
          'email': emailcontroller.text.trim(),
          'username': fullnamecontroller.text.trim().toLowerCase(),
          'type': "nothost",
        }
      ]);

      setState(() {
        isloading = false;
      });

      navigatetologinPage();
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isloading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isloading = false;
      });
    }
  }

  void navigatetologinPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const Loginpage()));
  }

  void togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _formkey = GlobalKey<FormState>();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    image: AssetImage('assets/images/bus1.png'),
                    height: size.height * 0.2,
                  ),
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    'make it work, make it right, make it faster',
                    style: TextStyle(
                        fontWeight: FontWeight.w400, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Form(
                  key: _formkey,
                  child: Container(
                    padding: EdgeInsets.symmetric(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isloading) ...[
                          const Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        ],
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: fullnamecontroller,
                          decoration: InputDecoration(
                              label: Text('Full name'),
                              prefixIcon: Icon(Icons.person_outline_rounded),
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.black))),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Full name is empty";
                            }
                            final isValid =
                                RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(value);
                            if (!isValid) {
                              return 'Full name must be 3-24 characters long with alphanumeric or underscore';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: emailcontroller,
                          decoration: InputDecoration(
                              label: Text('Email'),
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.black))),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is empty";
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: passwordcontroller,
                          obscureText:
                              _obscurePassword, // Obscure password by default
                          decoration: InputDecoration(
                              label: Text('Password'),
                              prefixIcon: Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.black,
                                ),
                                onPressed: togglePasswordVisibility,
                              ),
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.black))),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is required";
                            }
                            if (value.length < 6) {
                              return 'Password length must be 6 characters or more';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: confirmPwdController,
                          obscureText:
                              _obscurePassword, // Obscure confirm password by default
                          decoration: InputDecoration(
                              label: Text('Confirm Password'),
                              prefixIcon: Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.black,
                                ),
                                onPressed: togglePasswordVisibility,
                              ),
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.black))),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Confirm Password is required";
                            }
                            if (value != passwordcontroller.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                            onPressed: isloading
                                ? null
                                : () {
                                    if (_formkey.currentState!.validate()) {
                                      signUp();
                                    }
                                  },
                            child: Text('Sign up'))
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text('OR'),
                  TextButton(
                      onPressed: () {
                        navigatetologinPage();
                      },
                      child: Text.rich(TextSpan(children: [
                        TextSpan(text: 'Already have an Account? '),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ])))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
