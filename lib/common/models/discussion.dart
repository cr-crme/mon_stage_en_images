import 'package:defi_photo/crcrme_enhanced_containers/lib/list_serializable.dart';

import './message.dart';

class Discussion extends ListSerializable<Message> {
  Discussion() : super();
  Discussion.fromList(List<Message> discussion) {
    for (final message in discussion) {
      add(message);
    }
  }
  Discussion.fromSerialized(Map<String, dynamic> map)
      : super.fromSerialized(map);

  @override
  Message deserializeItem(data) {
    return Message.fromSerialized(data);
  }
}
