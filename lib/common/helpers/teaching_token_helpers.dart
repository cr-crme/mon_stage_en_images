import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:mon_stage_en_images/common/providers/database.dart';

class TeachingTokenHelpers {
  static Future<String> registerToken(String teacherId, String token) async {
    // Unregister previous active tokens created by the teacher
    final previousToken = await createdActiveToken(userId: teacherId);
    if (previousToken != null) await unregisterToken(teacherId, previousToken);

    await Database.root
        .child('tokens')
        .child(token)
        .child('metadata')
        .set({'createdBy': teacherId});
    await Database.root
        .child('tokens')
        .child('existing')
        .child(token)
        .set(true);

    await Database.root
        .child('users')
        .child(teacherId)
        .child('tokens')
        .child('created')
        .child(token)
        .set({'createdAt': ServerValue.timestamp, 'isActive': true});
    await updatePublicInformation(teacherId);

    return token;
  }

  static Future<void> unregisterToken(String teacherId, String token) async {
    // Fetch all the connected users to the token
    final connectedUsers = await userIdsConnectedTo(token: token);
    for (final studentId in connectedUsers) {
      await disconnectFromToken(studentId, token);
    }

    await Database.root.child('tokens').child('existing').child(token).remove();
    await Database.root.child('tokens').child(token).remove();

    await deletePublicInformation(teacherId);
    await Database.root
        .child('users')
        .child(teacherId)
        .child('tokens')
        .child('created')
        .child(token)
        .child('isActive')
        .set(false);
  }

  static Future<void> updatePublicInformation(String userId) async {
    final token = await TeachingTokenHelpers.createdActiveToken(userId: userId);
    if (token == null) return;

    final user =
        (await Database.safeGet(Database.root.child('users').child(userId)))
            ?.value as Map?;
    final firstName = user?['firstName'];
    final lastName = user?['lastName'];
    final avatar = user?['avatar'];
    if (firstName == null || lastName == null || avatar == null) {
      throw Exception('User not found');
    }

    await Database.root
        .child('users')
        .child(userId)
        .child('tokens')
        .child('created')
        .child(token)
        .child('public')
        .set({'firstName': firstName, 'lastName': lastName, 'avatar': avatar});
  }

  static Future<Map?> getPublicInformation(
      String teacherId, String token) async {
    return (await Database.safeGet(Database.root
            .child('users')
            .child(teacherId)
            .child('tokens')
            .child('created')
            .child(token)
            .child('public')))
        ?.value as Map?;
  }

  static Future<void> deletePublicInformation(String teacherId) async {
    final token = await createdActiveToken(userId: teacherId);
    if (token == null) return;

    await Database.root
        .child('users')
        .child(teacherId)
        .child('tokens')
        .child('created')
        .child(token)
        .child('public')
        .remove();
  }

  static Future<void> connectToToken(
      {required String token,
      required String studentId,
      required String teacherId}) async {
    await Database.root
        .child('tokens')
        .child(token)
        .child('connectedUsers')
        .update({studentId: true});

    await Database.root
        .child('users')
        .child(studentId)
        .child('tokens')
        .child('connected')
        .set({token: true});

    await Database.root
        .child('users')
        .child(studentId)
        .child('tokens')
        .child('userWithExtendedPermissions')
        .set({teacherId: true});
  }

  /// Disconnect a student from a token
  static Future<void> disconnectFromToken(
      String studentId, String token) async {
    await Database.root
        .child('tokens')
        .child(token)
        .child('connectedUsers')
        .child(studentId)
        .remove();

    await Database.root
        .child('users')
        .child(studentId)
        .child('tokens')
        .child('connected')
        .child(token)
        .remove();

    await Database.root
        .child('users')
        .child(studentId)
        .child('tokens')
        .child('userWithExtendedPermissions')
        .remove();
  }

  ///
  /// Generate a 6-character token that is not already in the database
  static Future<String> generateUniqueToken() async {
    final existingTokens = await _existingTokens();

    const chars = 'ABCDEFGHJKMNPQRSTUVXY3456789';
    final rand = Random();
    String token;
    do {
      token =
          List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
    } while (existingTokens.contains(token));

    return token;
  }

  static Future<Set<String>> _existingTokens() async {
    final data =
        await Database.safeGet(Database.root.child('tokens').child('existing'));
    return (data?.value as Map?)?.keys.cast<String>().toSet() ?? {};
  }

  static Future<String?> connectedToken({required String studentId}) async {
    final tokensSnapshot = Database.root
        .child('users')
        .child(studentId)
        .child('tokens')
        .child('connected');
    final tokens = (await Database.safeGet(tokensSnapshot))?.value as Map?;
    if (tokens == null || tokens.isEmpty) return null;

    return tokens.keys.first;
  }

  static Future<String?> creatorIdOf({required String token}) async {
    final snapshot = await Database.safeGet(Database.root
        .child('tokens')
        .child(token)
        .child('metadata')
        .child('createdBy'));
    return snapshot?.value as String?;
  }

  static Future<Iterable<String>> userIdsConnectedTo(
      {required String token}) async {
    final snapshot = await Database.safeGet(
        Database.root.child('tokens').child(token).child('connectedUsers'));
    return (snapshot?.value as Map?)?.keys.cast<String>() ?? [];
  }

  static Future<String?> createdActiveToken({required String userId}) async {
    final tokens = await createdTokens(userId: userId, activeOnly: true);
    return tokens.isEmpty ? null : tokens.first;
  }

  static Future<Iterable<String>> createdTokens(
      {required String userId, bool activeOnly = true}) async {
    final snapshot = await Database.safeGet(Database.root
        .child('users')
        .child(userId)
        .child('tokens')
        .child('created'));

    final tokens = (snapshot?.value as Map?)?.cast<String, dynamic>() ?? {};
    if (activeOnly) {
      return tokens.entries
          .where((entry) => (entry.value as Map?)?['isActive'] == true)
          .map((entry) => entry.key);
    } else {
      return tokens.keys;
    }
  }
}
