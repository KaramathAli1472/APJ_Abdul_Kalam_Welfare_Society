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
  
  final User? user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  
  // Step titles
  final List<String> _stepTitles = ['Personal Info', 'Education', 'Contact', 'Payment'];

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
      final storageRef = FirebaseStorage.instance.ref()
          .child('student_photos')
          .child('${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_image!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  // Validate current step
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (nameController.text.isEmpty) return _showError('Please enter full name');
        if (gender == null) return _showError('Please select gender');
        if (selectedDate == null) return _showError('Please select date of birth');
        if (fatherController.text.isEmpty) return _showError('Please enter father\'s name');
        if (motherController.text.isEmpty) return _showError('Please enter mother\'s name');
        return true;
      case 1:
        if (schoolController.text.isEmpty) return _showError('Please enter school name');
        if (gradeController.text.isEmpty) return _showError('Please enter grade/class');
        return true;
      case 2:
        if (phoneController.text.isEmpty || phoneController.text.length < 10) return _showError('Please enter valid phone number');
        final email = user?.email ?? emailController.text;
        if (email.isEmpty || !email.contains('@')) return _showError('Please enter valid email address');
        if (addressController.text.isEmpty) return _showError('Please enter address');
        return true;
      default: return true;
    }
  }

  bool _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    return false;
  }

  // Show Payment Dialog
  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Instructions', style: TextStyle(color: Colors.green)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Registration Fee: ₹200', style: TextStyle(fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 20),
            _paymentItem('UPI ID', 'apjwelfare@upi', Icons.payment),
            _paymentItem('Bank', 'State Bank of India', Icons.account_balance),
            _paymentItem('Account', '123456789012', Icons.credit_card),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.yellow.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Text('After payment, note Transaction ID and enter it in form.', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _paymentMade = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment initiated. Please enter Transaction ID below.'), backgroundColor: Colors.green)
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('I have Paid', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _paymentItem(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ])),
      ]),
    );
  }

  // Submit Form
  Future<void> _submitForm() async {
    if (!_validateAllSteps()) return;
    if (transactionIdController.text.isEmpty) return _showError('Please enter Transaction ID');

    setState(() => _isLoading = true);

    try {
      registrationNumber = _generateRegistrationNumber();
      final uploadedPhotoUrl = await _uploadImage();
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) throw Exception('User not authenticated');
      if (selectedDate == null) throw Exception('Date of birth required');
      if (gender == null) throw Exception('Gender required');

      // Save to students collection
      await FirebaseFirestore.instance.collection('students').doc(currentUser.uid).set({
        'name': nameController.text.trim(),
        'gender': gender,
        'dob': selectedDate!.toIso8601String(),
        'fatherName': fatherController.text.trim(),
        'motherName': motherController.text.trim(),
        'school': schoolController.text.trim(),
        'grade': gradeController.text.trim(),
        'phone': phoneController.text.trim(),
        'whatsapp': whatsappController.text.isEmpty ? phoneController.text.trim() : whatsappController.text.trim(),
        'email': currentUser.email ?? emailController.text.trim(),
        'address': addressController.text.trim(),
        'photoUrl': uploadedPhotoUrl,
        'registrationNumber': registrationNumber,
        'transactionID': transactionIdController.text.trim(),
        'paymentStatus': transactionIdController.text.isEmpty ? 'pending' : 'verified',
        'userId': currentUser.uid,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'active',
        'idCardGenerated': false,
      });

      // Save to admin panel
      await FirebaseFirestore.instance.collection('admin_panel').doc(registrationNumber).set({
        'name': nameController.text.trim(),
        'registrationNumber': registrationNumber,
        'phone': phoneController.text.trim(),
        'email': currentUser.email ?? emailController.text.trim(),
        'school': schoolController.text.trim(),
        'grade': gradeController.text.trim(),
        'paymentStatus': transactionIdController.text.isEmpty ? 'pending' : 'verified',
        'transactionID': transactionIdController.text.trim(),
        'photoUrl': uploadedPhotoUrl,
        'userId': currentUser.uid,
        'registrationDate': DateTime.now().toIso8601String(),
        'status': 'new_registration',
      });

      setState(() => _isLoading = false);
      _showSuccessDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error: ${e.toString()}');
    }
  }

  // Validate all steps
  bool _validateAllSteps() {
    if (nameController.text.isEmpty) return setStepError(0, 'Please enter full name');
    if (gender == null) return setStepError(0, 'Please select gender');
    if (selectedDate == null) return setStepError(0, 'Please select date of birth');
    if (fatherController.text.isEmpty) return setStepError(0, 'Please enter father\'s name');
    if (motherController.text.isEmpty) return setStepError(0, 'Please enter mother\'s name');
    if (schoolController.text.isEmpty) return setStepError(1, 'Please enter school name');
    if (gradeController.text.isEmpty) return setStepError(1, 'Please enter grade/class');
    if (phoneController.text.isEmpty || phoneController.text.length < 10) return setStepError(2, 'Please enter valid phone number');
    final email = user?.email ?? emailController.text;
    if (email.isEmpty || !email.contains('@')) return setStepError(2, 'Please enter valid email address');
    if (addressController.text.isEmpty) return setStepError(2, 'Please enter address');
    return true;
  }

  bool setStepError(int step, String message) {
    setState(() => _currentStep = step);
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    return _showError(message);
  }

  // Success Dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 60, color: Colors.green),
              const SizedBox(height: 20),
              const Text('Registration Successful!', style: TextStyle(fontSize: 22, color: Colors.green)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  const Text('Registration Number', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(registrationNumber!, style: const TextStyle(fontSize: 24, color: Colors.blue)),
                ]),
              ),
              const SizedBox(height: 20),
              const Text('Please save this number for future reference.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Copy Number'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                  child: const Text('Dashboard', style: TextStyle(color: Colors.white)),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Student Registration'), backgroundColor: Colors.white),
      body: _isLoading ? _buildLoader() : Column(children: [
        _buildStepper(),
        Expanded(child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Form(key: _formKey, child: Column(children: [
              _buildStepContent(),
              const SizedBox(height: 40),
              Row(children: [
                if (_currentStep > 0) Expanded(child: OutlinedButton(
                  onPressed: _previousStep,
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.arrow_back, size: 20), SizedBox(width: 8), Text('Previous'),
                  ]),
                )),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: _currentStep == _stepTitles.length - 1 ? _submitForm : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentStep == _stepTitles.length - 1 ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_currentStep == _stepTitles.length - 1 ? 'Submit Registration' : 'Next'),
                    if (_currentStep < _stepTitles.length - 1) const SizedBox(width: 8),
                    if (_currentStep < _stepTitles.length - 1) const Icon(Icons.arrow_forward, size: 20),
                  ]),
                )),
              ]),
            ])),
          ),
        )),
      ]),
    );
  }

  Widget _buildLoader() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50))),
      const SizedBox(height: 20),
      Text('Submitting Registration...', style: TextStyle(color: Colors.grey.shade600)),
    ]));
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(_stepTitles.length, (index) {
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
          Text(_stepTitles[index], style: TextStyle(
            fontSize: 12, fontWeight: _currentStep == index ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
          )),
        ]));
      })),
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

  Widget _buildPersonalInfoStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Column(children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: _image != null ? FileImage(_image!) : null,
            child: _image == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey) : null,
          ),
        ),
        TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.cloud_upload), label: const Text('Upload Photo')),
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
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.calendar_today), const SizedBox(width: 12),
            Expanded(child: Text(selectedDate == null ? 'Select Date' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}')),
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
        child: Center(child: Text(text, style: TextStyle(color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade700))),
      ),
    );
  }

  Widget _buildEducationStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Educational Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Enter your current educational information', style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 32),
      _buildTextField(schoolController, 'School Name', Icons.school, true),
      const SizedBox(height: 20),
      _buildTextField(gradeController, 'Grade/Class', Icons.grade, true),
    ]);
  }

  Widget _buildContactStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Contact Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('We\'ll use this information to contact you', style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 32),
      _buildTextField(phoneController, 'Phone Number', Icons.phone, true, TextInputType.phone),
      const SizedBox(height: 20),
      _buildTextField(whatsappController, 'WhatsApp (optional)', Icons.chat, false, TextInputType.phone),
      const SizedBox(height: 20),
      _buildTextField(emailController, 'Email Address', Icons.email, true, TextInputType.emailAddress, user?.email, user?.email != null),
      const SizedBox(height: 20),
      const Text('Address *', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 8),
      TextFormField(
        controller: addressController,
        maxLines: 3,
        decoration: InputDecoration(hintText: 'Enter your complete address', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
      ),
    ]);
  }

  Widget _buildPaymentStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Payment Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Complete your registration by making the payment', style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 32),
      _buildTextField(transactionIdController, 'Transaction ID', Icons.receipt_long, false, null, null, false, 'Enter UTR/Transaction number'),
      const SizedBox(height: 20),
      if (!_paymentMade) SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showPaymentDialog,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 18)),
          icon: const Icon(Icons.payment, color: Colors.white),
          label: const Text('Pay Now (₹200)', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
      if (!_paymentMade) const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.shade200)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Payment Instructions:', style: TextStyle(fontSize: 18, color: Colors.green)),
          const SizedBox(height: 15),
          const Text('• Registration Fee: ₹200'),
          const Text('• UPI ID: apjwelfare@upi'),
          const Text('• Bank: State Bank of India'),
          const Text('• Account: 123456789012'),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.yellow.shade50, borderRadius: BorderRadius.circular(8)),
            child: Text(_paymentMade ? 'Payment initiated! Enter Transaction ID above.' : 'Important: After payment, enter Transaction ID above.',
              style: TextStyle(color: _paymentMade ? Colors.green : Colors.orange)),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool required,
      [TextInputType? keyboardType, String? initialValue, bool readOnly = false, String? hintText]) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label${required ? ' *' : ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        initialValue: initialValue,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey.shade50 : null,
        ),
        validator: required ? (value) => value == null || value.isEmpty ? 'Required field' : null : null,
      ),
    ]);
  }
}