import 'package:flutter/material.dart';

class Huellision extends StatefulWidget {
  const Huellision({super.key});

  @override
  State<Huellision> createState() => _HuellisionState();
}

class HuellisionQuestion {
  final String word;
  final List<String> choices;
  final String correct;

  HuellisionQuestion({
    required this.word,
    required this.choices,
    required this.correct,
  });
}

class _HuellisionState extends State<Huellision> {
  int points = 0;
  int currentIndex = 0;
  String? selectedAnswer;

  final List<HuellisionQuestion> questions = [
    HuellisionQuestion(
      word: 'Boat',
      choices: ['Boat', 'Goat', 'Loot'],
      correct: 'Boat',
    ),
    HuellisionQuestion(
      word: 'Tree',
      choices: ['Free', 'Tree', 'Three'],
      correct: 'Tree',
    ),
    HuellisionQuestion(
      word: 'Star',
      choices: ['Scar', 'Star', 'Stay'],
      correct: 'Star',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Huellision',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('$points points', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              _buildCard(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.3),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 40, 50, 56),
            borderRadius: BorderRadius.circular(10),
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
    );
  }

  Widget _buildCard() {
    final question = questions[currentIndex];
    return Container(
      width: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff3c3f45),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'What is the word inside the circle',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildIshiharaCircle(question.word),
          const SizedBox(height: 20),
          const Text(
            'Choose your answer',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            alignment: WrapAlignment.center,
            children: question.choices.map(_answerButton).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff3c3f45),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: _submitAnswer,
      child: const Text(
        'Submit',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildIshiharaCircle(String word) {
    return Container(
      width: 170,
      height: 170,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xff1b5e20),
      ),
      alignment: Alignment.center,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children:
              word.split('').map((letter) {
                return TextSpan(
                  text: letter,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade400,
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _answerButton(String text) {
    final isSelected = selectedAnswer == text;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : const Color(0xff4a4d52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: () => setState(() => selectedAnswer = text),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  void _submitAnswer() {
    if (selectedAnswer == null) return;

    if (selectedAnswer == questions[currentIndex].correct) points += 1;

    setState(() {
      selectedAnswer = null;
      currentIndex = (currentIndex + 1) % questions.length;
    });
  }
}
