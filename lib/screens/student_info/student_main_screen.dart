import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/models/company.dart';
import '../../common/models/student.dart';
import '../../common/providers/all_question_lists.dart';
import '../../common/widgets/section_tile_in_student.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({Key? key}) : super(key: key);

  static const routeName = '/student-main-screen';

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  @override
  Widget build(BuildContext context) {
    final student = ModalRoute.of(context)!.settings.arguments as Student;

    return Consumer<AllQuestionList>(
      builder: (context, questions, child) => Scaffold(
        appBar: AppBar(
          title: Text(student.toString()),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            _buildCompanyTile(student),
            const Divider(),
            SectionTileInStudent(questions[0], 0),
            SectionTileInStudent(questions[1], 1),
            SectionTileInStudent(questions[2], 2),
            SectionTileInStudent(questions[3], 3),
            SectionTileInStudent(questions[4], 4),
            SectionTileInStudent(questions[5], 5),
          ]),
        ),
      ),
    );
  }

  ListTile _buildCompanyTile(Student student) {
    return ListTile(
      title: const Text(
        'Nom de l\'entreprise :',
      ),
      subtitle: _isModifyingCompany
          ? Form(
              key: _formKeyModifyCompany,
              child: TextFormField(
                initialValue:
                    student.company == null ? '' : student.company.toString(),
                onSaved: (value) => _newCompanyName = value as String,
              ),
            )
          : Text(
              student.company == null ? '' : '${student.company}',
            ),
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
    student.company = Company(name: _newCompanyName);
  }
}
