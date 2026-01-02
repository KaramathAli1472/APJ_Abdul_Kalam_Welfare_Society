import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class RegistrationFormScreen extends StatefulWidget {
  const RegistrationFormScreen({super.key});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController motherController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController transactionIdController = TextEditingController();
  
  // Variables
  String? gender;
  DateTime? selectedDate;
  File? _image;
  bool _isLoading = false;
  String? registrationNumber;
  int _currentStep = 0;
  bool _paymentMade = false;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  
  // Step titles
  final List<String> _stepTitles = ['Personal Info', 'Education', 'Contact', 'Payment'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserDataFromGoogle();
    });
  }

  void _loadUserDataFromGoogle() {
    final user = _auth.currentUser;
    
    if (user != null) {
      print('=== GOOGLE USER DATA LOADING ===');
      
      // Email auto-fill
      if (user.email != null && emailController.text.isEmpty) {
        emailController.text = user.email!;
      }
      
      // Name auto-fill
      if (user.displayName != null && nameController.text.isEmpty) {
        nameController.text = user.displayName!;
      }
    } else {
      print('⚠️ No user logged in');
    }
  }

  // Generate Registration Number
  String _generateRegistrationNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
    return 'APJ$year$month$day$random';
  }

  // Select Date of Birth
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  // Pick Image from Gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _image = File(image.path));
  }

  // Upload Image to Firebase Storage
  Future<String> _uploadImage() async {
    if (_image == null) return '';
    
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('User not authenticated for image upload');
        return '';
      }
      
      final storageRef = FirebaseStorage.instance.ref()
          .child('student_photos')
          .child('${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_image!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  // Show Error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      )
    );
  }

  // Show Success
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      )
    );
  }

  // Show QR Code Dialog
  void _showQRCodeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.qr_code, color: Colors.green.shade700),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Scan QR Code to Pay',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.currency_rupee, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Registration Fee: ₹200',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/qr_code.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade100,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.qr_code, size: 80, color: Colors.grey.shade400),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'QR Code Image',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'UPI ID (For Manual Payment)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              'apjwelfare@upi',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.yellow.shade300),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📋 Payment Instructions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('1. Open Google Pay, PhonePe or any UPI app'),
                      Text('2. Tap on "Scan QR Code"'),
                      Text('3. Point camera at the QR code above'),
                      Text('4. Pay exact amount: ₹200'),
                      Text('5. Note down Transaction ID after payment'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() => _paymentMade = true);
                          _showSuccess('Please enter Transaction ID after payment.');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'I have Paid',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Validate current step
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (nameController.text.isEmpty) { _showError('Please enter full name'); return false; }
        if (gender == null) { _showError('Please select gender'); return false; }
        if (selectedDate == null) { _showError('Please select date of birth'); return false; }
        if (fatherController.text.isEmpty) { _showError('Please enter father\'s name'); return false; }
        if (motherController.text.isEmpty) { _showError('Please enter mother\'s name'); return false; }
        return true;
      case 1:
        if (schoolController.text.isEmpty) { _showError('Please enter school name'); return false; }
        if (gradeController.text.isEmpty) { _showError('Please enter grade/class'); return false; }
        return true;
      case 2:
        if (phoneController.text.isEmpty || phoneController.text.length < 10) { 
          _showError('Please enter valid phone number'); 
          return false; 
        }
        
        final currentUser = _auth.currentUser;
        final email = currentUser?.email ?? emailController.text;
        if (email.isEmpty || !email.contains('@')) { 
          _showError('Please enter valid email address'); 
          return false; 
        }
        
        if (addressController.text.isEmpty) { 
          _showError('Please enter address'); 
          return false; 
        }
        return true;
      default: return true;
    }
  }

  // ✅✅✅ SUBMIT FORM FIXED ✅✅✅
  Future<void> _submitForm() async {
    print('=== SUBMIT FORM STARTED ===');
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showError('Please login to submit form.');
      return;
    }

    if (!_validateAllSteps()) return;
    
    if (transactionIdController.text.isEmpty) {
      _showError('Please enter Transaction ID');
      return;
    }

    setState(() => _isLoading = true);

    try {
      registrationNumber = _generateRegistrationNumber();
      final uploadedPhotoUrl = await _uploadImage();
      
      final freshUser = _auth.currentUser;
      if (freshUser == null) {
        _showError('Session expired. Please login again.');
        setState(() => _isLoading = false);
        return;
      }

      if (selectedDate == null) {
        _showError('Date of birth required');
        setState(() => _isLoading = false);
        return;
      }

      if (gender == null) {
        _showError('Gender required');
        setState(() => _isLoading = false);
        return;
      }

      // Save to students collection - WITH ID CARD GENERATED = TRUE
      final studentData = {
        'name': nameController.text.trim(),
        'gender': gender,
        'dob': selectedDate!.toIso8601String(),
        'fatherName': fatherController.text.trim(),
        'motherName': motherController.text.trim(),
        'school': schoolController.text.trim(),
        'grade': gradeController.text.trim(),
        'phone': phoneController.text.trim(),
        'whatsapp': whatsappController.text.isEmpty ? phoneController.text.trim() : whatsappController.text.trim(),
        'email': freshUser.email ?? emailController.text.trim(),
        'address': addressController.text.trim(),
        'photoUrl': uploadedPhotoUrl,
        'registrationNumber': registrationNumber,
        'transactionID': transactionIdController.text.trim(),
        'paymentStatus': 'verified',
        'userId': freshUser.uid,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'status': 'active',
        'idCardGenerated': true, // ✅ ID CARD GENERATED
        'loginMethod': freshUser.providerData.isNotEmpty 
            ? freshUser.providerData[0].providerId 
            : 'email',
      };

      await FirebaseFirestore.instance
          .collection('students')
          .doc(freshUser.uid)
          .set(studentData, SetOptions(merge: true));

      // Save to admin panel
      final adminData = {
        'name': nameController.text.trim(),
        'registrationNumber': registrationNumber,
        'phone': phoneController.text.trim(),
        'email': freshUser.email ?? emailController.text.trim(),
        'school': schoolController.text.trim(),
        'grade': gradeController.text.trim(),
        'paymentStatus': 'verified',
        'transactionID': transactionIdController.text.trim(),
        'photoUrl': uploadedPhotoUrl,
        'userId': freshUser.uid,
        'registrationDate': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'status': 'active',
        'loginMethod': freshUser.providerData.isNotEmpty 
            ? freshUser.providerData[0].providerId 
            : 'email',
      };

      await FirebaseFirestore.instance
          .collection('admin_panel')
          .doc(registrationNumber)
          .set(adminData);

      setState(() => _isLoading = false);
      
      // ✅ DIRECT DASHBOARD NAVIGATION
      print('✅ Registration successful! ID Card generated.');
      print('✅ Registration Number: $registrationNumber');
      print('➡️ Navigating to dashboard...');
      
      _showSuccess('Registration completed! ID Card generated.');
      
      // Direct dashboard navigation
      Navigator.pushReplacementNamed(context, '/dashboard');
      
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error: ${e.toString()}');
    }
  }

  // Validate all steps
  bool _validateAllSteps() {
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      _showError('Please login to submit form.');
      return false;
    }

    if (nameController.text.isEmpty) {
      setState(() => _currentStep = 0);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _showError('Please enter full name');
      return false;
    }
    if (gender == null) {
      setState(() => _currentStep = 0);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _showError('Please select gender');
      return false;
    }
    if (selectedDate == null) {
      setState(() => _currentStep = 0);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _showError('Please select date of birth');
      return false;
    }
    if (fatherController.text.isEmpty) {
      setState(() => _currentStep = 0);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _showError('Please enter father\'s name');
      return false;
    }
    if (motherController.text.isEmpty) {
      setState(() => _currentStep = 0);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _showError('Please enter mother\'s name');
      return false;
    }
    
    if (schoolController.text.isEmpty) {
      setState(() => _currentStep = 1);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _showError('Please enter school name');
      return false;
    }
    if (gradeController.text.isEmpty) {
      setState(() => _currentStep = 1);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _showError('Please enter grade/class');
      return false;
    }
    
    if (phoneController.text.isEmpty || phoneController.text.length < 10) {
      setState(() => _currentStep = 2);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _showError('Please enter valid phone number');
      return false;
    }
    
    final email = currentUser.email ?? emailController.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _currentStep = 2);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _showError('Please enter valid email address');
      return false;
    }
    
    if (addressController.text.isEmpty) {
      setState(() => _currentStep = 2);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _showError('Please enter address');
      return false;
    }
    
    return true;
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1 && _validateCurrentStep()) {
      setState(() => _currentStep++);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    nameController.dispose(); fatherController.dispose(); motherController.dispose();
    schoolController.dispose(); gradeController.dispose(); phoneController.dispose();
    whatsappController.dispose(); emailController.dispose(); addressController.dispose();
    transactionIdController.dispose(); _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'), 
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (currentUser != null)
            Tooltip(
              message: 'Logged in as ${currentUser.email}',
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    currentUser.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading ? _buildLoader() : Column(children: [
        _buildStepper(),
        Expanded(child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Form(
              key: _formKey, 
              child: Column(children: [
                // User info banner
                if (currentUser != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: currentUser.providerData.any((userInfo) => 
                          userInfo.providerId == 'google.com') 
                        ? Colors.blue.shade50 
                        : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: currentUser.providerData.any((userInfo) => 
                            userInfo.providerId == 'google.com') 
                          ? Colors.blue.shade200 
                          : Colors.green.shade200
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_circle, 
                          color: currentUser.providerData.any((userInfo) => 
                              userInfo.providerId == 'google.com') 
                            ? Colors.blue 
                            : Colors.green
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${currentUser.providerData.any((userInfo) => userInfo.providerId == 'google.com') ? '👤 Google User:' : '📧 Email User:'} ${currentUser.email}',
                                style: TextStyle(
                                  fontSize: 14, 
                                  color: currentUser.providerData.any((userInfo) => 
                                      userInfo.providerId == 'google.com') 
                                    ? Colors.blue 
                                    : Colors.green
                                ),
                              ),
                              if (currentUser.displayName != null && currentUser.displayName!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Name: ${currentUser.displayName}',
                                    style: TextStyle(
                                      fontSize: 12, 
                                      color: Colors.grey.shade700
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                _buildStepContent(),
                const SizedBox(height: 40),
                _buildNavigationButtons(),
              ])
            ),
          ),
        )),
      ]),
    );
  }

  Widget _buildLoader() {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50))),
        const SizedBox(height: 20),
        Text('Submitting Registration...', style: TextStyle(color: Colors.grey.shade600)),
      ],
    ));
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_stepTitles.length, (index) {
          final isActive = _currentStep >= index;
          return Expanded(child: Column(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                border: Border.all(color: _currentStep == index ? const Color(0xFF4CAF50) : Colors.transparent),
              ),
              child: Icon(_getStepIcon(index), size: 20, color: isActive ? Colors.white : Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              _stepTitles[index], 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: _currentStep == index ? FontWeight.bold : FontWeight.normal,
                color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
              ),
            ),
          ]));
        })
      ),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0: return Icons.person;
      case 1: return Icons.school;
      case 2: return Icons.contact_phone;
      case 3: return Icons.payment;
      default: return Icons.check;
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildPersonalInfoStep();
      case 1: return _buildEducationStep();
      case 2: return _buildContactStep();
      case 3: return _buildPaymentStep();
      default: return Container();
    }
  }

  Widget _buildNavigationButtons() {
    final currentUser = _auth.currentUser;
    
    return Row(children: [
      if (_currentStep > 0) Expanded(child: OutlinedButton(
        onPressed: _previousStep,
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.arrow_back, size: 20), 
          SizedBox(width: 8), 
          Text('Previous'),
        ]),
      )),
      if (_currentStep > 0) const SizedBox(width: 12),
      Expanded(child: ElevatedButton(
        onPressed: _currentStep == _stepTitles.length - 1 
          ? (currentUser == null ? () => _showError('Please login to submit form.') : _submitForm)
          : _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: _currentStep == _stepTitles.length - 1 ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            _currentStep == _stepTitles.length - 1 
              ? (currentUser == null ? 'Login Required' : 'Submit Registration') 
              : 'Next', 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
          ),
          if (_currentStep < _stepTitles.length - 1) const SizedBox(width: 8),
          if (_currentStep < _stepTitles.length - 1) const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
        ]),
      )),
    ]);
  }

  Widget _buildPersonalInfoStep() {
    final currentUser = _auth.currentUser;
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Column(children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: _image != null 
                ? FileImage(_image!)
                : (currentUser?.photoURL != null 
                    ? NetworkImage(currentUser!.photoURL!) as ImageProvider
                    : null),
            child: _image == null && currentUser?.photoURL == null 
                ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey) 
                : null,
          ),
        ),
        TextButton.icon(
          onPressed: _pickImage, 
          icon: const Icon(Icons.cloud_upload), 
          label: const Text('Upload Photo')
        ),
        const SizedBox(height: 20),
      ])),
      _buildTextField(nameController, 'Full Name', Icons.person, true),
      const SizedBox(height: 16),
      const Text('Gender *', style: TextStyle(color: Colors.grey)),
      Row(children: ['Male', 'Female', 'Other'].map((text) => Expanded(child: _genderButton(text))).toList()),
      const SizedBox(height: 16),
      const Text('Date of Birth *', style: TextStyle(color: Colors.grey)),
      InkWell(
        onTap: _selectDate,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300), 
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today), 
            const SizedBox(width: 12),
            Expanded(child: Text(
              selectedDate == null ? 'Select Date of Birth' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              style: TextStyle(color: selectedDate == null ? Colors.grey.shade500 : Colors.black),
            )),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      _buildTextField(fatherController, "Father's Name", Icons.person, true),
      const SizedBox(height: 16),
      _buildTextField(motherController, "Mother's Name", Icons.person, true),
    ]);
  }

  Widget _genderButton(String text) {
    final isSelected = gender == text;
    return InkWell(
      onTap: () => setState(() => gender = text),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300),
        ),
        child: Center(child: Text(
          text, 
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade700
          )
        )),
      ),
    );
  }

  Widget _buildEducationStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Educational Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Enter your current educational information', style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 32),
      _buildTextField(schoolController, 'School Name', Icons.school, true),
      const SizedBox(height: 20),
      _buildTextField(gradeController, 'Grade/Class', Icons.grade, true),
    ]);
  }

  Widget _buildContactStep() {
    final currentUser = _auth.currentUser;
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Contact Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('We\'ll use this information to contact you', style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 32),
      _buildTextField(phoneController, 'Phone Number', Icons.phone, true, TextInputType.phone),
      const SizedBox(height: 20),
      _buildTextField(whatsappController, 'WhatsApp (optional)', Icons.chat, false, TextInputType.phone),
      const SizedBox(height: 20),
      _buildTextField(
        emailController, 
        'Email Address', 
        Icons.email, 
        true, 
        TextInputType.emailAddress, 
        currentUser?.email, 
        currentUser?.email != null
      ),
      const SizedBox(height: 20),
      const Text('Address *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
        controller: addressController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Enter your complete address', 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
      ),
    ]);
  }

  Widget _buildPaymentStep() {
    final currentUser = _auth.currentUser;
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Payment Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Complete your registration by making the payment', style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 32),
      _buildTextField(
        transactionIdController, 
        'Transaction ID', 
        Icons.receipt_long, 
        true,
        null, 
        null, 
        false, 
        'Enter UTR/Transaction number'
      ),
      const SizedBox(height: 20),
      
      // Pay Now button
      if (!_paymentMade)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: currentUser == null 
              ? () => _showError('Please login to make payment.')
              : _showQRCodeDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: currentUser == null ? Colors.grey : Colors.green, 
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(Icons.qr_code, color: Colors.white, size: 26),
            label: Text(
              currentUser == null ? 'Login Required' : 'Pay Now (₹200)', 
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ),
        ),
      
      if (!_paymentMade) const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.shade50, 
          borderRadius: BorderRadius.circular(16), 
          border: Border.all(color: Colors.green.shade200)
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Payment Process:', style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _paymentMade ? Colors.green.shade50 : Colors.yellow.shade50, 
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _paymentMade ? Colors.green.shade300 : Colors.yellow.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentUser == null)
                  const Text(
                    '⚠️ Please login to access payment options.',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  )
                else if (_paymentMade)
                  const Text(
                    '✅ QR Code scanned successfully!',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  )
                else
                  const Text(
                    '📱 Click "Pay Now" to view QR code',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 8),
                Text(
                  currentUser == null
                    ? 'You need to be logged in to make payment.'
                    : (_paymentMade 
                        ? 'Now enter the Transaction ID above and submit form.' 
                        : 'Scan QR code with any UPI app and pay ₹200.'),
                  style: TextStyle(color: currentUser == null ? Colors.orange : (_paymentMade ? Colors.green : Colors.orange)),
                ),
              ],
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    bool required,
    [TextInputType? keyboardType, 
    String? initialValue, 
    bool readOnly = false, 
    String? hintText]
  ) {
    if (initialValue != null && controller.text.isEmpty) {
      controller.text = initialValue;
    }
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label${required ? ' *' : ''}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: required ? (value) => value == null || value.isEmpty ? 'Required field' : null : null,
      ),
    ]);
  }
}