import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/helpers/helpers.dart';
import 'package:mon_stage_en_images/common/helpers/responsive_service.dart';
import 'package:mon_stage_en_images/common/helpers/route_manager.dart';
import 'package:mon_stage_en_images/common/helpers/teaching_token_helpers.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/common/providers/database.dart';
import 'package:mon_stage_en_images/common/widgets/are_you_sure_dialog.dart';
import 'package:mon_stage_en_images/common/widgets/avatar_tab.dart';
import 'package:mon_stage_en_images/common/widgets/main_drawer.dart';
import 'package:mon_stage_en_images/common/widgets/user_info_dialog.dart';
import 'package:mon_stage_en_images/default_onboarding_steps.dart';
import 'package:mon_stage_en_images/onboarding/onboarding.dart';
import 'package:mon_stage_en_images/screens/all_students/widgets/student_list_tile.dart';
import 'package:provider/provider.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  static const routeName = '/students-screen';

  @override
  State<StudentsScreen> createState() => StudentsScreenState();
}

//StudentsScreenState is purposefully made public so onboarding can access its inner methods (like openDrawer)
class StudentsScreenState extends State<StudentsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    final database = Provider.of<Database>(context, listen: false);
    final userType = database.userType;
    final user = database.currentUser;
    if (user == null) return;

    switch (userType) {
      case UserType.none:
      case UserType.student:
        break;
      case UserType.teacher:
        Future.delayed(Duration(milliseconds: 500), () {
          if (!mounted) return;
          OnboardingContexts.instance.requestOnboarding(context);
        });
    }
  }

  void openDrawer() => scaffoldKey.currentState?.openDrawer();
  void closeDrawer() {
    if (isDrawerOpen != true) return;
    Navigator.of(context).pop();
  }

  bool? get isDrawerOpen => scaffoldKey.currentState?.isDrawerOpen;
  bool _isFetchingUsers = false;

  Future<void> _showCurrentToken() async {
    final teacherId =
        Provider.of<Database>(context, listen: false).currentUser!.id;

    final token =
        await TeachingTokenHelpers.createdActiveToken(userId: teacherId);
    if (!mounted) return;
    if (token == null) {
      _generateNewToken();
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Code d\'inscription'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Communiquez le code suivant à vos élèves pour qu\'ils vous\n'
                  'enregistrent comme enseignant(e).'),
              const SizedBox(height: 20),
              Center(
                child: SelectableText(
                  token,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _generateNewToken();
                },
                child: const Text('Nouveau code',
                    style: TextStyle(color: Colors.black))),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  final _passwordFormKey = GlobalKey<FormState>();
  StateSetter? _passwordDialogSetState;
  String _password = '';
  String? _passwordError;
  Future<void> _validatePasswordDialogForm() async {
    if (_password.isEmpty) {
      if (_passwordDialogSetState != null) {
        _passwordDialogSetState!(() {
          _passwordError = 'Veuillez entrer votre mot de passe';
        });
      }
      return;
    }

    // Check if the password is correct
    final database = Provider.of<Database>(context, listen: false);
    final loginStatus = await database.login(
        username: database.currentUser!.email,
        password: _password,
        skipPostLogin: true);
    if (loginStatus != EzloginStatus.success) {
      if (_passwordDialogSetState != null) {
        _passwordDialogSetState!(() {
          _passwordError =
              'Les identifiants fournis ne correspondent pas à notre base de données.'
              'Veuillez réessayer avec des identifiants corrects.';
        });
      }
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  bool _isGeneratingToken = false;
  Future<void> _generateNewToken() async {
    final teacherId =
        Provider.of<Database>(context, listen: false).currentUser!.id;

    final isSuccess = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _passwordDialogSetState = setState;
            return AreYouSureDialog(
              title: 'Générer un nouveau code?',
              content:
                  'Êtes-vous certain(e) de vouloir générer un nouveau code?\n'
                  'Réinitialiser votre code interrompt et archive la communication\n'
                  'avec vos élèves enregistrés.\n\n'
                  'Entrez votre mot de passe pour confirmer :',
              extraContent: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Form(
                  key: _passwordFormKey,
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      errorMaxLines: 3,
                      errorText: _passwordError,
                    ),
                    obscureText: true,
                    autofocus: true,
                    onChanged: (value) {
                      _password = value;
                      _passwordDialogSetState!(() {
                        _passwordError = null;
                      });
                    },
                    onFieldSubmitted: (_) => _validatePasswordDialogForm(),
                    validator: (value) => _passwordError,
                  ),
                ),
              ),
              onCancelled: () => Navigator.pop(context, false),
              onConfirmed: _validatePasswordDialogForm,
            );
          },
        );
      },
    );
    _passwordDialogSetState = null;
    if (!mounted) return;
    if (isSuccess != true) {
      Helpers.showSnackbar(context, 'Génération du nouveau code annulée');
      return;
    }

    setState(() {
      _isGeneratingToken = true;
    });
    // Prevent from trying to fetch old data while generating new token
    final database = Provider.of<Database>(context, listen: false);
    await database.teacherAnswers.stopFetchingData();

    // Generate and register new token
    final newToken = await TeachingTokenHelpers.generateUniqueToken();
    await TeachingTokenHelpers.registerToken(teacherId, newToken);

    // Force relogin to refresh setup
    if (!mounted) return;
    final username = database.currentUser!.email;
    await database.logout();
    await database.login(
        username: username, password: _password, userType: UserType.teacher);

    if (!mounted) return;
    await _showCurrentToken();

    if (!mounted) return;
    RouteManager.instance.gotoStudentsPage(context);
  }

  Future<void> _showStudentInfo(User student) async {
    final database = Provider.of<Database>(context, listen: false);

    final newInfo = await showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button
      builder: (BuildContext context) => UserInfoDialog(
        title: const Text('Informations de l\'élève'),
        user: student,
        showEditableNotes: true,
        onRemoveFromList: (password) async =>
            _removeStudent(student: student, password: password),
      ),
    );
    if (newInfo == null) return;

    await database.modifyNotes(studentId: student.id, notes: newInfo);
  }

  Future<void> _removeStudent(
      {required User student, required String password}) async {
    if (!mounted) return;
    final token = await TeachingTokenHelpers.createdActiveToken(
        userId: Provider.of<Database>(context, listen: false).currentUser!.id);
    if (token == null) return;
    await TeachingTokenHelpers.disconnectFromToken(student.id, token);
    if (!mounted) return;

    final database = Provider.of<Database>(context, listen: false);
    final username = database.currentUser!.email;
    await database.logout();
    await database.login(
        username: username, password: password, userType: UserType.teacher);
    if (!mounted) return;
    RouteManager.instance.gotoStudentsPage(context);
  }

  PreferredSizeWidget _setAppBar() {
    final currentUser =
        Provider.of<Database>(context, listen: false).currentUser;
    if (currentUser == null) {
      return ResponsiveService.appBarOf(
        context,
      );
    }

    return ResponsiveService.appBarOf(
      context,
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AvatarTab(
                user:
                    Provider.of<Database>(context, listen: false).currentUser!),
          ),
          const Text('Mes élèves'),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onPrimary),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
      actions: [
        IconButton(
            onPressed: _isFetchingUsers
                ? null
                : () async {
                    setState(() {
                      _isFetchingUsers = true;
                    });
                    final database =
                        Provider.of<Database>(context, listen: false);

                    final previousStudentIds =
                        database.students.map((e) => e.id).toList();
                    await database.fetchUsers();
                    if (database.students
                        .any((e) => !previousStudentIds.contains(e.id))) {
                      await database.restartFetchingTeacherAnswers();
                    }
                    setState(() {
                      _isFetchingUsers = false;
                    });
                  },
            icon: _isFetchingUsers
                ? const Icon(Icons.hourglass_bottom)
                : const Icon(Icons.refresh, color: Colors.black)),
        OnboardingContainer(
          onInitialize: (context) =>
              OnboardingContexts.instance['generate_code'] = context,
          child: IconButton(
            onPressed: _isGeneratingToken || _isFetchingUsers
                ? null
                : _showCurrentToken,
            icon: Icon(Icons.qr_code_2,
                color: IconButtonTheme.of(context).style?.iconColor?.resolve({
                  WidgetState.disabled,
                })),
            iconSize: 35,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isGeneratingToken) {
      return ResponsiveService.scaffoldOf(
        context,
        appBar: _setAppBar(),
        body: Center(child: Text('Génération du code d\'inscription...')),
        smallDrawer: MainDrawer.small(),
        mediumDrawer: MainDrawer.medium(),
        largeDrawer: MainDrawer.large(),
      );
    }

    final bool isOnboarding = OnboardingContexts.instance.isOnboarding;
    final students = Provider.of<Database>(context).students;
    students.sort(
        (a, b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()));

    final dummy = OnboardingContexts.instance.dummyStudent;

    return ResponsiveService.scaffoldOf(
      context,
      key: scaffoldKey,
      appBar: _setAppBar(),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          AbsorbPointer(
            absorbing: _isGeneratingToken,
            child: Column(
              children: [
                const SizedBox(height: 15),
                Text('Mon stage en images',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 3),
                if (_isFetchingUsers) ...[
                  SizedBox(
                    height: 12,
                  ),
                  LinearProgressIndicator(),
                  Text(
                    'Actualisation de la liste d\'élèves en cours',
                    style: Theme.of(context).textTheme.labelLarge,
                  )
                ],
                isOnboarding
                    ? StudentListTile(
                        dummy.id,
                        isOnboarding: isOnboarding,
                        modifyStudentCallback: _showStudentInfo,
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return StudentListTile(
                              students[index].id,
                              isOnboarding: isOnboarding,
                              modifyStudentCallback: _showStudentInfo,
                            );
                          },
                          itemCount: students.length,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
      smallDrawer: MainDrawer.small(),
      mediumDrawer: MainDrawer.medium(),
      largeDrawer: MainDrawer.large(),
    );
  }
}
