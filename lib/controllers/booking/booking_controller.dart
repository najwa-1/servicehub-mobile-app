import 'package:flutter/material.dart';
import '../../models/booking/booking_model.dart';
import '../../services/booking_service.dart';

class BookingController extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  
  bool _isLoading = true;
  bool _hasError = false;
  List<BookingModel> _allBookings = [];
  String _errorMessage = '';
  String _currentBookingId = '';

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  List<BookingModel> get allBookings => _allBookings;
  String get errorMessage => _errorMessage;
  int get bookingsCount => _allBookings.length;

  void setCurrentBookingId(String bookingId) {
    _currentBookingId = bookingId;
  }

  Future<void> fetchAllBookings() async {
    try {
      _setLoadingState(true, false);
      
      final bookings = await _bookingService.fetchAllBookings(_currentBookingId);
      
      _allBookings = bookings;
      _setLoadingState(false, false);
    } catch (e) {
      String errorMsg = _bookingService.getErrorMessage(e);
      _setErrorState(errorMsg);
    }
  }

  void _setLoadingState(bool loading, bool error) {
    _isLoading = loading;
    _hasError = error;
    notifyListeners();
  }

  void _setErrorState(String errorMsg) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = errorMsg;
    notifyListeners();
  }

  void retryFetch() {
    _bookingService.clearProviderCache();
    fetchAllBookings();
  }

  void refreshData() {
    _bookingService.clearProviderCache();
    fetchAllBookings();
  }

  bool isEmpty() {
    return _allBookings.isEmpty;
  }
}