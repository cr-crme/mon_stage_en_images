import './common/models/all_answers.dart';
import './common/models/answer.dart';
import './common/models/company.dart';
import './common/models/enum.dart';
import './common/models/message.dart';
import './common/models/question.dart';
import './common/models/student.dart';
import './common/providers/all_questions.dart';
import './common/providers/all_students.dart';

void prepareDummyData(AllStudents students, AllQuestions questions) {
  questions.add(Question('Photo 1',
      type: QuestionType.photo, section: 0, defaultTarget: Target.none));
  questions.add(Question('Texte 1',
      type: QuestionType.text, section: 0, defaultTarget: Target.none));
  questions.add(Question('Texte 2',
      type: QuestionType.text, section: 1, defaultTarget: Target.none));
  questions.add(Question('Photo 2',
      type: QuestionType.photo, section: 2, defaultTarget: Target.none));
  questions.add(Question('Photo 3',
      type: QuestionType.photo, section: 3, defaultTarget: Target.none));
  questions.add(Question('Photo 4',
      type: QuestionType.photo, section: 4, defaultTarget: Target.none));
  questions.add(Question('Photo 5',
      type: QuestionType.photo, section: 5, defaultTarget: Target.none));
  questions.add(Question('Texte 3',
      type: QuestionType.text, section: 5, defaultTarget: Target.none));
  questions.add(Question('Photo 6',
      type: QuestionType.photo, section: 5, defaultTarget: Target.none));

  final benjaminAnswers = AllAnswers(questions: questions);
  benjaminAnswers[questions.fromSection(0)[0]] =
      Answer(isActive: true, discussion: []);
  benjaminAnswers[questions.fromSection(0)[1]] =
      Answer(isActive: true, discussion: []);
  benjaminAnswers[questions.fromSection(1)[0]] =
      Answer(isActive: true, text: 'Ma réponse!', discussion: []);
  benjaminAnswers[questions.fromSection(5)[1]] =
      Answer(isActive: true, text: 'coucou', discussion: []);
  benjaminAnswers[questions.fromSection(5)[1]] =
      Answer(isActive: true, text: 'coucou2', discussion: []);
  benjaminAnswers[questions.fromSection(5)[2]] =
      Answer(isActive: true, text: 'coucou3', discussion: []);

  students.add(Student(
      firstName: 'Benjamin',
      lastName: 'Michaud',
      company: Company(name: 'Ici'),
      allAnswers: benjaminAnswers));

  final aurelieAnswers = AllAnswers(questions: questions);
  aurelieAnswers[questions.fromSection(5)[2]] = Answer(
      isActive: true,
      photoUrl: 'https://cdn.photographycourse.net/wp-content/uploads/2014/11/'
          'Landscape-Photography-steps.jpg',
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
      ]);
  aurelieAnswers[questions.fromSection(5)[1]] = Answer(
    isActive: true,
    discussion: [],
    text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
        'Praesent vel turpis quis augue efficitur dignissim sit amet '
        'vel sem. Orci varius natoque penatibus et magnis dis '
        'parturient montes, nascetur ridiculus mus. Aliquam erat '
        'volutpat. Quisque metus velit, lacinia ut lorem euismod, '
        'rhoncus maximus erat. Phasellus sapien leo, consectetur eget '
        'viverra id, molestie in leo. Nam vitae sapien augue. Nulla '
        'pulvinar, lorem sit amet bibendum feugiat, dui odio convallis '
        'ligula, nec dapibus velit mi a urna. Donec sit amet '
        'risus lacus.',
  );

  students.add(Student(
      firstName: 'Aurélie',
      lastName: 'Tondoux',
      company: Company(name: ''),
      allAnswers: aurelieAnswers));
}
