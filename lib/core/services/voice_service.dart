// ============================================
// VOICE SERVICE - SHOPPRO
// ============================================
// Wrapper pour la reconnaissance vocale
// Basé sur le package speech_to_text
// ============================================

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

class VoiceService {
  // ─────────────────────────────────────────────
  // SINGLETON
  // ─────────────────────────────────────────────
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _speech = SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  String? _errorMessage;

  // ─────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isAvailable => _speech.isAvailable;
  String get lastWords => _lastWords;
  String? get errorMessage => _errorMessage;

  // ─────────────────────────────────────────────
  // CALLBACKS (branchés depuis l'UI)
  // ─────────────────────────────────────────────
  Function(String words)? onResult;
  Function(String error)? onError;
  Function()? onDone;
  Function(double level)? onSoundLevelChange;

  // ─────────────────────────────────────────────
  // INITIALISATION
  // ─────────────────────────────────────────────
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onSpeechError,
        debugLogging: false,
      );
      return _isInitialized;
    } catch (e) {
      _errorMessage = 'Erreur d\'initialisation: $e';
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // DÉMARRER L'ÉCOUTE
  // ─────────────────────────────────────────────
  Future<bool> startListening({
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return false;
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      _errorMessage = null;
      _lastWords = '';
      _isListening = true;

      await _speech.listen(
        onResult: _onResult,
        localeId: localeId,
        listenFor: listenFor ?? const Duration(seconds: 30),
        pauseFor: pauseFor ?? const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
        onSoundLevelChange: (level) {
          onSoundLevelChange?.call(level);
        },
      );
      return true;
    } catch (e) {
      _isListening = false;
      _errorMessage = 'Erreur démarrage: $e';
      onError?.call(_errorMessage!);
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // ARRÊTER / ANNULER
  // ─────────────────────────────────────────────
  Future<void> stopListening() async {
    if (!_isListening) return;
    try {
      await _speech.stop();
    } catch (_) {}
    _isListening = false;
  }

  Future<void> cancelListening() async {
    if (!_isListening) return;
    try {
      await _speech.cancel();
    } catch (_) {}
    _isListening = false;
  }

  // ─────────────────────────────────────────────
  // CALLBACKS INTERNES
  // ─────────────────────────────────────────────
  void _onResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    onResult?.call(_lastWords);

    if (result.finalResult) {
      _isListening = false;
      onDone?.call();
    }
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    _isListening = false;
    _errorMessage = _errorMessageFromCode(error.errorMsg);
    onError?.call(_errorMessage!);
  }

  // ─────────────────────────────────────────────
  // TRADUCTION DES ERREURS
  // ─────────────────────────────────────────────
  String _errorMessageFromCode(String code) {
    switch (code) {
      case 'error_no_match':
        return 'Aucune parole détectée. Réessayez.';
      case 'error_speech_timeout':
        return 'Délai dépassé. Parlez plus près du micro.';
      case 'error_audio':
      case 'error_audio_error':
        return 'Erreur audio. Vérifiez votre micro.';
      case 'error_permission':
      case 'error_permission_denied':
        return 'Permission micro refusée.';
      case 'error_network':
        return 'Erreur réseau. Vérifiez votre connexion.';
      case 'error_busy':
        return 'Le micro est déjà utilisé.';
      default:
        return 'Erreur de reconnaissance vocale.';
    }
  }
}