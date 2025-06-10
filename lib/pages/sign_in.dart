import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_vise/pages/sign_up.dart';
import 'package:grade_vise/screens/mobile_screen.dart';
import 'package:grade_vise/services/firebase_auth_methods.dart';

import 'package:grade_vise/utils/colors.dart';
import 'package:grade_vise/utils/fonts.dart';
import 'package:grade_vise/utils/show_error.dart';
import 'package:grade_vise/widgets/custom_button.dart';
import 'package:grade_vise/widgets/custom_textfeild.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignUpState();
}

class _SignUpState extends State<SignIn> with TickerProviderStateMixin {
  // Controllers for the animations
  late AnimationController _textController;
  late AnimationController _drawerController;
  late AnimationController _contentController;

  // Animations
  late Animation<Offset> _textSlideAnimation;
  late Animation<Offset> _drawerSlideAnimation;
  late Animation<double> _contentOpacityAnimation;

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Text animation controller - first animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Drawer animation controller - second animation
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Content animation controller - third animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Text slide animation
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Drawer slide animation - comes from bottom to top
    _drawerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _drawerController, curve: Curves.easeOut),
    );

    // Content opacity animation
    _contentOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    // Start animations in sequence
    _textController.forward().then((_) {
      _drawerController.forward().then((_) {
        _contentController.forward();
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _drawerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSignIn(BuildContext context, String email, String pass) async {
    String user = await FirebaseAuthMethods(
      FirebaseAuth.instance,
    ).signInUser(context, email, pass);

    if (user == 'success') {
      // Only navigate after sign-in is complete
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MobileScreen()),
      );
    } else {
      debugPrint("Sign-in failed!");
    }
  }

  void handleSignIn() async {
    User? user =
        await FirebaseAuthMethods(FirebaseAuth.instance).signInWithGoogle();

    if (user != null) {
      // Only navigate after sign-in is complete
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MobileScreen()),
        );
      }
    } else {
      debugPrint("Sign-in failed!");
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            // Animated title with slide effect
            SlideTransition(
              position: _textSlideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Grade Vise",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                    fontFamily: sourceSans,
                  ),
                ),
              ),
            ),
            // Animated subtitle with slide effect
            SlideTransition(
              position: _textSlideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Text(
                  "Sign In",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontFamily: sourceSans,
                  ),
                ),
              ),
            ),

            // Drawer animation coming from bottom
            Expanded(
              child: SlideTransition(
                position: _drawerSlideAnimation,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(45),
                      topLeft: Radius.circular(45),
                    ),
                    color: Colors.white,
                  ),
                  child: FadeTransition(
                    opacity: _contentOpacityAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.06,
                            ),

                            CustomTextfeild(
                              hintText: "Email address",
                              isObute: false,
                              controller: email,
                            ),
                            const SizedBox(height: 25),
                            CustomTextfeild(
                              hintText: "Password",
                              isObute: true,
                              controller: password,
                            ),

                            const SizedBox(height: 40),
                            CustomButton(
                              onPressed: () {
                                if (email.text.isEmpty || email.text.isEmpty) {
                                  showSnakbar(
                                    context,
                                    'please enter the detais',
                                  );
                                } else {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  _handleSignIn(
                                    context,
                                    email.text.trim(),
                                    password.text.trim(),
                                  );

                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              text: "Sign In",
                              color: bgColor,
                              isLoading: isLoading,
                            ),

                            const SizedBox(height: 20),

                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    "Or",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 20),

                            InkWell(
                              onTap: () {
                                setState(() {
                                  isLoading = true;
                                });

                                handleSignIn();

                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      221,
                                      190,
                                      186,
                                      186,
                                    ),
                                  ),
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/google.png'),
                                    const SizedBox(width: 15),

                                    isLoading
                                        ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                        : Text(
                                          "Continue to Google",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: sourceSans,
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            GestureDetector(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUp(),
                                    ),
                                  ),
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: sourceSans,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Sign Up",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.copyWith(
                                        color: bgColor,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: sourceSans,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
