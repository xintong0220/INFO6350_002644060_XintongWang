import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String output = "";
  String expression = "";
  bool isNewCalculation = false;

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        output = "";
        expression = "";
        isNewCalculation = false;
      } else if (buttonText == "=") {
        try {
          output = evaluateExpression(expression);
          expression = output;
          isNewCalculation = true;
        } catch (e) {
          output = "Error";
          expression = "";
        }
      } else {
        if (isNewCalculation && RegExp(r'[0-9]').hasMatch(buttonText)) {
          expression = buttonText;
          isNewCalculation = false;
        } else {
          expression += buttonText;
        }
        output = expression;
      }
    });
  }

  String evaluateExpression(String expr) {
    try {
      expr = expr.replaceAll("x", "*");
      Parser p = Parser();
      Expression exp = p.parse(expr);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      return result % 1 == 0 ? result.toInt().toString() : result.toString();
    } catch (e) {
      return "Error";
    }
  }

  Widget buildButton(String text, Color color) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => buttonPressed(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(32),
              child: Text(
                output.isEmpty ? "0" : output,
                style: TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
          ),
          Column(
            children: [
              buildRow(["7", "8", "9", "x"], [Colors.white, Colors.white, Colors.white, Colors.grey]),
              buildRow(["4", "5", "6", "/"], [Colors.white, Colors.white, Colors.white, Colors.grey]),
              buildRow(["1", "2", "3", "+"], [Colors.white, Colors.white, Colors.white, Colors.grey]),
              buildRow(["=", "0", "C", "-"], [Colors.orange, Colors.white, Colors.grey, Colors.grey]),
            ],
          )
        ],
      ),
    );
  }

  Widget buildRow(List<String> texts, List<Color> colors) {
    return Row(
      children: List.generate(
        texts.length,
        (index) => buildButton(texts[index], colors[index]),
      ),
    );
  }
}
