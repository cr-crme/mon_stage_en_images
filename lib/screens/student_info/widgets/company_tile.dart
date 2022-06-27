import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/models/enum.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_students.dart';
import '../../../common/providers/login_information.dart';

class CompanyTile extends StatefulWidget {
  const CompanyTile({Key? key, required this.studentId}) : super(key: key);

  final String? studentId;

  @override
  State<CompanyTile> createState() => _CompanyTileState();
}

class _CompanyTileState extends State<CompanyTile> {
  final _formKeyModifyCompany = GlobalKey<FormState>();

  var _isModifyingCompany = false;

  var _newCompanyName = '';

  void _modifyCompany() {
    _isModifyingCompany = true;

    setState(() {});
  }

  void _saveCompany() {
    _isModifyingCompany = false;

    _formKeyModifyCompany.currentState!.save();
    if (_newCompanyName == '') return;

    final allStudents = Provider.of<AllStudents>(context, listen: false);
    final student = ModalRoute.of(context)!.settings.arguments as Student;
    final newCompany = student.company.copyWith(name: _newCompanyName);
    final newStudent = student.copyWith(company: newCompany);
    allStudents.replace(newStudent);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userIsStudent =
        Provider.of<LoginInformation>(context, listen: false).loginType ==
            LoginType.student;
    return widget.studentId == null
        ? Container()
        : ListTile(
            title: const Text('Nom de l\'entreprise :'),
            subtitle: Consumer<AllStudents>(
              builder: (context, students, child) {
                final student = students[widget.studentId];
                return _isModifyingCompany
                    ? Form(
                        key: _formKeyModifyCompany,
                        child: TextFormField(
                          initialValue: student.company.toString(),
                          onSaved: (value) => _newCompanyName = value as String,
                        ),
                      )
                    : Text(student.company.toString());
              },
            ),
            trailing: userIsStudent
                ? null
                : _isModifyingCompany
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
