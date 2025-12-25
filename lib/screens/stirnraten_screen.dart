import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:provider/provider.dart';
import '../services/sound_service.dart';
import '../utils/sensor_helper.dart';
import '../data/words.dart';
import '../utils/theme.dart';
import '../widgets/animated_widgets.dart';

enum StirnratenGameState { setup, countdown, playing, result }

class StirnratenScreen extends StatefulWidget {
  const StirnratenScreen({super.key});

  @override
  State<StirnratenScreen> createState() => _StirnratenScreenState();
}

class _StirnratenScreenState extends State<StirnratenScreen> {
  StirnratenGameState _gameState = StirnratenGameState.setup;
  List<String> _currentWords = [];
  List<Map<String, dynamic>> _results = []; // {word: String, correct: bool}
  int _score = 0;
  int _timeLeft = 60;
  int _countdown = 3;
  Timer? _gameTimer;
  Timer? _countdownTimer;
  String _currentWord = "";
  
  // Sensor handling
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _canSkip = true;
  bool _neutralPosition = true;
  
  // Feedback
  Color? _feedbackColor;
  Timer? _feedbackTimer;
  
  // Tilt detection thresholds
  static const double _tiltThreshold = 7.0; // Gravity component on Z axis
  static const double _neutralThreshold = 7.0; // Gravity component on X axis (landscape)

  @override
  void dispose() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    _feedbackTimer?.cancel();
    _accelerometerSubscription?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _startCountdown(StirnratenCategory category) async {
    // Unlock audio context on user interaction
    context.read<SoundService>().unlock();

    // Request sensor permission (Web/iOS)
    await requestSensorPermission();

    // Force landscape for the game
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    setState(() {
      _currentWords = List.from(StirnratenData.getWords(category))..shuffle();
      _score = 0;
      _timeLeft = 60;
      _results = [];
      _countdown = 3;
      _gameState = StirnratenGameState.countdown;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        _startGame();
      }
    });
  }

  void _startGame() {
    setState(() {
      _gameState = StirnratenGameState.playing;
      _canSkip = true;
      _neutralPosition = true;
    });

    context.read<SoundService>().playStart();
    _nextWord();
    _startTimer();
    _startSensors();
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _startSensors() {
    // Try standard sensors_plus first
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      _processSensorData(event.x, event.y, event.z);
    });

    // Fallback for Web if sensors_plus returns 0s (common issue on some browsers/permissions)
    if (kIsWeb) {
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_gameState != StirnratenGameState.playing) {
          timer.cancel();
          return;
        }
        // Check if standard sensors are working (giving non-zero values)
        // If they are mostly 0, try the JS fallback
        // Note: We can't easily know if 0 is real or error, but exact 0.0 on all axes is rare in hand
        
        final webData = getWebAccelerometerData();
        // If we get data from JS, use it
        if (webData[0] != 0 || webData[1] != 0 || webData[2] != 0) {
           _processSensorData(webData[0], webData[1], webData[2]);
        }
      });
    }
  }

  void _processSensorData(double x, double y, double z) {
      if (_gameState != StirnratenGameState.playing) return;

      // Check for Neutral Position (Phone vertical on forehead)
      if (x.abs() > _neutralThreshold) {
        _neutralPosition = true;
      }

      if (!_canSkip || !_neutralPosition) return;

      // Check for Tilt
      if (x.abs() < 5.0) {
        // Face Down (Pass)
        if (z < -_tiltThreshold) {
          _neutralPosition = false;
          _handlePass();
        }
        // Face Up (Correct)
        else if (z > _tiltThreshold) {
          _neutralPosition = false;
          _handleCorrect();
        }
      }
  }

  void _nextWord() {
    if (_currentWords.isEmpty) {
      _endGame();
      return;
    }
    setState(() {
      _currentWord = _currentWords.removeLast();
    });
  }

  void _handleCorrect() {
    if (!_canSkip) return;
    _debounce();
    HapticFeedback.heavyImpact();
    
    context.read<SoundService>().playCorrect();
    
    setState(() {
      _score++;
      _results.add({'word': _currentWord, 'correct': true});
    });

    _showFeedback(Colors.green.withOpacity(0.8), onFinished: () {
      _nextWord();
    });
  }

  void _handlePass() {
    if (!_canSkip) return;
    _debounce();
    
    context.read<SoundService>().playWrong();
    
    setState(() {
      _results.add({'word': _currentWord, 'correct': false});
    });

    _showFeedback(Colors.red.withOpacity(0.8), onFinished: () {
      _nextWord();
    });
  }

  void _debounce() {
    _canSkip = false;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _canSkip = true);
    });
  }
  
  void _showFeedback(Color color, {VoidCallback? onFinished}) {
    setState(() => _feedbackColor = color);
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _feedbackColor = null);
        onFinished?.call();
      }
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _accelerometerSubscription?.cancel();
    context.read<SoundService>().playEnd();
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    setState(() {
      _gameState = StirnratenGameState.result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_gameState) {
      case StirnratenGameState.setup:
        return _buildSetup();
      case StirnratenGameState.countdown:
        return _buildCountdown();
      case StirnratenGameState.playing:
        return _buildGame();
      case StirnratenGameState.result:
        return _buildResult();
    }
  }
  
  Widget _buildCountdown() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$_countdown',
            style: const TextStyle(
              fontSize: 120,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Handy an die Stirn!',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetup() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_iphone, size: 64, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                'STIRNRATEN',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Wähle eine Kategorie:',
                style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 24),
              ...StirnratenCategory.values.map((category) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    text: StirnratenData.categoryNames[category]!,
                    onPressed: () => _startCountdown(category),
                    gradient: LinearGradient(
                      colors: [
                        _getCategoryColor(category),
                        _getCategoryColor(category).withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 40),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.5)),
                label: Text(
                  'Zurück zum Hauptmenü',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(StirnratenCategory category) {
    switch (category) {
      case StirnratenCategory.anime:
        return AppTheme.accentRed;
      case StirnratenCategory.starWars:
        return const Color(0xFFF1C40F);
      case StirnratenCategory.custom:
        return const Color(0xFF8E44AD);
    }
  }

  Widget _buildGame() {
    return Stack(
      children: [
        Container(color: AppTheme.primaryBlue),
        
        // Feedback Overlay
        if (_feedbackColor != null)
          Container(color: _feedbackColor),
        
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _handlePass,
                behavior: HitTestBehavior.translucent,
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Icon(Icons.close, size: 100, color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _handleCorrect,
                behavior: HitTestBehavior.translucent,
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Icon(Icons.check, size: 100, color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ),
            ),
          ],
        ),

        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _currentWord,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_timeLeft',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),

        const Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Text(
            'Links tippen: Passen  |  Rechts tippen: Richtig\nOder Gerät kippen!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Zeit abgelaufen!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              '$_score Punkte',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.accentOrange),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return ListTile(
                      leading: Icon(
                        result['correct'] ? Icons.check_circle : Icons.cancel,
                        color: result['correct'] ? AppTheme.accentGreen : AppTheme.accentRed,
                      ),
                      title: Text(
                        result['word'],
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Nochmal spielen',
                onPressed: () {
                  setState(() {
                    _gameState = StirnratenGameState.setup;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Zurück zum Hauptmenü',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

