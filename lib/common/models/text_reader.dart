import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';

import './answer.dart';
import './question.dart';

class TextReader {
  TextReader() {
    _initTts();
  }

  late final FlutterTts _textToSpeech;

  Future _initTts() async {
    _textToSpeech = FlutterTts();
    await _textToSpeech.awaitSpeakCompletion(true);
    await _textToSpeech.setVolume(1);
    await _textToSpeech.setSpeechRate(0.5);
    await _textToSpeech.setPitch(1);
  }

  Future stopReading() async {
    await _textToSpeech.stop();
  }

  Future read(Question question, Answer? answer,
      {required VoidCallback hasFinishedCallback}) async {
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
    for (final message in answer.discussion) {
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
