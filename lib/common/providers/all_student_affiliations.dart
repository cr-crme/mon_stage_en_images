import 'package:defi_photo/crcrme_enhanced_containers/lib/firebase_list_provided.dart';
import 'package:defi_photo/crcrme_enhanced_containers/lib/list_serializable.dart';

import '../models/student_affiliation.dart';

class AllStudentAffiliations extends FirebaseListProvided<StudentAffiliation>
    with CreationTimedItems {
  int get count => length;
  static const String dataName = 'student-affiliation';

  AllStudentAffiliations() : super(pathToData: dataName);

  @override
  StudentAffiliation deserializeItem(data) {
    return StudentAffiliation.fromSerialized(data);
  }
}
