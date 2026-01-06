import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isWakeLockEnabled = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    print('🚀 Login Screen Loaded');
    _initWakeLock();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('savedEmail');
      final savedPassword = prefs.getString('savedPassword');
      final rememberMe = prefs.getBool('rememberMe') ?? false;
      
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
      
      if (savedPassword != null && savedPassword.isNotEmpty) {
        _passwordController.text = savedPassword;
      }
      
      setState(() {
        _rememberMe = rememberMe;
      });
      
      print('📝 Loaded saved credentials');
      
    } catch (e) {
      print('⚠️ Error loading saved credentials: $e');
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_rememberMe) {
        await prefs.setString('savedEmail', email);
        await prefs.setString('savedPassword', password);
        await prefs.setBool('rememberMe', true);
        print('💾 Credentials saved');
      } else {
        await prefs.remove('savedEmail');
        await prefs.remove('savedPassword');
        await prefs.setBool('rememberMe', false);
        print('🗑️ Credentials cleared');
      }
    } catch (e) {
      print('⚠️ Error saving credentials: $e');
    }
  }

  void _initWakeLock() async {
    try {
      _isWakeLockEnabled = await WakelockPlus.enabled;
    } catch (e) {
      print('⚠️ Wakelock initialization error: $e');
    }
  }

  void _toggleWakeLock(bool value) async {
    setState(() {
      _isWakeLockEnabled = value;
    });
    
    try {
      if (value) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (e) {
      print('⚠️ Wakelock toggle error: $e');
    }
  }

  // ✅ SIMPLE GOOGLE SIGN IN
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      print('🔄 Starting Google Sign In...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Google Sign In cancelled');
        setState(() { _isGoogleLoading = false; });
        return;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      
      if (user != null) {
        print('✅ Google Sign In Successful!');
        print('👤 Name: ${user.displayName}');
        print('📧 Email: ${user.email}');
        print('🆔 UID: ${user.uid}');
        
        // Save login status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', user.email ?? '');
        await prefs.setString('userName', user.displayName ?? '');
        await prefs.setString('userId', user.uid);
        await prefs.setString('loginMethod', 'google');
        
        // Save photo
        String profilePhotoUrl = user.photoURL ?? 
            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
        await prefs.setString('userPhoto', profilePhotoUrl);
        
        // Check if user needs registration
        await _checkUserRegistration(user.email!, user.uid);
      }
      
    } catch (error) {
      print('❌ Google Sign In Error: $error');
      _showSnackBar('Google Sign In failed. Please try again.');
      setState(() { _isGoogleLoading = false; });
    }
  }

  // ✅ SIMPLE CHECK USER REGISTRATION
  Future<void> _checkUserRegistration(String email, String userId) async {
    try {
      print('🔍 Checking registration for: $email');
      
      final firestore = FirebaseFirestore.instance;
      
      // Check if this is a student email
      if (email.endsWith('@apj.org') && email.startsWith('s')) {
        print('🎓 Student email detected - going to dashboard');
        _goToDashboard();
        return;
      }
      
      // For parent/guardian - check in Firestore
      QuerySnapshot query = await firestore
          .collection('students')
          .where('parentUserId', isEqualTo: userId)
          .limit(1)
          .get();
      
      print('📊 Query results: ${query.docs.length}');
      
      if (query.docs.isNotEmpty) {
        print('✅ User found in Firestore - going to dashboard');
        _goToDashboard();
      } else {
        print('❌ User not found - going to registration');
        _goToRegistration(email, userId);
      }
      
    } catch (e) {
      print('⚠️ Error checking registration: $e');
      // On error, go to registration
      _goToRegistration(email, userId);
    } finally {
      setState(() {
        _isGoogleLoading = false;
        _isLoading = false;
      });
    }
  }

  // ✅ EMAIL LOGIN
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
    
    // Save credentials
    _saveCredentials(email, password);
    
    // Check if student email
    if (email.endsWith('@apj.org') && email.startsWith('s')) {
      print('🎓 Student email login');
      _handleStudentLogin(email, password);
    } else {
      _handleRegularLogin(email, password);
    }
  }

  // ✅ STUDENT LOGIN
  Future<void> _handleStudentLogin(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userId', user.uid);
        await prefs.setString('loginMethod', 'email');
        await prefs.setString('accountType', 'student');
        
        print('✅ Student login successful');
        _goToDashboard();
      }
      
    } catch (error) {
      print('❌ Student login error: $error');
      setState(() { _isLoading = false; });
      
      if (error.toString().contains('invalid-credential') || 
          error.toString().contains('wrong-password')) {
        _showErrorDialog('Invalid email or password');
      } else {
        _showErrorDialog('Login failed. Please try again.');
      }
    }
  }

  // ✅ REGULAR LOGIN
  Future<void> _handleRegularLogin(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userId', user.uid);
        await prefs.setString('loginMethod', 'email');
        await prefs.setString('accountType', 'parent');
        
        print('✅ Email login successful');
        await _checkUserRegistration(email, user.uid);
      }
      
    } catch (error) {
      print('❌ Email login error: $error');
      setState(() { _isLoading = false; });
      _showErrorDialog('Login failed. Please check your credentials.');
    }
  }

  // ✅ GO TO DASHBOARD
  void _goToDashboard() {
    print('✅ Going to dashboard...');
    
    _showSnackBar('Welcome back!');
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
          _isLoading = false;
        });
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }

  // ✅ GO TO REGISTRATION
  void _goToRegistration(String email, String userId) {
    print('📝 Going to registration form...');
    
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setString('registerEmail', email);
      await prefs.setString('firebaseUid', userId);
    });
    
    _showSnackBar('Please complete registration');
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
          _isLoading = false;
        });
        Navigator.pushReplacementNamed(context, '/register');
      }
    });
  }

  void _forgetPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to reset password:'),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              controller: TextEditingController(text: _emailController.text),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = _emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                _showErrorDialog('Please enter a valid email');
                return;
              }
              
              _auth.sendPasswordResetEmail(email: email).then((_) {
                Navigator.pop(context);
                _showSnackBar('Password reset link sent to $email');
              }).catchError((error) {
                Navigator.pop(context);
                _showErrorDialog('Failed to send reset email. Please try again.');
              });
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('Error', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                const SizedBox(height: 20),
                
                // Logo
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
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.school,
                              size: 50,
                              color: Colors.blue,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
                const Column(
                  children: [
                    Text(
                      'A.P.J Abdul Kalam Welfare Society',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
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
                    hintText: 'student@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                ),
                
                const SizedBox(height: 10),
                
                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                        ),
                        const Text('Remember Me'),
                      ],
                    ),
                    TextButton(
                      onPressed: _forgetPassword,
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Login Button
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
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'SIGN IN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // OR Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text('OR SIGN IN WITH'),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Google Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                    child: _isGoogleLoading
                        ? const CircularProgressIndicator(color: Colors.red)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'SIGN IN WITH GOOGLE',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // WakeLock
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Switch(
                        value: _isWakeLockEnabled,
                        onChanged: _toggleWakeLock,
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Screen Always ON',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Prevent screen sleep',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
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