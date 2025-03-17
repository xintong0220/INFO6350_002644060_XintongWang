import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:collection/collection.dart';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  int timeLeft = 60;
  late Timer timer;
  List<String> selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    loadQuestions();
    startTimer();
  }

  Future<void> loadQuestions() async {
    String data = await rootBundle.loadString('assets/questions.json');
    List jsonResult = json.decode(data);
    jsonResult.shuffle();
    setState(() {
      questions = jsonResult.take(10).toList();
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        t.cancel();
        endQuiz();
      }
    });
  }

  void answerQuestion(dynamic answer) {
    var correctAnswer = questions[currentQuestionIndex]['correct'];
    if (answer is List) {
      if (const ListEquality().equals(answer, correctAnswer)) {
        score++;
      }
    } else if (answer == correctAnswer) {
      score++;
    }

    setState(() {
      selectedAnswers.clear();
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        endQuiz();
      }
    });
  }

  void endQuiz() {
    timer.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(score: timeLeft > 0 ? score : 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var question = questions[currentQuestionIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Quiz App'), backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Time left: $timeLeft sec', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Question ${currentQuestionIndex + 1} of ${questions.length}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('(${question['type'] == 'truefalse' ? 'TRUE or FALSE' : question['type'].toUpperCase()} Question)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
            SizedBox(height: 10),
            Text(question['question'], style: TextStyle(fontSize: 22), textAlign: TextAlign.center),
            SizedBox(height: 20),
            ...buildOptions(question),
          ],
        ),
      ),
    );
  }

  List<Widget> buildOptions(question) {
    List options = question['options'];
    if (question['type'] == 'multiple') {
      return [
        ...options.map((option) {
          return CheckboxListTile(
            title: Text(option),
            value: selectedAnswers.contains(option),
            activeColor: Colors.blue,
            checkColor: Colors.white,
            tileColor: Colors.white,
            onChanged: (bool? selected) {
              setState(() {
                if (selected == true) {
                  selectedAnswers.add(option);
                } else {
                  selectedAnswers.remove(option);
                }
              });
            },
          );
        }).toList(),
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.blue),
          onPressed: () => answerQuestion(List.from(selectedAnswers)),
          child: Text('Submit'),
        )
      ];
    }
    return options.map((option) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.blue),
          onPressed: () => answerQuestion(option),
          child: Text(option, style: TextStyle(color: Colors.blue)),
        ),
      );
    }).toList();
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  ResultScreen({required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your Score: $score', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.blue),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => QuizScreen()),
                );
              },
              child: Text('Retry'),
            )
          ],
        ),
      ),
    );
  }
}
