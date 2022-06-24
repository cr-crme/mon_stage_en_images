import 'package:flutter/material.dart';

import '../../../common/models/student.dart';

class CompanyTile extends StatefulWidget {
  const CompanyTile({Key? key, required this.student}) : super(key: key);

  final Student? student;

  @override
  State<CompanyTile> createState() => _CompanyTileState();
}

class _CompanyTileState extends State<CompanyTile> {
  final _formKeyModifyCompany = GlobalKey<FormState>();

  var _isModifyingCompany = false;

  var _newCompanyName = "";

  void _modifyCompany() {
    _isModifyingCompany = true;

    setState(() {});
  }

  void _saveCompany() {
    _isModifyingCompany = false;

    setState(() {});

    _formKeyModifyCompany.currentState!.save();
    if (_newCompanyName == "") return;

    final student = ModalRoute.of(context)!.settings.arguments as Student;
    student.company.name = _newCompanyName;
  }

  @override
  Widget build(BuildContext context) {
    return widget.student == null
        ? Container()
        : ListTile(
            title: const Text('Nom de l\'entreprise :'),
            subtitle: _isModifyingCompany
                ? Form(
                    key: _formKeyModifyCompany,
                    child: TextFormField(
                      initialValue: widget.student!.company.toString(),
                      onSaved: (value) => _newCompanyName = value as String,
                    ),
                  )
                : Text(widget.student!.company.toString()),
            trailing: _isModifyingCompany
                ? IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveCompany,
                  )
                : IconButton(
                    icon: const Icon(Icons.mode),
                    onPressed: _modifyCompany,
                  ),
          );
  }
}
