import 'package:enhanced_containers/enhanced_containers.dart';

import 'message.dart';

class Discussion extends ListSerializable<Message> with ItemsWithCreationTimed {
  Discussion();
  Discussion.fromList(List<Message> discussion) {
    for (final message in discussion) {
      add(message);
    }
  }
  Discussion.fromSerialized(super.map) : super.fromSerialized();

  @override
  Message deserializeItem(data) {
    return Message.fromSerialized((data as Map?)?.cast<String, dynamic>());
  }
}
