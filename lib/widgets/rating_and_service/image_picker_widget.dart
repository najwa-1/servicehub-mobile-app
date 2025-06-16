import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_colors.dart';

class ImagePickerWidget extends StatelessWidget {
  final Uint8List? imageBytes;
  final Function(Uint8List) onImageSelected;
  static const double containerSize = 150.0;
  static const double borderRadiusValue = 15.0;
  static const double borderWidth = 2.0;

  ImagePickerWidget({required this.imageBytes, required this.onImageSelected});

  void _pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('photo shoot'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    final bytes = await pickedFile.readAsBytes();
                    onImageSelected(bytes);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Selection from the gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    final bytes = await pickedFile.readAsBytes();
                    onImageSelected(bytes);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(borderRadiusValue),
          border: Border.all(color: AppColors.primary, width: borderWidth),
        ),
        child: imageBytes == null
            ? Center(child: Icon(Icons.add_a_photo, color:AppColors.primary))
            : ClipRRect(
                borderRadius: BorderRadius.circular(borderRadiusValue),
                child: Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}

