import 'package:intl/intl.dart';

extension StringDateTimeFromInt on int {
  String toFullDateFromEpoch({String formatter = 'dd MMM yy hh:mm'}) {
    DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(this);
    return this >= 0
        ? DateFormat(formatter, 'fr_Fr').format(dateTime)
        : toString();
  }
}
