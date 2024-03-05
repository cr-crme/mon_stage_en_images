import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class Speecher with ChangeNotifier {
  Speecher() {
    _initSpeech();
  }

  final _speechToText = SpeechToText();
  bool _speechEnabled = false;
  VoidCallback? _onErrorUserCallback;

  void _initSpeech() async {
    try {
      /// This has to happen only once per app
      _speechEnabled =
          await _speechToText.initialize(onError: _onErrorCallback);
    } on PlatformException catch (_) {
      _speechEnabled = false;
    }
  }

  void _onErrorCallback(SpeechRecognitionError error) {
    if (_onErrorUserCallback == null) return;
    _onErrorUserCallback!();
  }

  void startListening(
      {required Function(String) onResultCallback,
      VoidCallback? onErrorCallback}) async {
    if (!_speechEnabled) {
      onResultCallback('Assistance vocale non disponible.');
      return;
    }

    _onErrorUserCallback = onErrorCallback;
    await _speechToText.listen(
      listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation, partialResults: false),
      pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(seconds: 20),
      onResult: (SpeechRecognitionResult result) =>
          onResultCallback(result.recognizedWords),
    );
  }

  void stopListening() async {
    await _speechToText.stop();
  }
}
