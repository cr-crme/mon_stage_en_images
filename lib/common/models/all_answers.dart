import 'package:defi_photo/crcrme_enhanced_containers/lib/map_serializable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './answer.dart';
import './enum.dart';
import './exceptions.dart';
import '../providers/all_questions.dart';
import '../providers/login_information.dart';

class AllAnswers extends MapSerializable<Answer> {
  // Constructors and (de)serializer
  AllAnswers({required AllQuestions questions}) : super() {
    for (var question in questions) {
      this[question] = Answer(isActive: false);
    }
  }
  AllAnswers.fromSerialized(map) : super.fromSerialized(map);

  @override
  Answer deserializeItem(map) {
    return Answer.fromSerialized(map);
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

  AllAnswers fromQuestions(AllQuestions questions) {
    var out = AllAnswers(questions: AllQuestions());
    for (var question in questions) {
      out[question] = this[question]!;
    }
    return out;
  }

  AllQuestions activeQuestions(AllQuestions questions) {
    var out = AllQuestions();
    for (var question in questions) {
      if (this[question]!.isActive) out.add(question);
    }
    return out;
  }

  AllAnswers activeAnswers(AllQuestions questions) {
    var out = AllAnswers(questions: AllQuestions());
    for (var question in questions) {
      final answer = this[question]!;
      if (answer.isActive) out[question] = answer;
    }
    return out;
  }

  AllQuestions answeredQuestions(AllQuestions questions,
      {bool shouldBeActive = true, bool skipIfValidated = false}) {
    var out = AllQuestions();
    for (var question in questions) {
      final answer = this[question]!;
      final activeState =
          !shouldBeActive || (shouldBeActive && answer.isActive);
      final shouldSkipIfValidated = !skipIfValidated || !answer.isValidated;
      if (activeState && answer.isAnswered && shouldSkipIfValidated) {
        out.add(question);
      }
    }
    return out;
  }

  AllQuestions unansweredQuestions(AllQuestions questions,
      {bool shouldBeActive = true}) {
    var out = AllQuestions();
    for (var question in questions) {
      final answer = this[question]!;
      var activeState = !shouldBeActive || (shouldBeActive && answer.isActive);
      if (activeState && !answer.isAnswered) out.add(question);
    }
    return out;
  }

  AllQuestions inactiveQuestions(AllQuestions questions) {
    var out = AllQuestions();
    for (var question in questions) {
      final answer = this[question]!;
      if (!answer.isActive) out.add(question);
    }
    return out;
  }
}
