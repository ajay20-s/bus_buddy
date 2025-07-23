import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_buddy/snackbar_extension.dart';

class Otpemail extends StatefulWidget {
  final String email;

  const Otpemail({required this.email, Key? key}) : super(key: key);

  @override
  _OtpemailState createState() => _OtpemailState();
}

class _OtpemailState extends State<Otpemail> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController passwordController;
  late TextEditingController confirmPwdController;

  @override
  void initState() {
    passwordController = TextEditingController();
    confirmPwdController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPwdController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String password = passwordController.text.trim();

      try {
        // Update the user's password using the token
        await supabaseClient.auth.updateUser(UserAttributes(
          password: password,
        ));

        context.showSnackbar(
          message: 'Password has been reset successfully.',
          backgroundColor: Colors.green,
        );

        Navigator.pop(context);
      } catch (e) {
        print('Error: $e'); // Debugging: print error
        // Handle any exceptions that occur during the API call
        context.showSnackbar(
          message:
              'An error occurred while resetting the password. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!RegExp(r'^(?=.*?[0-9]).{6,}$').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
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
        title: Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Reset Password for ${widget.email}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    label: Text('Password'),
                    hintText: 'Enter new password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: validatePassword,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: confirmPwdController,
                  decoration: InputDecoration(
                    label: Text('Confirm Password'),
                    hintText: 'Re-enter new password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: resetPassword,
                    child: Text('Reset Password'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
