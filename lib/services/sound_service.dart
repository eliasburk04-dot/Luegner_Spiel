import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  // Volume settings
  static const double _volCorrect = 1.0;
  static const double _volWrong = 0.8;
  static const double _volStart = 0.8;
  static const double _volEnd = 0.75;

  SoundService() {
    // Configure the audio context for better mobile experience
    _initAudioContext();
  }

  Future<void> _initAudioContext() async {
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  /// Call this from a user gesture (e.g. button click) to unlock audio on Web
  Future<void> unlock() async {
    if (kIsWeb) {
      // Play start sound at very low volume (but not 0) to unlock audio context
      // We do NOT stop it immediately. We let it play.
      // The next real sound will stop this one automatically.
      await _player.setVolume(0.01);
      await _player.play(AssetSource('sounds/start.wav'));
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _player.stop();
    }
  }

  Future<void> _playSound(String fileName, double volume) async {
    if (_isMuted) return;

    try {
      // Stop any currently playing sound to prevent overlap
      await _player.stop();
      
      await _player.setVolume(volume);
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound $fileName: $e');
      }
    }
  }

  Future<void> playStart() async {
    await _playSound('start.wav', _volStart);
  }

  Future<void> playCorrect() async {
    await _playSound('correct.wav', _volCorrect);
  }

  Future<void> playWrong() async {
    await _playSound('wrong.wav', _volWrong);
  }

  Future<void> playEnd() async {
    await _playSound('end.wav', _volEnd);
  }

  void dispose() {
    _player.dispose();
  }
}
