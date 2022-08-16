// import './common/models/all_answers.dart';
// import './common/models/company.dart';
// import './common/models/enum.dart';
// import './common/models/question.dart';
// import './common/models/student.dart';
import './common/providers/all_questions.dart';
import './common/providers/all_students.dart';

void prepareDummyData(AllStudents students, AllQuestions questions) {
  // questions.add(Question('Photo 1', section: 0, defaultTarget: Target.all));
  // questions.add(Question('Texte 1', section: 0, defaultTarget: Target.none));
  // questions.add(Question('Texte 2', section: 1, defaultTarget: Target.none));
  // questions.add(Question('Photo 2', section: 2, defaultTarget: Target.none));
  // questions.add(Question('Photo 3', section: 3, defaultTarget: Target.none));
  // questions.add(Question('Photo 4', section: 4, defaultTarget: Target.none));
  // questions.add(Question('Photo 5', section: 5, defaultTarget: Target.none));
  // questions.add(Question('Texte 3', section: 5, defaultTarget: Target.all));
  // questions.add(Question('Photo 6', section: 5, defaultTarget: Target.all));

  // students.add(Student(
  //     firstName: 'Benjamin',
  //     lastName: 'Michaud',
  //     company: Company(name: 'Ici'),
  //     allAnswers: AllAnswers(questions: questions.toList(growable: false))));

  // students.add(Student(
  //     firstName: 'Aurélie',
  //     lastName: 'Tondoux',
  //     company: Company(name: 'Coucou'),
  //     allAnswers: AllAnswers(questions: questions.toList(growable: false))));

  // benjaminAnswers[questions.fromSection(0)[1]] =
  //     Answer(actionRequired: ActionRequired.fromStudent);
  // benjaminAnswers[questions.fromSection(1)[0]] =
  //     Answer(actionRequired: ActionRequired.fromTeacher);
  // benjaminAnswers[questions.fromSection(5)[1]] =
  //     Answer(actionRequired: ActionRequired.fromStudent);
  // benjaminAnswers[questions.fromSection(5)[1]] = Answer(isValidated: true);
  // benjaminAnswers[questions.fromSection(5)[2]] =
  //     Answer(actionRequired: ActionRequired.fromTeacher);

  // aurelieAnswers[questions.fromSection(5)[2]] = Answer(
  //     actionRequired: ActionRequired.fromTeacher,
  //     discussion: Discussion.fromList([
  //       Message(name: 'Prof', text: 'Coucou'),
  //       Message(name: 'Aurélie', text: 'Non pas coucou'),
  //       Message(name: 'Prof', text: 'Coucou'),
  //       Message(
  //           name: 'Aurélie',
  //           text:
  //               'https://cdn.photographycourse.net/wp-content/uploads/2014/11/'
  //               'Landscape-Photography-steps.jpg',
  //           isPhotoUrl: true),
  //       Message(name: 'Prof', text: 'Coucou'),
  //       Message(name: 'Aurélie', text: 'Non pas coucou'),
  //       Message(name: 'Prof', text: 'Coucou'),
  //       Message(name: 'Aurélie', text: 'Non pas coucou'),
  //       Message(name: 'Prof', text: 'Coucou'),
  //       Message(name: 'Aurélie', text: 'Non pas coucou'),
  //       Message(name: 'Prof', text: 'Coucou'),
  //       Message(
  //           name: 'Aurélie',
  //           text:
  //               'https://cdn.photographycourse.net/wp-content/uploads/2014/11/'
  //               'Landscape-Photography-steps.jpg',
  //           isPhotoUrl: true),
  //       Message(name: 'Prof', text: 'Coucou'),
  //       Message(name: 'Aurélie', text: 'Non pas coucou'),
  //       Message(name: 'Prof', text: 'Coucou'),
  //       Message(name: 'Aurélie', text: 'Non pas coucou'),
  //       Message(name: 'Prof', text: 'Coucou'),
  //       Message(name: 'Aurélie', text: 'Non pas coucou'),
  //     ]));
  // aurelieAnswers[questions.fromSection(5)[1]] = Answer(isValidated: true);
}
