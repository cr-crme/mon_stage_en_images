import 'package:defi_photo/crcrme_enhanced_containers/lib/item_serializable.dart';

class StudentAffiliation extends ItemSerializable {
  // Constructors and (de)serializer
  StudentAffiliation({required this.teacherEmail, required this.studentEmail})
      : super(id: 'studentEmail');
  StudentAffiliation.fromSerialized(map)
      : teacherEmail = map['teacherEmail'],
        studentEmail = map['studentEmail'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'teacherEmail': teacherEmail,
      'studentEmail': studentEmail,
    };
  }

  @override
  StudentAffiliation deserializeItem(map) {
    return StudentAffiliation.fromSerialized(map);
  }

  // Attributes and methods
  final String teacherEmail;
  final String studentEmail;

  @override
  String toString() {
    return '$studentEmail added by $teacherEmail';
  }
}
