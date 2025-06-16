import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../repository/add-service_repository.dart';
import '../../../widgets/rating_and_service/image_picker_widget.dart';
import '../../../widgets/rating_and_service/service_form_field.dart';
import '../../theme/app_colors.dart';

class AddServicePage extends StatefulWidget {
  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final nameController = TextEditingController();
  final detailsController = TextEditingController();
  final priceController = TextEditingController();
  final userController = TextEditingController();
  final phoneController = TextEditingController();

  Uint8List? _imageBytes;
  bool isFormValid = false;

  final double paddingAll = 16.0;
  final double spaceSmall = 16.0;
  final double spaceMedium = 20.0;
  final double spaceLarge = 24.0;
  final double appBarFontSize = 18;
  final double buttonFontSize = 16;
  final double buttonPaddingHorizontal = 24;
  final double buttonPaddingVertical = 12;
  final double buttonBorderRadius = 10;

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumber();
  }

  void _fetchPhoneNumber() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('phone')) {
          phoneController.text = data['phone'];
          _validateForm();
        }
      }
    }
  }

  void _validateForm() {
    setState(() {
      isFormValid = nameController.text.isNotEmpty &&
          detailsController.text.isNotEmpty &&
          priceController.text.isNotEmpty &&
          userController.text.isNotEmpty &&
          phoneController.text.isNotEmpty;
    });
  }

  void _onImageSelected(Uint8List bytes) {
    setState(() {
      _imageBytes = bytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Service',
          style: TextStyle(
            fontSize: appBarFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(paddingAll),
        child: Column(
          children: [
            ImagePickerWidget(imageBytes: _imageBytes, onImageSelected: _onImageSelected),
            SizedBox(height: spaceMedium),
            ServiceFormField(
              controller: userController,
              label: 'User Name',
              hint: 'Enter your name',
              onChanged: _validateForm,
            ),
            SizedBox(height: spaceMedium),
            ServiceFormField(
              controller: phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              isNumber: true,
              onChanged: _validateForm,
            ),
            SizedBox(height: spaceMedium),
            ServiceFormField(
              controller: nameController,
              label: 'Service Name',
              hint: 'Enter service name',
              onChanged: _validateForm,
            ),
            SizedBox(height: spaceSmall),
            ServiceFormField(
              controller: detailsController,
              label: 'Service Details',
              hint: 'Enter service details',
              maxLines: 3,
              onChanged: _validateForm,
            ),
            SizedBox(height: spaceMedium),
            ServiceFormField(
              controller: priceController,
              label: 'Price',
              hint: 'Enter service price',
              isNumber: true,
              onChanged: _validateForm,
            ),
            SizedBox(height: spaceLarge),
            ElevatedButton(
              onPressed: isFormValid
                  ? () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        print("User not logged in!");
                        return;
                      }

                      final newService = {
                        'user': userController.text,
                        'userId': user.uid,
                        'phone': phoneController.text,
                        'name': nameController.text,
                        'details': detailsController.text,
                        'price': priceController.text,
                        'imageBytes': _imageBytes != null ? base64Encode(_imageBytes!) : '',
                      };

                      final repository = Provider.of<addServiceRepository>(context, listen: false);
        final serviceId = await repository.addService(newService);
                      if (serviceId != null) {
                        Navigator.pop(context, serviceId);
                      }
                    }
                  : null,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: buttonPaddingHorizontal,
                  vertical: buttonPaddingVertical,
                ),
                child: Text(
                  'Add Service',
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFormValid ? AppColors.primary : AppColors.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonBorderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
