import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/helpers/emoji_helpers.dart';
import 'package:mon_stage_en_images/common/helpers/helpers.dart';
import 'package:mon_stage_en_images/common/helpers/responsive_service.dart';
import 'package:mon_stage_en_images/common/misc/focus_nodes.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/common/providers/database.dart';
import 'package:mon_stage_en_images/common/widgets/are_you_sure_dialog.dart';
import 'package:provider/provider.dart';

class UserInfoDialog extends StatefulWidget {
  const UserInfoDialog({
    super.key,
    required this.title,
    this.editInformation = false,
    this.showEditableNotes = false,
    required this.user,
    this.onRemoveFromList,
  });

  final Widget title;
  final User user;
  final bool editInformation;
  final bool showEditableNotes;
  final Future<void> Function(String password)? onRemoveFromList;

  @override
  State<UserInfoDialog> createState() => _UserInfoDialogState();
}

class _UserInfoDialogState extends State<UserInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _firstNameController =
      TextEditingController(text: widget.user.firstName);
  late final _lastNameController =
      TextEditingController(text: widget.user.lastName);
  late final _avatarController =
      TextEditingController(text: widget.user.avatar);
  late final _emailController = TextEditingController(text: widget.user.email);

  late final TextEditingController _noteController;

  final _focusNodes = FocusNodes();

  @override
  void initState() {
    super.initState();

    _noteController = TextEditingController(
        text: Provider.of<Database>(context, listen: false)
            .currentUser
            ?.studentNotes[widget.user.id]);

    if (widget.editInformation) {
      _focusNodes.add('firstName');
      _focusNodes.add('lastName');
      _focusNodes.add('email');
    }
    if (widget.showEditableNotes) {
      _focusNodes.add('note');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _avatarController.dispose();
    _emailController.dispose();
    _noteController.dispose();

    _focusNodes.dispose();
    super.dispose();
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

  void _save() {
    final database = Provider.of<Database>(context, listen: false);
    final user = database.currentUser!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newUser = user.copyWith(
      firstName:
          widget.editInformation ? _firstNameController.text : user.firstName,
      lastName:
          widget.editInformation ? _lastNameController.text : user.lastName,
      avatar: widget.editInformation ? _avatarController.text : user.avatar,
      email: widget.editInformation ? _emailController.text : user.email,
      studentNotes: {
        ...user.studentNotes,
        widget.user.id: _noteController.text
      },
    );

    database.modifyUser(user: user, newInfo: newUser);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              maxWidth: ResponsiveService.smallScreenWidth),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                widget.editInformation
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            // Allows for text to appead in TextFormField
                            padding: const EdgeInsets.only(top: 4.0),
                            child: TextFormField(
                              controller: _firstNameController,
                              focusNode: _focusNodes['firstName'],
                              decoration:
                                  const InputDecoration(labelText: 'Prénom'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Le prénom ne peut pas être vide';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) =>
                                  _focusNodes['lastName']!.requestFocus(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: TextFormField(
                              controller: _lastNameController,
                              focusNode: _focusNodes['lastName'],
                              decoration:
                                  const InputDecoration(labelText: 'Nom'),
                              onFieldSubmitted: (_) => _save(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Le nom ne peut pas être vide';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Text('Nom, prénom : ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              '${widget.user.firstName} ${widget.user.lastName}'),
                        ],
                      ),
                widget.editInformation
                    ? Column(
                        children: [
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            focusNode: _focusNodes['email'],
                            enabled: false,
                            decoration:
                                const InputDecoration(labelText: 'Courriel'),
                            onFieldSubmitted: (_) => _save(),
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            validator: Helpers.emailValidator,
                          )
                        ],
                      )
                    : Row(
                        children: [
                          Text('Courriel : ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(widget.user.email),
                        ],
                      ),
                widget.editInformation
                    ? SizedBox(height: 8)
                    : SizedBox.shrink(),
                widget.editInformation
                    ? StatefulBuilder(
                        builder: (context, setStateEmoji) => Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text('Mon avatar actuel : ',
                                      style: TextStyle(fontSize: 16)),
                                  Text(_avatarController.text,
                                      style: TextStyle(fontSize: 24)),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            EmojiHelpers.picker(onSelected: (emoji) {
                              _avatarController.text = emoji;
                              if (mounted) setStateEmoji(() {});
                            }),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          Text('Avatar : ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            widget.user.avatar,
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                if (widget.showEditableNotes)
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteController,
                        focusNode: _focusNodes['note'],
                        decoration: const InputDecoration(
                            labelText: 'Note privée sur l\'élève'),
                        onFieldSubmitted: (_) => _save(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        if (widget.onRemoveFromList != null)
          IconButton(
            onPressed: () async {
              final isSuccess = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        _passwordDialogSetState = setState;
                        return AreYouSureDialog(
                          title: 'Retirer de la liste',
                          content:
                              'Êtes-vous sûr de vouloir retirer cet élève de la liste d\'élèves inscrits à votre code d\'inscription ?\n'
                              'Cette action est irréversible.\n\n'
                              'Veuillez entrer votre mot de passe pour confirmer :',
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
                                onFieldSubmitted: (_) =>
                                    _validatePasswordDialogForm(),
                                validator: (value) => _passwordError,
                              ),
                            ),
                          ),
                          onCancelled: () {
                            if (mounted) Navigator.pop(context, false);
                          },
                          onConfirmed: _validatePasswordDialogForm,
                        );
                      },
                    );
                  });
              _passwordDialogSetState = null;
              if (context.mounted) Navigator.pop(context);
              if (isSuccess != true || !context.mounted) return;

              await widget.onRemoveFromList!(_password);
            },
            icon: const Icon(Icons.delete),
          ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary)),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text('Enregistrer',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }
}
