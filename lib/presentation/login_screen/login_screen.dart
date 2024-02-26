import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:road_map_v2/core/app_export.dart';
import 'package:road_map_v2/widgets/custom_elevated_button.dart';
import 'package:road_map_v2/widgets/custom_text_form_field.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          width: SizeUtils.width,
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
                    child: CustomElevatedButton(
                      text: "Login",
                      onPressed: () {
                        _signInWithEmailAndPassword(context);
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

  void _signInWithEmailAndPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        // If login is successful, navigate to the desired screen
        Navigator.pushNamed(context, AppRoutes.appNavigationmapUser);
        //Navigator.pushNamed(context, AppRoutes.commicunication);
      } catch (e) {
        // Handle errors here
        print("Error signing in: $e");
        // You can display error messages to the user using SnackBar or showDialog
      }
    }
  }
}
