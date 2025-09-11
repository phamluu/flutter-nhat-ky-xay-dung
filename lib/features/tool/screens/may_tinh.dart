import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _rawInput = ""; // biểu thức gốc để tính toán
  String _input = "";    // hiển thị có phân cách hàng nghìn
  String _result = "";

  void _onPressed(String value) {
    setState(() {
      if (value == "C") {
        _rawInput = "";
        _input = "";
        _result = "";
      } else if (value == "=") {
        _result = _calculate(_rawInput);
      } else {
        _rawInput += value;
        _updateInputDisplay();
      }
    });
  }

  void _updateInputDisplay() {
    final buffer = StringBuffer();
    final reg = RegExp(r'(\d+\.?\d*)|[+\-×÷]');
    final matches = reg.allMatches(_rawInput);
    for (final m in matches) {
      final s = m.group(0)!;
      if (RegExp(r'\d').hasMatch(s)) {
        buffer.write(NumberFormat("#,###").format(double.parse(s)));
      } else {
        buffer.write(s);
      }
    }
    _input = buffer.toString();
  }

  String _calculate(String input) {
    input = input.replaceAll("×", "*").replaceAll("÷", "/");
    try {
      Parser p = Parser();
      Expression exp = p.parse(input);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      // Nếu là số nguyên, định dạng có phân cách hàng nghìn
      if (eval == eval.toInt()) {
        return NumberFormat("#,###").format(eval.toInt());
      }

      // Nếu là số thập phân, giữ 2 chữ số sau dấu phẩy và phân cách hàng nghìn
      return NumberFormat("#,##0.##").format(eval);
    } catch (e) {
      return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(20),
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.black,
    );

    final List<String> buttons = [
      "7", "8", "9", "÷",
      "4", "5", "6", "×",
      "1", "2", "3", "-",
      "0", ".", "=", "+",
      "C"
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Máy tính"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_input, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 10),
                  Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 2,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                final btn = buttons[index];
                return ElevatedButton(
                  onPressed: () => _onPressed(btn),
                  style: buttonStyle,
                  child: Text(
                    btn,
                    style: const TextStyle(fontSize: 24),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
