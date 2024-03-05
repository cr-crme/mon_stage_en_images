import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'answer.dart';
import 'question.dart';

class TextReader {
  TextReader() {
    _initTts();
  }

  late final FlutterTts _textToSpeech;
  bool _isInitialized = false;

  Future _initTts() async {
    _textToSpeech = FlutterTts();

    if ((await _textToSpeech.getLanguages).contains('fr-FR')) {
      await _textToSpeech.setLanguage('fr-FR');
    }
    await _textToSpeech.awaitSpeakCompletion(true);
    await _textToSpeech.setVolume(1);
    await _textToSpeech.setSpeechRate(0.5);
    await _textToSpeech.setPitch(1);
    _isInitialized = true;
  }

  Future stopReading() async {
    await _textToSpeech.stop();
  }

  Future readText(String text,
      {required VoidCallback hasFinishedCallback}) async {
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 1));
    }
    await _textToSpeech.speak(text);
    hasFinishedCallback();
  }

  Future read(Question question, Answer? answer,
      {required VoidCallback hasFinishedCallback}) async {
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 1));
    }
    await _textToSpeech.speak('La question est');
    await _textToSpeech.speak(question.text);

    int imageCounter = 1;
    if (answer == null) {
      hasFinishedCallback();
      return;
    }
    if (answer.discussion.isEmpty) {
      await _textToSpeech.speak('Il n\'y a aucune réponse.');
      hasFinishedCallback();
      return;
    }

    await _textToSpeech.speak(answer.discussion.length == 1
        ? 'La réponse est : '
        : 'Les réponses sont : ');

    // We make a copy of the discussion
    // so if it changes while reading, it won't crash
    List<String> discussion = [];
    for (final message in answer.discussion.toListByTime(reversed: true)) {
      discussion.add(message.name);
      if (message.isPhotoUrl) {
        discussion.add('Photo $imageCounter de l\'élève.');
        imageCounter++;
      } else {
        discussion.add(message.text);
      }
    }

    for (final message in discussion) {
      await _textToSpeech.speak(message);
    }
    hasFinishedCallback();
  }
}
