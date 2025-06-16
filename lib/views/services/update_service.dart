import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repository/update-service_repository.dart';
import '../../widgets/rating_and_service/image_pickerr_widget.dart';
import '../../widgets/rating_and_service/text_field_widget.dart';
import '../../widgets/rating_and_service/update_button_widget.dart';


class UpdateService extends StatefulWidget {
  final Map<String, dynamic> service;

  UpdateService({required this.service});

  @override
  _UpdateServicePageState createState() => _UpdateServicePageState();
}

class _UpdateServicePageState extends State<UpdateService> {
  final nameController = TextEditingController();
  final detailsController = TextEditingController();
  final priceController = TextEditingController();
  final userController = TextEditingController();
  final phoneController = TextEditingController();

  Uint8List? _imageBytes;
late updateServiceRepository _repository;

  static const double paddingAll = 16.0;
  static const double spacingSmall = 16.0;
  static const double spacingMedium = 20.0;
  static const double spacingLarge = 24.0;

  @override
void initState() {
  super.initState();

  Future.microtask(() {
    _repository = Provider.of<updateServiceRepository>(context, listen: false);

    final service = widget.service;
    nameController.text = service['name'];
    detailsController.text = service['details'];
    priceController.text = service['price'];
    userController.text = service['user'];
    phoneController.text = service['phone'] ?? '';
    _imageBytes = base64Decode(service['imageBytes']);
  });
}

  Future<void> _pickImage() async {
    try {
      final bytes = await _repository.pickImage();
      if (bytes != null) {
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _submitUpdate() async {
    final updatedService = {
      'user': userController.text,
      'phone': phoneController.text, 
      'name': nameController.text,
      'details': detailsController.text,
      'price': priceController.text,
      'imageBytes': base64Encode(_imageBytes ?? Uint8List(0)),
    };

    try {
      await _repository.submitUpdate(widget.service['id'], updatedService);
      Navigator.pop(context, updatedService);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Service')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(paddingAll),
        child: Column(
          children: [
            ImagePickerWidget(
              imageBytes: _imageBytes,
              onTap: _pickImage,
            ),
            SizedBox(height: spacingMedium),
            TextFieldWidget(controller: userController, labelText: 'User Name'),
            SizedBox(height: spacingMedium),
            TextFieldWidget(
              controller: phoneController,
              labelText: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: spacingMedium),
            TextFieldWidget(controller: nameController, labelText: 'Service Name'),
            SizedBox(height: spacingSmall),
            TextFieldWidget(
              controller: detailsController,
              labelText: 'Service Details',
              maxLines: 3,
            ),
            SizedBox(height: spacingSmall),
            TextFieldWidget(
              controller: priceController,
              labelText: 'Price',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: spacingLarge),
            UpdateButtonWidget(onPressed: _submitUpdate),
          ],
        ),
      ),
    );
  }
}
