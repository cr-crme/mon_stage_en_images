import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mon_stage_en_images/common/helpers/push_notifications_helpers.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/common/providers/database.dart';
import 'package:mon_stage_en_images/screens/all_students/students_screen.dart';
import 'package:mon_stage_en_images/screens/login/failed_checks_screen.dart';
import 'package:mon_stage_en_images/screens/login/go_to_irsst_screen.dart';
import 'package:mon_stage_en_images/screens/login/login_screen.dart';
import 'package:mon_stage_en_images/screens/login/terms_and_services_screen.dart';
import 'package:mon_stage_en_images/screens/login/wrong_version_screen.dart';
import 'package:mon_stage_en_images/screens/my_info/my_info_screen.dart';
import 'package:mon_stage_en_images/screens/q_and_a/q_and_a_screen.dart';
import 'package:mon_stage_en_images/screens/resources/resources_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:pub_semver/pub_semver.dart';

final _logger = Logger('RouteManager');

enum _VersionStatus {
  validVersion,
  wrongVersion,
  pendingVersion,
  cannotObtainVersion;
}

class RouteManager {
  // Singleton pattern
  RouteManager._();
  static final RouteManager instance = RouteManager._();

  bool get isInitialized => _status != _VersionStatus.pendingVersion;

  _VersionStatus _status = _VersionStatus.pendingVersion;
  Future<void> initialize() async {
    await _setVersionIsValid();
  }

  Future<void> _setVersionIsValid() async {
    WidgetsFlutterBinding.ensureInitialized();

    String versionString;
    // Check the software version
    try {
      versionString = (await Database.getRequiredSoftwareVersion())!;
    } on Exception catch (e) {
      _logger.info('Cannot obtain software required version : ${e.toString()}');
      _status = _VersionStatus.cannotObtainVersion;
      return;
    }

    final requiredVersion = Version.parse(versionString);

    final packageInfo = await PackageInfo.fromPlatform();
    final current = Version.parse(packageInfo.version);
    _status = current >= requiredVersion
        ? _VersionStatus.validVersion
        : _VersionStatus.wrongVersion;
  }

  final _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  NavigatorState? get currentState => _navigatorKey.currentState;

  String get initialRoute => switch (_status) {
        _VersionStatus.pendingVersion => throw Exception(
            'RouteManager is not initialized. Call initialize() before accessing initialRoute.'),
        _VersionStatus.cannotObtainVersion => FailedChecksScreen.routeName,
        _VersionStatus.wrongVersion => WrongVersionScreen.routeName,
        _VersionStatus.validVersion => LoginScreen.routeName
      };

  Future<void> gotoLoginPage(BuildContext context) async {
    if (!isInitialized) {
      throw Exception(
          'RouteManager is not initialized. Call initialize() before accessing initialRoute.');
    }

    await currentState?.pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (route) => false,
    );
  }

  Future<void> gotoTermsAndServicesPage(BuildContext context) async {
    if (!isInitialized) {
      throw Exception(
          'RouteManager is not initialized. Call initialize() before accessing initialRoute.');
    }

    if (currentState == null) return;

    // We setup the push notifications here because this function is called
    // right after the user logs in
    await PushNotificationsHelpers.setupPushNotifications(context);
    if (!context.mounted) return;

    final areTermsAccepted = Provider.of<Database>(context, listen: false)
        .currentUser!
        .termsAndServicesAccepted;

    if (!areTermsAccepted) {
      await currentState?.pushNamedAndRemoveUntil(
          TermsAndServicesScreen.routeName, (route) => false);
    } else {
      await gotoIrsstPage(context);
    }
  }

  Future<void> gotoIrsstPage(BuildContext context) async {
    if (!isInitialized) {
      throw Exception(
          'RouteManager is not initialized. Call initialize() before accessing initialRoute.');
    }

    if (currentState == null) return;
    final database = Provider.of<Database>(context, listen: false);
    final userType = database.userType;
    final user = database.currentUser;
    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    switch (userType) {
      case UserType.student:
        await gotoQAndAPage(context,
            target: Target.individual,
            pageMode: PageMode.editableView,
            student: null);
        break;
      case UserType.teacher:
      case UserType.none:
        if (user.irsstPageSeen) {
          await gotoStudentsPage(context);
        } else {
          await currentState?.pushNamedAndRemoveUntil(
            GoToIrsstScreen.routeName,
            (route) => false,
          );
        }
        break;
    }
  }

  Future<void> gotoMyInfoPage(BuildContext context) async {
    if (!isInitialized) {
      throw Exception(
          'RouteManager is not initialized. Call initialize() before accessing initialRoute.');
    }

    await currentState?.pushNamedAndRemoveUntil(
      MyInfoScreen.routeName,
      (route) => false,
    );
  }

  Future<void> gotoStudentsPage(BuildContext context) async {
    if (!isInitialized) {
      throw Exception(
          'RouteManager is not initialized. Call initialize() before accessing initialRoute.');
    }

    await currentState?.pushNamedAndRemoveUntil(
      StudentsScreen.routeName,
      (route) => false,
    );
  }

  Future<void> goToResourcesPage(BuildContext context) async {
    if (!isInitialized) {
      throw Exception(
          'RouteManager is not initialized. Call initialize() before accessing initialRoute.');
    }
    await currentState?.pushNamedAndRemoveUntil(
      ResourcesScreen.routeName,
      (route) => false,
    );
  }

  Future<void> gotoQAndAPage(
    BuildContext context, {
    required Target target,
    required PageMode pageMode,
    required User? student,
    bool pushOnStack = false,
  }) async {
    if (!isInitialized) {
      throw Exception(
          'RouteManager is not initialized. Call initialize() before accessing initialRoute.');
    }

    pushOnStack
        ? await currentState?.pushNamed(
            QAndAScreen.routeName,
            arguments: [target, pageMode, student],
          )
        : await currentState?.pushNamedAndRemoveUntil(
            QAndAScreen.routeName,
            (route) => false,
            arguments: [target, pageMode, student],
          );
  }

  Widget builderForCurrentRoute(String routeName) {
    switch (routeName) {
      case MyInfoScreen.routeName:
        return MyInfoScreen();
      case FailedChecksScreen.routeName:
        return FailedChecksScreen();
      case WrongVersionScreen.routeName:
        return WrongVersionScreen();
      case LoginScreen.routeName:
        return LoginScreen();
      case TermsAndServicesScreen.routeName:
        return TermsAndServicesScreen();
      case GoToIrsstScreen.routeName:
        return GoToIrsstScreen();
      case StudentsScreen.routeName:
        return StudentsScreen();
      case QAndAScreen.routeName:
        return QAndAScreen();
      case ResourcesScreen.routeName:
        return ResourcesScreen();
      default:
        return SizedBox.shrink();
    }
  }
}
