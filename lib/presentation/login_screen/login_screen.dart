import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:road_map_v2/core/app_export.dart';
import 'package:road_map_v2/provider/auth_provider.dart';
import 'package:road_map_v2/widgets/custom_elevated_button.dart';
import 'package:road_map_v2/widgets/custom_text_form_field.dart';
import 'package:provider/provider.dart'; // Import your AuthProvider class

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // State variable to manage loading state

  @override
  Widget build(BuildContext context) {
    AuthenticationProvider authProvider =
        Provider.of<AuthenticationProvider>(context);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLoginForm(context),
                  SizedBox(height: 30.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: CustomTextFormField(
                      controller: emailController,
                      hintText: "E-mail",
                      textInputType: TextInputType.emailAddress,
                      prefix: Container(
                        margin: EdgeInsets.fromLTRB(18.0, 10.0, 21.0, 10.0),
                        child: CustomImageView(
                          imagePath: ImageConstant.imgImage1,
                          height: 30.0,
                          width: 34.0,
                        ),
                      ),
                      prefixConstraints: BoxConstraints(maxHeight: 50.0),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: CustomTextFormField(
                      controller: passwordController,
                      hintText: "Password",
                      textInputAction: TextInputAction.done,
                      textInputType: TextInputType.visiblePassword,
                      obscureText: true,
                      prefix: Container(
                        margin: EdgeInsets.fromLTRB(18.0, 10.0, 21.0, 10.0),
                        child: CustomImageView(
                          imagePath: ImageConstant.imgImage2,
                          height: 34.0,
                          width: 34.0,
                          color: Colors.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }

                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: _isLoading
                        ? SizedBox(
                            width: 30,
                            child:
                                CircularProgressIndicator()) // Show circular progress if loading
                        : CustomElevatedButton(
                            text: "Login",
                            onPressed: () {
                              setState(() {
                                _isLoading = true; // Set loading state to true
                              });
                              _signInWithEmailAndPassword(
                                  context, authProvider);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 65.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
        color: Colors.grey[200],
      ),
      child: Column(
        children: [
          SizedBox(height: 27.0),
          CustomImageView(
            imagePath: ImageConstant.imgLogoooooooooooo,
            height: 222.0,
            width: 222.0,
          ),
        ],
      ),
    );
  }

  void _signInWithEmailAndPassword(
      BuildContext context, AuthenticationProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = await authProvider.signInWithEmailAndPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        if (user != null) {
          // If login is successful, navigate to the desired screen
          Navigator.pushNamed(context, AppRoutes.homepageContainerScreen);
        } else {
          // Handle login failure
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to sign in. Please check your credentials.'),
          ));
        }
      } catch (e) {
        // Handle errors here
        print("Error signing in: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ));
      } finally {
        setState(() {
          _isLoading = false; // Set loading state to false
        });
      }
    }
  }
}
