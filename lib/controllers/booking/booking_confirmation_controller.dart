
import 'package:flutter/material.dart';
import '../../models/booking/booking_confirmation_model.dart';
import '../../services/booking_confirmation_service.dart';

class BookingConfirmationController extends ChangeNotifier {
  final BookingConfirmationService _service = BookingConfirmationService();
  
  BookingConfirmationModel? _booking;
  String? _bookingId;
  bool _isLoading = true;
  String _providerName = '';
  bool _hasError = false;
  String _errorMessage = '';

  BookingConfirmationModel? get booking => _booking;
  String? get bookingId => _bookingId;
  bool get isLoading => _isLoading;
  String get providerName => _providerName;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  Future<void> initializeBooking({
    required String name,
    required String location,
    required String time,
    required String date,
    required String service,
    required String provider,
    required String serviceId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _booking = BookingConfirmationModel(
        name: name,
        location: location,
        time: time,
        date: date,
        service: service,
        provider: provider,
        serviceId: serviceId,
      );

      await _resolveProviderName();
      
      await _saveBookingToFirebase();
      
      print('Booking initialized successfully');
      print('Provider ID: $provider');
      print('Provider Name: $_providerName');
      
    } catch (e) {
      print('Error in initializeBooking: $e');
      _setError('Failed to initialize booking: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _resolveProviderName() async {
    try {
      if (_booking?.provider.isNotEmpty == true) {
        print('Resolving provider name for ID: ${_booking!.provider}');
        _providerName = await _service.getProviderName(_booking!.provider);
        print('Resolved provider name: $_providerName');
        
        _booking = _booking!.copyWith(providerName: _providerName);
      } else {
        print('Provider ID is empty');
        _providerName = 'Unknown Provider';
        _booking = _booking!.copyWith(providerName: _providerName);
      }
    } catch (e) {
      print('Error resolving provider name: $e');
      _providerName = _booking?.provider ?? 'Unknown Provider';
      _booking = _booking!.copyWith(providerName: _providerName);
    }
  }

  Future<void> _saveBookingToFirebase() async {
    try {
      if (_booking == null) {
        throw Exception('Booking data is null');
      }

      final savedBookingId = await _service.saveBooking(_booking!);
      
      _bookingId = savedBookingId;
      _booking = _booking!.copyWith(bookingId: savedBookingId);
      
    } catch (e) {
      print('Error saving booking to Firebase: $e');
      throw Exception('Failed to save booking: $e');
    }
  }

  Future<void> retryInitialization() async {
    if (_booking != null) {
      await initializeBooking(
        name: _booking!.name,
        location: _booking!.location,
        time: _booking!.time,
        date: _booking!.date,
        service: _booking!.service,
        provider: _booking!.provider,
        serviceId: _booking!.serviceId,
      );
    } else {
      _setError('No booking data available to retry');
    }
  }

  Map<String, String> getDisplayData() {
    if (_booking == null) return {};
    return _booking!.toDisplayData();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}