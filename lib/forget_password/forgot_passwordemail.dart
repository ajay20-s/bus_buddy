import 'package:bus_buddy/forget_password/otpemail.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_buddy/snackbar_extension.dart';

class ForgotPasswordEmail extends StatefulWidget {
  const ForgotPasswordEmail({super.key});

  @override
  _ForgotPasswordEmailState createState() => _ForgotPasswordEmailState();
}

class _ForgotPasswordEmailState extends State<ForgotPasswordEmail> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;

  @override
  void initState() {
    emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String email = emailController.text.trim();

      try {
        // Send the password reset email
        await supabaseClient.auth.resetPasswordForEmail(email);

        context.showSnackbar(
          message: 'Password reset email sent successfully.',
          backgroundColor: Colors.green,
        );
      } on AuthException catch (e) {
        if (e.statusCode == 429) {
          context.showSnackbar(
            message:
                'You have exceeded the rate limit for password reset emails. Please try again later.',
            backgroundColor: Colors.red,
          );
        } else {
          context.showSnackbar(
            message:
                'An error occurred while resetting the password. Please try again.',
            backgroundColor: Colors.red,
          );
        }
      } catch (e) {
        print(e); // Debugging: print error
        context.showSnackbar(
          message:
              'An error occurred while resetting the password. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Image(
                image: AssetImage('assets/images/forget.png'),
                height: 100,
                alignment: Alignment.topCenter,
              ),
              Text(
                'Forgot Password',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                'Select one of the options given below to reset your password.',
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 30,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        label: Text('E-Mail'),
                        hintText: 'E-Mail',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: resetPassword,
                        child: Text('Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
