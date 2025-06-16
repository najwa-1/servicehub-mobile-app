import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Widget buildProfilePicture({
  required Uint8List? imageBytes,
  required VoidCallback onEdit,
}) {
  ImageProvider? image = imageBytes != null ? MemoryImage(imageBytes) : null;

  return Center(
    child: Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundImage: image,
          backgroundColor: Colors.grey[300],
          child: image == null ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
        ),
        Container(
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black87),
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 22),
            onPressed: onEdit,
          ),
        ),
      ],
    ),
  );
}

Widget buildProfileTile({
  required IconData icon,
  required String title,
  required String value,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: SizedBox(
      width: 160,
      child: InkWell(
        onTap: onTap,
        child: Text(
          value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
  );
}

Widget buildActionTile({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  Color? iconColor,
  Color? textColor,
}) {
  return ListTile(
    leading: Icon(icon, size: 28, color: iconColor),
    title: Text(
      title,
      style: TextStyle(fontSize: 18, color: textColor ?? Colors.black),
    ),
    onTap: onTap,
  );
}
