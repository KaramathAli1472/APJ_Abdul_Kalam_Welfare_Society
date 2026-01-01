import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  
  // Wakelock variable
  bool _isWakeLockEnabled = false;

  @override
  void initState() {
    super.initState();
    print('🚀 Login Screen Loaded');
    _initWakeLock();
  }

  // Initialize Wakelock
  void _initWakeLock() async {
    try {
      _isWakeLockEnabled = await WakelockPlus.enabled;
      print(_isWakeLockEnabled 
          ? '🔆 WakeLock Enabled by Default' 
          : '🌙 WakeLock Disabled by Default');
    } catch (e) {
      print('⚠️ Wakelock initialization error: $e');
    }
  }

  // Toggle Wakelock
  void _toggleWakeLock(bool value) async {
    setState(() {
      _isWakeLockEnabled = value;
    });
    
    try {
      if (value) {
        await WakelockPlus.enable();
        print('🔆 WakeLock ENABLED - Screen will stay on');
      } else {
        await WakelockPlus.disable();
        print('🌙 WakeLock DISABLED - Screen can sleep');
      }
    } catch (e) {
      print('⚠️ Wakelock toggle error: $e');
    }
  }

  // Regular Login Function
  void _signInWithEmail() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    if (email.isEmpty) {
      _showErrorDialog('Please enter your email');
      return;
    }
    
    if (password.isEmpty) {
      _showErrorDialog('Please enter your password');
      return;
    }
    
    if (!email.contains('@') || !email.contains('.')) {
      _showErrorDialog('Please enter a valid email address');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      
      print('📧 Regular Login Successful!');
      print('✅ Email: $email');
      print('🔑 Password Length: ${password.length} characters');
      
      // Here you would typically call your authentication API
      // For now, we'll just navigate to dashboard
      Navigator.pushReplacementNamed(context, '/register');
    });
  }

  // Google Sign In Function
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      print('🔄 Starting Google Sign In Process...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser != null) {
        // Google user details
        final email = googleUser.email;
        final name = googleUser.displayName;
        final photoUrl = googleUser.photoUrl;
        final id = googleUser.id;
        
        print('✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅');
        print('✅ GOOGLE SIGN IN SUCCESSFUL! ✅');
        print('✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅');
        print('👤 Name: $name');
        print('📧 Email: $email');
        print('🆔 User ID: $id');
        print('🖼️ Photo URL: $photoUrl');
        print('--------------------------------------------------');
        
        // Success - navigate to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        print('❌ Google Sign In Cancelled by User');
        _showSnackBar('Sign in cancelled');
      }
    } catch (error) {
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      print('❌ GOOGLE SIGN IN ERROR!');
      print('❌ Error Details: $error');
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      _showErrorDialog('Google sign in failed: $error');
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  // Forget Password Function
  void _forgetPassword() {
    showDialog(
      context: context,
      barrierDismissible: true, // Screen band karne dega
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to reset password:'),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('❌ Password reset cancelled');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              print('📧 Password reset link requested');
              _showSnackBar('Password reset link sent to your email');
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  // Error Dialog Function
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true, // Screen band karne dega
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              print('⚠️ Error dialog closed');
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // SnackBar Function
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    
    // Optional: Disable wakelock when screen is disposed
    if (_isWakeLockEnabled) {
      WakelockPlus.disable();
      print('🌙 WakeLock Disabled on screen dispose');
    }
    
    print('👋 Login Screen Disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Top Space Reduced
                const SizedBox(height: 05),
                
                // Logo - Circle shape
Center(
  child: Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.2),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
      border: Border.all(
        color: Colors.blue[100]!,
        width: 2,
      ),
    ),
    child: Center(
      child: ClipOval(
        child: Image.asset(
          'assets/images/school_logo.png',
          width: 90,
          height: 90,
          fit: BoxFit.contain,
        ),
      ),
    ),
  ),
),
                
                // Title - Upper position
                const SizedBox(height: 10),
                const Column(
                  children: [
                    Text(
                      'A.P.J Abdul Kalam Welfare Society',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 0.2,
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.blue),
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(color: Colors.blue),
                    hintText: 'student@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 10),
                
                // Password Field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outlined, color: Colors.blue),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible 
                            ? Icons.visibility_outlined 
                            : Icons.visibility_off_outlined,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.blue),
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: !_isPasswordVisible,
                ),
                
                const SizedBox(height: 05),
                
                // Forget Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgetPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 05),
                
                // Login Button - Different color for regular login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: Colors.green.withOpacity(0.3),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'SIGN IN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // OR Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        'OR SIGN IN WITH',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                
                // Google Sign In Button - Different style
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                      elevation: 2,
                      shadowColor: Colors.red.withOpacity(0.2),
                    ),
                    child: _isGoogleLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.red,
                              strokeWidth: 3,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                child: Image.network(
                                  'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'SIGN IN WITH GOOGLE',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // WakeLock Toggle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Switch(
                        value: _isWakeLockEnabled,
                        onChanged: _toggleWakeLock,
                        activeColor: Colors.blue,
                        activeTrackColor: Colors.blue[200],
                      ),
                      const SizedBox(width: 05),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isWakeLockEnabled ? 'Screen Always ON' : 'Screen Normal',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _isWakeLockEnabled ? Colors.blue : Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _isWakeLockEnabled 
                                ? 'Screen will not sleep'
                                : 'Screen can sleep normally',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 05),
                
               
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}