import 'dart:async';
import 'package:flutter/material.dart';

class Huehunt extends StatefulWidget {
  const Huehunt({super.key});

  @override
  State<Huehunt> createState() => _HuehuntState();
}

class _HuehuntState extends State<Huehunt> {
  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.green,
  ];

  List<int> _revealed = [];
  List<int> _matched = [];
  bool _memorizing = true;

  Timer? _timer;
  int _timeLeft = 63;
  int _stage = 1;

  @override
  void initState() {
    super.initState();
    _startStage();
  }

  // ───── STAGE LOGIC ─────
  void _startStage() {
    _timer?.cancel(); // FIX: cancel old timer

    _matched.clear();
    _revealed.clear();
    _memorizing = true;

    _colors.shuffle();

    // Show all cards (memorization phase)
    _revealed = List.generate(_colors.length, (i) => i);
    if (mounted) setState(() {}); // FIX

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; // FIX

      _revealed.clear();
      _memorizing = false;
      _startTimer();
      setState(() {});
    });
  }

  // ───── TIMER ─────
  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 63;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel(); // FIX
        return;
      }

      if (_timeLeft == 0) {
        timer.cancel();
        _showGameOver();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  // ───── GAME LOGIC ─────
  void _onCardTap(int index) {
    if (_memorizing || _revealed.contains(index) || _matched.contains(index))
      return;

    setState(() => _revealed.add(index));

    if (_revealed.length == 2) {
      final a = _revealed[0];
      final b = _revealed[1];

      if (_colors[a] == _colors[b]) {
        _matched.addAll(_revealed);
        _revealed.clear();

        if (_matched.length == _colors.length) {
          _timer?.cancel();
          Future.delayed(const Duration(milliseconds: 700), () {
            if (!mounted) return; // FIX
            _nextStage();
          });
        }
      } else {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return; // FIX
          setState(() => _revealed.clear());
        });
      }
    }
  }

  // ───── STAGE CAP (10) ─────
  void _nextStage() {
    if (_stage < 10) {
      setState(() {
        _stage++;
        _startStage();
      });
    } else {
      _timer?.cancel();
      _showWin();
    }
  }

  void _showWin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text("You Win! 🎉"),
            content: const Text("You completed all 10 stages!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _restartGame();
                },
                child: const Text("Restart"),
              ),
            ],
          ),
    );
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text("Time's up!"),
            content: Text("You reached Stage $_stage"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _restartGame();
                },
                child: const Text("Restart"),
              ),
            ],
          ),
    );
  }

  void _restartGame() {
    _timer?.cancel();
    setState(() {
      _stage = 1;
      _startStage();
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel(); // FIX
    super.dispose();
  }

  // ───── UI ─────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ───── APP BAR ─────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.3),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 40, 50, 56),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Image.asset('assets/logo/LogoKly.png', width: 28, height: 28),
            const SizedBox(height: 4),
            const Text(
              "KULAIDOVERSE",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.person_outline, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Hue-Hunt",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text("Stage $_stage"),
          Text("Remaining Time ${_formatTime(_timeLeft)}"),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              width: 300,
              decoration: BoxDecoration(
                color: const Color(0xff2f2f2f),
                borderRadius: BorderRadius.circular(20),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: _colors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (_, index) {
                  final visible =
                      _revealed.contains(index) || _matched.contains(index);
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: visible ? _colors[index] : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          visible
                              ? null
                              : Center(
                                child: Image.asset(
                                  'images/LogoKly.png',
                                  width: 24,
                                ),
                              ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
