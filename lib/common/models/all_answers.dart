import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../providers/login_information.dart';
import 'answer.dart';
import 'enum.dart';
import 'exceptions.dart';

class AllAnswers extends MapSerializable<Answer> {
  // Constructors and (de)serializer
  AllAnswers({required List<Question> questions}) {
    for (var question in questions) {
      this[question] = Answer(isActive: false);
    }
  }
  AllAnswers.fromSerialized(map) : super.fromSerialized(map);

  @override
  Answer deserializeItem(data) {
    return Answer.fromSerialized(data);
  }

  // Attributes and methods
  int get number => length;
  int get numberActive {
    int active = 0;
    forEach((answer) {
      if (answer.value.isActive) active++;
    });
    return active;
  }

  int get numberAnswered {
    int answered = 0;
    forEach((answer) {
      if (answer.value.isAnswered) answered++;
    });
    return answered;
  }

  @override
  Answer? operator [](key) {
    // Add the answer to the pool if it does not exist
    if (super[key] == null) {
      super[key] = Answer(
          actionRequired: ActionRequired.fromStudent,
          isActive: key.defaultTarget == Target.all);
    }

    return super[key];
  }

  int numberOfActionsRequired(BuildContext context) {
    final loginType =
        Provider.of<LoginInformation>(context, listen: false).loginType;
    if (loginType == LoginType.student) {
      return numberNeedStudentAction(context);
    } else if (loginType == LoginType.teacher) {
      return numberNeedTeacherAction(context);
    } else {
      throw const NotLoggedIn();
    }
  }

  int numberNeedTeacherAction(BuildContext context) {
    int number = 0;
    forEach((answer) {
      if (answer.value.action(context) == ActionRequired.fromTeacher) {
        number++;
      }
    });
    return number;
  }

  int numberNeedStudentAction(BuildContext context) {
    int number = 0;
    forEach((answer) {
      if (answer.value.action(context) == ActionRequired.fromStudent) {
        number++;
      }
    });
    return number;
  }

  AllAnswers fromQuestions(List<Question> questions) {
    var out = AllAnswers(questions: []);
    for (var question in questions) {
      out[question] = this[question]!;
    }
    return out;
  }

  List<Question> activeQuestions(List<Question> questions,
      {bool shouldBeActive = true, bool skipIfValidated = false}) {
    List<Question> out = questions.where((question) {
      final answer = this[question]!;
      final activeState =
          !shouldBeActive || (shouldBeActive && answer.isActive);
      final shouldSkipIfValidated = !skipIfValidated || !answer.isValidated;
      return activeState && shouldSkipIfValidated;
    }).toList(growable: false);
    return out;
  }

  AllAnswers activeAnswers(List<Question> questions) {
    var out = AllAnswers(questions: []);
    for (var question in questions) {
      final answer = this[question]!;
      if (answer.isActive) out[question] = answer;
    }
    return out;
  }

  List<Question> answeredQuestions(List<Question> questions,
      {bool shouldBeActive = true, bool skipIfValidated = false}) {
    List<Question> out = questions.where((question) {
      final answer = this[question]!;
      final activeState =
          !shouldBeActive || (shouldBeActive && answer.isActive);
      final shouldSkipIfValidated = !skipIfValidated || !answer.isValidated;
      return activeState && answer.isAnswered && shouldSkipIfValidated;
    }).toList(growable: false);
    return out;
  }

  List<Question> unansweredQuestions(List<Question> questions,
      {bool shouldBeActive = true}) {
    List<Question> out = questions.where((question) {
      final answer = this[question]!;
      final activeState =
          !shouldBeActive || (shouldBeActive && answer.isActive);
      return activeState && !answer.isAnswered;
    }).toList(growable: false);
    return out;
  }

  List<Question> inactiveQuestions(List<Question> questions) {
    List<Question> out = questions.where((question) {
      final answer = this[question]!;
      return !answer.isActive;
    }).toList(growable: false);
    return out;
  }
}
