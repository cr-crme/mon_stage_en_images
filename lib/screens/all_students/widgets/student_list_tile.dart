import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/helpers/route_manager.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/common/providers/all_answers.dart';
import 'package:mon_stage_en_images/common/providers/database.dart';
import 'package:mon_stage_en_images/common/widgets/avatar_tab.dart';
import 'package:mon_stage_en_images/common/widgets/taking_action_notifier.dart';
import 'package:mon_stage_en_images/default_onboarding_steps.dart';
import 'package:mon_stage_en_images/onboarding/onboarding.dart';
import 'package:provider/provider.dart';

class StudentListTile extends StatelessWidget {
  const StudentListTile(
    this.studentId, {
    super.key,
    required this.modifyStudentCallback,
    this.isOnboarding = false,
  });

  final Function(User) modifyStudentCallback;
  final String studentId;
  final bool isOnboarding;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final currentUser = database.currentUser;

    final student = isOnboarding
        ? OnboardingContexts.instance.dummyStudent
        : database.students.firstWhereOrNull((e) => e.id == studentId);

    final allAnswers =
        AllAnswers.of(context, listen: false).filter(studentIds: [studentId]);
    final numberOfActions =
        AllAnswers.numberNeedTeacherActionFrom(allAnswers, context);

    return Card(
      elevation: 5,
      child: ListTile(
        title: Row(
          children: [
            if (student != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: AvatarTab(user: student),
              ),
            Expanded(
              child: Text(student?.toString() ?? '',
                  style: const TextStyle(fontSize: 20)),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                student?.id != null
                    ? currentUser?.studentNotes[student!.id] ?? ''
                    : '',
                style: const TextStyle(fontSize: 16)),
            Text(
                'Questions répondues : ${AllAnswers.numberAnsweredFrom(allAnswers)} '
                '/ ${AllAnswers.numberActiveFrom(allAnswers)}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TakingActionNotifier(
              number: numberOfActions == 0 ? null : numberOfActions,
              padding: 10,
              borderColor: Colors.black,
              child: const Text(""),
            ),
            OnboardingContainer(
              onInitialize: (context) => OnboardingContexts
                  .instance['more_options_student_button'] = context,
              child: IconButton(
                  onPressed: () {
                    if (student == null) return;
                    modifyStudentCallback(student);
                  },
                  icon: Icon(Icons.more_horiz)),
            )
          ],
        ),
        onTap: () => RouteManager.instance.gotoQAndAPage(context,
            target: Target.individual,
            pageMode: PageMode.editableView,
            student: student,
            pushOnStack: true),
        onLongPress: () {
          if (student == null) return;
          modifyStudentCallback(student);
        },
      ),
    );
  }
}
