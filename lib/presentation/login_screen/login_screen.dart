import 'package:flutter/material.dart';
import 'package:road_map_v2/core/app_export.dart';
import 'package:road_map_v2/widgets/custom_elevated_button.dart';
import 'package:road_map_v2/widgets/custom_text_form_field.dart';

// ignore_for_file: must_be_immutable
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
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Form(
                        key: _formKey,
                        child: SizedBox(
                            width: double.maxFinite,
                            child: Column(children: [
                              _buildLoginForm(context),
                              SizedBox(height: 107.v),
                              Padding(
                                  padding:
                                      EdgeInsets.only(left: 25.h, right: 26.h),
                                  child: CustomTextFormField(
                                      controller: emailController,
                                      hintText: "E-mail",
                                      textInputType: TextInputType.emailAddress,
                                      prefix: Container(
                                          margin: EdgeInsets.fromLTRB(
                                              18.h, 10.v, 21.h, 10.v),
                                          child: CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgImage1,
                                              height: 30.v,
                                              width: 34.h)),
                                      prefixConstraints:
                                          BoxConstraints(maxHeight: 50.v))),
                              SizedBox(height: 30.v),
                              Padding(
                                  padding:
                                      EdgeInsets.only(left: 25.h, right: 26.h),
                                  child: CustomTextFormField(
                                      controller: passwordController,
                                      hintText: "Password",
                                      textInputAction: TextInputAction.done,
                                      textInputType:
                                          TextInputType.visiblePassword,
                                      obscureText: true)),
                              SizedBox(height: 67.v),
                              CustomElevatedButton(
                                  text: "Login",
                                  margin:
                                      EdgeInsets.only(left: 25.h, right: 26.h),
                                  onPressed: () {
                                    onTapLogin(context);
                                  }),
                              SizedBox(height: 5.v)
                            ])))))));
  }

  Widget _buildLoginForm(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 74.h, vertical: 65.v),
            decoration: AppDecoration.outlineBlack.copyWith(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 27.v),
                  CustomImageView(
                      imagePath: ImageConstant.imgLogoooooooooooo,
                      height: 222.adaptSize,
                      width: 222.adaptSize)
                ])));
  }

  /// Navigates to the homepageContainerScreen when the action is triggered.
  onTapLogin(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.mapScreen);
  }
}
