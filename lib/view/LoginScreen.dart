import 'package:chat_app1/view/ChatScreen.dart';
import 'package:chat_app1/view/SignupScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  String _emailError = '';
  String _passwordError = '';
  bool showPw = false;
  bool checked = false;

  // Animation controllers
  late AnimationController _formAnimationController;
  late AnimationController _logoAnimationController;
  late Animation<double> _logoAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Password visibility toggle animation
  late AnimationController _iconAnimationController;
  late Animation<double> _iconRotationAnimation;

  @override
  void initState() {
    super.initState();

    // Form animation controller
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Icon animation controller
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Define animations
    _logoAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _formAnimationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formAnimationController, curve: Curves.easeIn),
    );

    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(_iconAnimationController);

    // Start animations
    _logoAnimationController.forward();
    _formAnimationController.forward();
  }

  @override
  void dispose() {
    _formAnimationController.dispose();
    _logoAnimationController.dispose();
    _iconAnimationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Function to validate the login form
  Future<void> _submitForm() async {
    setState(() {
      _emailError = '';
      _passwordError = '';
    });

    String email = emailController.text;
    String password = passwordController.text;

    bool isValid = true;

    // Validate Email
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Please enter your email';
      });
      isValid = false;
    } else if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      isValid = false;
    }

    // Regular expression for password validation
    bool isValidPassword = true;
    // bool isValidPassword = RegExp(
    //   r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_])[A-Za-z\d\W_]{8,}$',
    // ).hasMatch(password);

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

    if (isValid) {
      try {
        print("user");
        print(emailController.text.trim());
        print(passwordController.text.trim());
        print("user ${_auth.app}");

        _auth
            .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            )
            .then((user) {
              print("user asdf");
              print(user);
            });
        // print("userasdfasdfasdf");
        // print(user);
        // if (user != null) {
        //   print("Login successful: ${user.user?.email}");
        //   print("Id: ${user.user?.uid}");
        // }
      } catch (e) {
        print("Login failed: $e");
      }
      ScaffoldMessenger.of(context).clearSnackBars();

      // Animate the success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: const Text('Login Successful'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to profile screen with user data
      
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const ChatScreen(); // Replace with your profile screen
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Custom transition
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();

      // Animate the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: const Text('Please fix the errors'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      showPw = !showPw;
    });

    if (showPw) {
      _iconAnimationController.forward();
    } else {
      _iconAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 110),
            ScaleTransition(
              scale: _logoAnimation,
              child: const Center(
                child: Text("", style: TextStyle(color: Colors.white)),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Padding(
                padding: EdgeInsets.all(48.0),
                child: Text(
                  "Login to your account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Animated form fields
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Email field with animation
                    Padding(
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
                    // Password field with animation
                    Padding(
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
                          obscureText: !showPw,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            fillColor: Colors.white,
                            label: const Text(
                              "Password",
                              style: TextStyle(color: Colors.grey),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: RotationTransition(
                              turns: _iconRotationAnimation,
                              child: IconButton(
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (
                                    Widget child,
                                    Animation<double> animation,
                                  ) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    );
                                  },
                                  child: Icon(
                                    showPw
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    key: ValueKey<bool>(showPw),
                                  ),
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                            ),
                            errorText:
                                _passwordError.isEmpty ? null : _passwordError,
                          ),
                        ),
                      ),
                    ),
                    // Remember me and forgot password row with animations
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          // Animated checkbox
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Checkbox(
                              value: checked,
                              onChanged: (newVal) {
                                setState(() {
                                  checked = newVal!;
                                });
                              },
                            ),
                          ),
                          const Text(
                            "Remember me",
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          const Spacer(),
                          // Animated forgot password button
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            builder: (context, value, child) {
                              return Opacity(opacity: value, child: child);
                            },
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.blue[600]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                    // Login button with pulse animation
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.95, end: 1.0),
                      duration: const Duration(milliseconds: 2000),
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
                          child: const Text("Login"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Sign up button with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 2000),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32.0, 0, 32, 0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const SignUpScreen(),
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
                          child: const Text("Sign Up"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Hint text with animation
                    // AnimatedOpacity(
                    //   opacity: 1.0,
                    //   duration: const Duration(milliseconds: 1500),
                    //   curve: Curves.easeIn,
                    //   child: const Text(
                    //     "(Hint: Login with any valid email/password combination.)",
                    //     style: TextStyle(color: Colors.white),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
