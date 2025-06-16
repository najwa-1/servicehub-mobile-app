import 'package:flutter/material.dart';
import '../../models/booking_form_model.dart';
import '../../services/booking_form_service.dart';

class BookingFormController extends ChangeNotifier {
  final BookingFormService _service = BookingFormService();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String _serviceName = '';
  String _serviceProvider = '';
  String _serviceId = '';
  String _providerId = '';

  bool _isFormValid = false;
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isFormValid => _isFormValid;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get serviceName => _serviceName;
  String get serviceProvider => _serviceProvider;

  BookingFormController() {
    nameController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
    locationController.addListener(_validateForm);
    timeController.addListener(_validateForm);
    dateController.addListener(_validateForm);
  }

  void initializeService(Map<String, dynamic> service) {
    _serviceName = service['name'] ?? 'Service Name';
    _serviceProvider = service['user'] ?? 'Service Provider Name';
    _serviceId = service['id'] ?? '';
    _providerId = service['userId'] ?? '';
    
    fetchUserData();
    _validateForm();
  }

  Future<void> fetchUserData() async {
    try {
      final profileData = await _service.fetchUserProfile();
      if (profileData != null) {
        final location = await _service.parseLocationFromProfile(profileData);
        if (location.isNotEmpty) {
          locationController.text = location;
        }

        final name = _service.parseNameFromProfile(profileData);
        if (name.isNotEmpty) {
          nameController.text = name;
        }

        final phone = _service.parsePhoneFromProfile(profileData);
        if (phone.isNotEmpty) {
          phoneController.text = phone;
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _validateForm() {
    final isValid = nameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        timeController.text.isNotEmpty &&
        dateController.text.isNotEmpty;
    
    if (_isFormValid != isValid) {
      _isFormValid = isValid;
      notifyListeners();
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      timeController.text = pickedTime.format(context);
      notifyListeners();
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      notifyListeners();
    }
  }

  BookingFormModel _createBookingModel() {
    final user = _service.getCurrentUser();
    final bookingDateTime = _service.parseSelectedDateTime(
      dateController.text, 
      timeController.text
    );

    return BookingFormModel(
      name: nameController.text,
      phone: phoneController.text,
      location: locationController.text,
      time: timeController.text,
      date: dateController.text,
      serviceName: _serviceName,
      serviceProvider: _serviceProvider,
      serviceId: _serviceId,
      providerId: _providerId,
      bookingDateTime: bookingDateTime,
      clientId: user?.uid ?? '',
    );
  }

  Future<bool> submitBooking() async {
    if (!_isFormValid) {
      _errorMessage = 'Please fill all fields';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final booking = _createBookingModel();
      await _service.submitBooking(booking);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Map<String, String> getConfirmationData() {
    return {
      'serviceName': _serviceName,
      'serviceProvider': _serviceProvider,
      'name': nameController.text,
      'location': locationController.text,
      'date': dateController.text,
      'time': timeController.text,
    };
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    timeController.dispose();
    dateController.dispose();
    super.dispose();
  }
}
