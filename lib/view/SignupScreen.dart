import 'package:chat_app1/view/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _auth = FirebaseAuth.instance;

  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  // Animation controller
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  // Additional animations for form elements
  late List<Animation<Offset>> _formFieldAnimations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    // Animations for form fields with staggered effect
    _formFieldAnimations = List.generate(
      3,
      (index) => Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.3 + (index * 0.1),
            0.8 + (index * 0.1),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to validate the sign-up form
  void _submitForm() {
    setState(() {
      _emailError = '';
      _passwordError = '';
      _confirmPasswordError = '';
    });

    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

  print(email);
  print(password);
    bool isValid = true;

    // Validate Email
    // if (email.isEmpty) {
    //   setState(() {
    //     _emailError = 'Please enter your email';
    //   });
    //   isValid = false;
    // } else if (!RegExp(
    //   r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    // ).hasMatch(email)) {
    //   setState(() {
    //     _emailError = 'Please enter a valid email address';
    //   });
    //   isValid = false;
    // }

    // Validate Password
    bool isValidPassword = RegExp(
      r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    ).hasMatch(password);

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Please enter your password';
      });
      isValid = false;
    } else if (!isValidPassword) {
      setState(() {
        _passwordError =
            'Password must be at least 8 characters, include one \nuppercase letter, one special character, and one number';
      });
      isValid = false;
    }

    // Validate Confirm Password
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Please confirm your password';
      });
      isValid = false;
    } else if (password != confirmPassword) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      isValid = false;
    }

    if (isValid) {
      // Create bounce animation effect on successful validation
      // _animateButtonSuccess();

      _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((userCredential) {
            // Signed up successfully
            var user = userCredential.user;
            print("User signed up: ${user?.uid}");
          })
          .catchError((error) {
            print("Signup error: ${error.message}");
          });

      // Navigate to profile screen with user data after animation completes
      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return Placeholder();
            },
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              // Hero-like transition
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.95,
                    end: 1.0,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
    }
  }

  void _animateButtonSuccess() {
    // Create a button press animation effect
    AnimationController buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    buttonController.forward().then((_) {
      buttonController.reverse().then((_) {
        buttonController.dispose();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                const SizedBox(height: 96),
                // App logo with rotation animation
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: const Center(
                    child: Text("", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Text(
                    "Create a new account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Form fields with staggered slide animations
                SlideTransition(
                  position: _formFieldAnimations[0],
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _emailError.isNotEmpty
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.transparent,
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          label: const Text(
                            "Email",
                            style: TextStyle(color: Colors.grey),
                          ),
                          prefixIcon: const Icon(Icons.mail),
                          errorText: _emailError.isEmpty ? null : _emailError,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ),
                ),
                SlideTransition(
                  position: _formFieldAnimations[1],
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _passwordError.isNotEmpty
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.transparent,
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: passwordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          label: const Text(
                            "Password",
                            style: TextStyle(color: Colors.grey),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          errorText:
                              _passwordError.isEmpty ? null : _passwordError,
                        ),
                      ),
                    ),
                  ),
                ),
                SlideTransition(
                  position: _formFieldAnimations[2],
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _confirmPasswordError.isNotEmpty
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.transparent,
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: confirmPasswordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          label: const Text(
                            "Confirm Password",
                            style: TextStyle(color: Colors.grey),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          errorText:
                              _confirmPasswordError.isEmpty
                                  ? null
                                  : _confirmPasswordError,
                        ),
                      ),
                    ),
                  ),
                ),
                // Animated buttons
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32.0, 8, 32, 0),
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black,
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        fixedSize: const Size(548, 32),
                      ),
                      child: const Text("Sign Up"),
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32.0, 10, 32, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const LoginScreen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 1.0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 500,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        fixedSize: const Size(548, 32),
                      ),
                      child: const Text("Login"),
                    ),
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
