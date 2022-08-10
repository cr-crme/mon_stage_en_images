import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class Speecher with ChangeNotifier {
  Speecher() {
    _initSpeech();
  }

  final _speechToText = SpeechToText();
  bool _speechEnabled = false;

  void _initSpeech() async {
    /// This has to happen only once per app
    _speechEnabled = await _speechToText.initialize();
  }

  void startListening(Function(String) onResult) async {
    if (!_speechEnabled) {
      onResult('Assistance vocale non disponible.');
      return;
    }

    await _speechToText.listen(
      listenMode: ListenMode.dictation,
      pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(seconds: 20),
      onResult: (SpeechRecognitionResult result) =>
          onResult(result.recognizedWords),
      partialResults: false,
    );
  }

  void stopListening() async {
    await _speechToText.stop();
  }
}
