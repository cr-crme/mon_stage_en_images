import 'package:defi_photo/common/models/message.dart';

import 'common/models/all_answer.dart';
import './common/models/answer.dart';
import './common/models/company.dart';
import './common/models/question.dart';
import './common/models/student.dart';
import './common/providers/all_question_lists.dart';
import './common/providers/students.dart';

void prepareDummyData(Students students, AllQuestionList questions) {
  questions[0].add(Question('Photo 1?', needPhoto: true, needText: false));
  questions[1].add(Question('Photo 2?', needPhoto: true, needText: false));
  questions[2].add(Question('Photo 3?', needPhoto: true, needText: false));
  questions[3].add(Question('Photo 4?', needPhoto: true, needText: false));
  questions[4].add(Question('Photo 5?', needPhoto: true, needText: false));
  questions[5].add(Question('Photo 6?', needPhoto: true, needText: false));
  questions[5].add(Question('Texte 1?', needPhoto: false, needText: true));
  questions[5]
      .add(Question('Photo et texte 1?', needPhoto: true, needText: true));

  final benjaminAnswers = AllAnswer();
  benjaminAnswers
      .add(Answer(isActive: true, question: questions[0][0]!, discussion: []));
  benjaminAnswers
      .add(Answer(isActive: true, question: questions[5][0]!, discussion: []));
  benjaminAnswers.add(Answer(
      isActive: true,
      text: 'coucou',
      question: questions[5][1]!,
      discussion: []));
  benjaminAnswers.add(Answer(
      isActive: true,
      text: 'coucou2',
      question: questions[5][1]!,
      discussion: []));
  benjaminAnswers.add(Answer(
      isActive: true,
      text: 'coucou3',
      question: questions[5][2]!,
      discussion: []));

  students.add(Student(
      firstName: 'Benjamin',
      lastName: 'Michaud',
      company: Company(name: 'Ici'),
      allAnswers: benjaminAnswers));

  final aurelieAnswers = AllAnswer();
  aurelieAnswers.add(Answer(
      isActive: true,
      photoUrl: 'https://cdn.photographycourse.net/wp-content/uploads/2014/11/'
          'Landscape-Photography-steps.jpg',
      text:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vel turpis quis augue efficitur dignissim sit amet vel sem. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aliquam erat volutpat. Quisque metus velit, lacinia ut lorem euismod, rhoncus maximus erat. Phasellus sapien leo, consectetur eget viverra id, molestie in leo. Nam vitae sapien augue. Nulla pulvinar, lorem sit amet bibendum feugiat, dui odio convallis ligula, nec dapibus velit mi a urna. Donec sit amet risus lacus.',
      question: questions[5][2]!,
      discussion: [
        Message(name: 'Prof', text: 'Coucou'),
        Message(name: 'Aurélie', text: 'Non pas coucou'),
        Message(name: 'Prof', text: 'Coucou'),
        Message(name: 'Aurélie', text: 'Non pas coucou'),
        Message(name: 'Prof', text: 'Coucou'),
        Message(name: 'Aurélie', text: 'Non pas coucou'),
        Message(name: 'Prof', text: 'Coucou'),
        Message(name: 'Aurélie', text: 'Non pas coucou'),
        Message(name: 'Prof', text: 'Coucou'),
        Message(name: 'Aurélie', text: 'Non pas coucou'),
        Message(name: 'Prof', text: 'Coucou'),
        Message(name: 'Aurélie', text: 'Non pas coucou'),
        Message(name: 'Prof', text: 'Coucou'),
        Message(name: 'Aurélie', text: 'Non pas coucou'),
        Message(name: 'Prof', text: 'Coucou'),
        Message(name: 'Aurélie', text: 'Non pas coucou'),
        Message(name: 'Prof', text: 'Coucou'),
        Message(name: 'Aurélie', text: 'Non pas coucou'),
      ]));

  students.add(Student(
      firstName: 'Aurélie',
      lastName: 'Tondoux',
      company: Company(name: null),
      allAnswers: aurelieAnswers));
}
