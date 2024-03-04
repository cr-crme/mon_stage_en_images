import 'dart:io';
import 'dart:typed_data';

import 'package:defi_photo/common/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

abstract class StorageService {
  static Future<Uint8List?> getImage(String imageUrl) async {
    return await FirebaseStorage.instance.ref(imageUrl).getData();
  }

  static Future<String> uploadImage(User student, XFile image) async {
    return await uploadFile(student, File(image.path));
  }

  static Future<String> uploadFile(User student, File file) async {
    final url = '/${student.id}/${file.hashCode}${extension(file.path)}';
    var ref = FirebaseStorage.instance.ref(url);

    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return url;
  }
}
