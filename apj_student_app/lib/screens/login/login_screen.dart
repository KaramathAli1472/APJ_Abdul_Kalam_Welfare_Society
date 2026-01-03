import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  
  static const String _cloudName = 'drxe5e2nk';
  static const String _uploadPreset = 'students_photos';
  static const String _assetFolder = 'students';
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isWakeLockEnabled = false;

  @override
  void initState() {
    super.initState();
    print('🚀 Login Screen Loaded');
    _initWakeLock();
    _checkAutoLogin();
  }

  // ✅ FIXED: Auto login check
  Future<void> _checkAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      
      print('🔍 Auto Login Check: isLoggedIn = $isLoggedIn');
      
      if (!isLoggedIn) {
        print('❌ No auto login - User not logged in');
        return;
      }
      
      final email = prefs.getString('userEmail');
      final userId = prefs.getString('userId');
      
      print('📧 Email from prefs: $email');
      print('🆔 User ID from prefs: $userId');
      
      if (email == null || email.isEmpty) {
        print('❌ No email found');
        await prefs.setBool('isLoggedIn', false);
        return;
      }
      
      final firestore = FirebaseFirestore.instance;
      
      // Check by email first
      QuerySnapshot emailQuery = await firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      DocumentSnapshot? userDoc;
      Map<String, dynamic>? userData;
      
      if (emailQuery.docs.isNotEmpty) {
        userDoc = emailQuery.docs.first;
        userData = userDoc.data() as Map<String, dynamic>;
        print('✅ Found user by email');
      } 
      // If not found by email, check by Firebase UID
      else if (userId != null) {
        QuerySnapshot uidQuery = await firestore
            .collection('students')
            .where('firebaseUid', isEqualTo: userId)
            .limit(1)
            .get();
        
        if (uidQuery.docs.isNotEmpty) {
          userDoc = uidQuery.docs.first;
          userData = userDoc.data() as Map<String, dynamic>;
          print('✅ Found user by Firebase UID');
        }
      }
      
      if (userData != null) {
        final regNumber = userData['registrationNumber']?.toString();
        final isRegistered = userData['isRegistered'] ?? false;
        
        print('🔢 Registration Number: $regNumber');
        print('📝 isRegistered: $isRegistered');
        
        if (regNumber != null && regNumber.isNotEmpty && isRegistered) {
          print('✅ User fully registered, redirecting to dashboard');
          
          // Save all user data to SharedPreferences
          await prefs.setString('userId', userDoc!.id);
          await prefs.setString('registrationNumber', regNumber);
          await prefs.setString('fullName', userData['fullName']?.toString() ?? '');
          await prefs.setString('phone', userData['phone']?.toString() ?? '');
          await prefs.setString('course', userData['course']?.toString() ?? '');
          await prefs.setString('userPhoto', userData['profilePhoto']?.toString() ?? '');
          await prefs.setString('userEmail', userData['email']?.toString() ?? email);
          await prefs.setBool('isRegistered', true);
          await prefs.setString('firebaseUid', userData['firebaseUid']?.toString() ?? '');
          
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else {
          print('⚠️ User not fully registered, clearing login');
          await prefs.clear();
        }
      } else {
        print('❌ User not found in Firestore, clearing login');
        await prefs.clear();
      }
    } catch (e) {
      print('⚠️ Auto login error: $e');
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

  Future<String?> _uploadToCloudinary(String imageUrl, {String? fileName}) async {
    try {
      print('☁️ Uploading image to Cloudinary...');
      
      if (imageUrl.contains('cloudinary.com')) {
        print('✅ Image is already from Cloudinary');
        return imageUrl;
      }
      
      if (imageUrl.contains('blank-profile-picture')) {
        print('📸 Using default profile picture');
        return imageUrl;
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicId = 'student_${timestamp}_${fileName ?? 'profile'}';
      
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      
      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = _assetFolder
        ..fields['public_id'] = publicId;
      
      try {
        final imageResponse = await http.get(Uri.parse(imageUrl));
        if (imageResponse.statusCode == 200) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              imageResponse.bodyBytes,
              filename: 'profile_$timestamp.jpg',
            ),
          );
        } else {
          print('❌ Failed to download image from URL');
          return imageUrl;
        }
      } catch (e) {
        print('❌ Error downloading image: $e');
        request.fields['file'] = imageUrl;
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final secureUrl = data['secure_url'];
        print('✅ Image uploaded to Cloudinary successfully!');
        return secureUrl;
      } else {
        print('❌ Cloudinary upload failed: ${response.statusCode}');
        return imageUrl;
      }
      
    } catch (e) {
      print('❌ Cloudinary upload error: $e');
      return imageUrl;
    }
  }

  // ✅ FIXED: Google Sign In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      print('🔄 Starting Google Sign In Process...');
      
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
        
        // Handle profile photo
        String? profilePhotoUrl = user.photoURL;
        String cloudinaryPhotoUrl = '';
        
        if (profilePhotoUrl == null || profilePhotoUrl.isEmpty) {
          print('📸 No profile photo from Google, using default');
          profilePhotoUrl = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
          cloudinaryPhotoUrl = profilePhotoUrl;
        } else {
          final fileName = user.email?.split('@').first ?? 'profile';
          final cloudinaryUrl = await _uploadToCloudinary(profilePhotoUrl, fileName: fileName);
          cloudinaryPhotoUrl = cloudinaryUrl ?? profilePhotoUrl;
        }
        
        // ✅ Save login status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', user.email ?? '');
        await prefs.setString('userName', user.displayName ?? '');
        await prefs.setString('userPhoto', cloudinaryPhotoUrl);
        await prefs.setString('userId', user.uid);
        await prefs.setString('loginMethod', 'google');
        
        // ✅ IMPORTANT: Save user info in Firestore (Temporary until registration)
        await _saveOrUpdateUserInFirestore(
          email: user.email!,
          uid: user.uid,
          name: user.displayName ?? '',
          photoUrl: cloudinaryPhotoUrl,
        );
        
        // Now check registration status
        await _checkRegistrationAndNavigate(
          email: user.email!,
          userId: user.uid,
          photoUrl: cloudinaryPhotoUrl,
        );
      }
      
    } catch (error) {
      print('❌ Google Sign In Error: $error');
      _showSnackBar('Google Sign In failed. Please try again.');
      setState(() { _isGoogleLoading = false; });
    }
  }

  // ✅ FIXED: Email Sign In
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
    
    _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).then((userCredential) async {
      print('✅ Email Login Successful!');
      final user = userCredential.user;
      
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userId', user.uid);
        await prefs.setString('loginMethod', 'email');
        
        final defaultPhoto = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
        await prefs.setString('userPhoto', defaultPhoto);
        
        await _checkRegistrationAndNavigate(
          email: email,
          userId: user.uid,
          photoUrl: defaultPhoto,
        );
      }
      
    }).catchError((error) {
      print('❌ Email Login Error: $error');
      _showErrorDialog('Login failed. Please check your credentials.');
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  // ✅ FIXED: Save or update user in Firestore
  Future<void> _saveOrUpdateUserInFirestore({
    required String email,
    required String uid,
    required String name,
    required String photoUrl,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Check if user already exists by email
      QuerySnapshot emailQuery = await firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      // Check if user already exists by Firebase UID
      QuerySnapshot uidQuery = await firestore
          .collection('students')
          .where('firebaseUid', isEqualTo: uid)
          .limit(1)
          .get();
      
      Map<String, dynamic> userData = {
        'email': email,
        'firebaseUid': uid,
        'fullName': name,
        'profilePhoto': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        'loginMethod': 'google',
      };
      
      if (emailQuery.docs.isNotEmpty) {
        // Update existing user
        await emailQuery.docs.first.reference.update(userData);
        print('✅ Updated existing user in Firestore');
      } else if (uidQuery.docs.isNotEmpty) {
        // Update existing user by UID
        await uidQuery.docs.first.reference.update(userData);
        print('✅ Updated existing user by UID in Firestore');
      } else {
        // Create new user
        userData['createdAt'] = FieldValue.serverTimestamp();
        userData['isRegistered'] = false;
        userData['status'] = 'pending';
        
        await firestore.collection('students').add(userData);
        print('✅ Created new user in Firestore');
      }
    } catch (e) {
      print('⚠️ Error saving user to Firestore: $e');
    }
  }

  // ✅ FIXED: Check registration status
  Future<void> _checkRegistrationAndNavigate({
    required String email,
    required String userId,
    required String photoUrl,
  }) async {
    try {
      print('🔍 Checking registration status for: $email');
      
      final firestore = FirebaseFirestore.instance;
      
      // Check by email
      QuerySnapshot emailQuery = await firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      // Check by Firebase UID
      QuerySnapshot uidQuery = await firestore
          .collection('students')
          .where('firebaseUid', isEqualTo: userId)
          .limit(1)
          .get();
      
      print('📊 Email query results: ${emailQuery.docs.length}');
      print('📊 UID query results: ${uidQuery.docs.length}');
      
      DocumentSnapshot? userDoc;
      Map<String, dynamic>? userData;
      
      if (emailQuery.docs.isNotEmpty) {
        userDoc = emailQuery.docs.first;
        userData = userDoc.data() as Map<String, dynamic>;
        print('✅ Found user by email');
      } else if (uidQuery.docs.isNotEmpty) {
        userDoc = uidQuery.docs.first;
        userData = userDoc.data() as Map<String, dynamic>;
        print('✅ Found user by UID');
      }
      
      if (userData != null) {
        final regNumber = userData['registrationNumber']?.toString();
        final isRegistered = userData['isRegistered'] ?? false;
        
        print('🔢 Registration Number: $regNumber');
        print('📝 isRegistered: $isRegistered');
        
        if (regNumber != null && regNumber.isNotEmpty && isRegistered) {
          // ✅ USER IS REGISTERED - Go to dashboard
          print('✅ User already registered, going to dashboard');
          await _saveUserToPrefs(userData, userDoc!.id, photoUrl);
          _goToDashboard(userData['fullName'] ?? '');
        } else {
          // User exists but not registered
          print('⚠️ User exists but not registered, going to registration');
          
          // Update profile photo if needed
          if (userData['profilePhoto'] == null || userData['profilePhoto'].isEmpty) {
            await userDoc!.reference.update({
              'profilePhoto': photoUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
          
          _goToRegistration(email, photoUrl, userId);
        }
      } else {
        // User not found - new user
        print('👤 New user detected, going to registration');
        _goToRegistration(email, photoUrl, userId);
      }
      
    } catch (e) {
      print('⚠️ Error checking registration: $e');
      _goToRegistration(email, photoUrl, userId);
    } finally {
      setState(() {
        _isGoogleLoading = false;
        _isLoading = false;
      });
    }
  }

  // ✅ Save user data to SharedPreferences
  Future<void> _saveUserToPrefs(Map<String, dynamic> studentData, String docId, String photoUrl) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('userId', docId);
    await prefs.setString('registrationNumber', studentData['registrationNumber']?.toString() ?? '');
    await prefs.setString('fullName', studentData['fullName']?.toString() ?? '');
    await prefs.setString('phone', studentData['phone']?.toString() ?? '');
    await prefs.setString('course', studentData['course']?.toString() ?? '');
    await prefs.setString('userPhoto', photoUrl);
    await prefs.setString('userEmail', studentData['email']?.toString() ?? '');
    await prefs.setString('firebaseUid', studentData['firebaseUid']?.toString() ?? '');
    await prefs.setBool('isRegistered', true);
    
    print('💾 User data saved to SharedPreferences');
  }

  // ✅ Go to dashboard
  void _goToDashboard(String userName) {
    print('✅ Going to dashboard...');
    
    _showSnackBar('Welcome back${userName.isNotEmpty ? ', $userName' : ''}!');
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }

  // ✅ Go to registration
  void _goToRegistration(String email, String photoUrl, String userId) {
    print('📝 Going to registration form...');
    
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setString('registerEmail', email);
      await prefs.setString('firebaseUid', userId);
      await prefs.setString('registerPhoto', photoUrl);
      await prefs.setBool('isNewUser', true);
      await prefs.setBool('isRegistered', false);
    });
    
    _showSnackBar('Please complete registration');
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
                
                const SizedBox(height: 05),
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
                
                const SizedBox(height: 03),
                
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
                
                const SizedBox(height: 05),
                
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
                
                const SizedBox(height: 3),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgetPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                
                const SizedBox(height: 05),
                
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
                
                const SizedBox(height: 10),
                
                // OR Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        'OR SIGN IN WITH',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
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
                              Container(
                                width: 24,
                                height: 24,
                                child: Image.network(
                                  'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.g_mobiledata, color: Colors.red);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'SIGN IN WITH GOOGLE',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isWakeLockEnabled
                                ? 'Screen Always ON'
                                : 'Screen Normal',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Prevent screen sleep',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ], // ✅ Column children closed
            ),
          ),
        ),
      ),
    );
  }
}

