import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jeevan_vigyan/constants/colors.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

// Helper function to convert numbers to Nepali
String _convertToNepali(String number) {
  const Map<String, String> nepaliNumbers = {
    '0': '०',
    '1': '१',
    '2': '२',
    '3': '३',
    '4': '४',
    '5': '५',
    '6': '६',
    '7': '७',
    '8': '८',
    '9': '९',
  };
  return number.replaceAllMapped(RegExp(r'[0-9]'), (match) {
    return nepaliNumbers[match.group(0)!]!;
  });
}

// Helper function to convert Nepali numbers to English
String _convertNepaliToEnglish(String nepaliNumber) {
  const Map<String, String> englishNumbers = {
    '०': '0',
    '१': '1',
    '२': '2',
    '३': '3',
    '४': '4',
    '५': '5',
    '६': '6',
    '७': '7',
    '८': '8',
    '९': '9',
  };
  return nepaliNumber.replaceAllMapped(RegExp(r'[०-९]'), (match) {
    return englishNumbers[match.group(0)!]!;
  });
}

class CalculatorPage extends StatefulWidget {
  final VoidCallback onBackToHome;
  const CalculatorPage({super.key, required this.onBackToHome});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _output = "०"; // Displayed output (Nepali numbers)
  String _currentInput = "0"; // Current number being entered (English numbers)
  String _operand = ""; // + - * /
  double _result = 0.0;
  bool _isOperandPressed = false;

  NepaliDateTime _currentNepaliDate = NepaliDateTime.now();

  void _onButtonPressed(String buttonText) {
    setState(() {
      // Convert Nepali numerals from button to English for internal logic
      final String englishButtonText = _convertNepaliToEnglish(buttonText);

      if (buttonText == "C") {
        _output = "०";
        _currentInput = "0";
        _result = 0.0;
        _operand = "";
        _isOperandPressed = false;
      } else if (buttonText == "⌫") {
        if (_currentInput.isNotEmpty && _currentInput != "0") {
          _currentInput = _currentInput.substring(0, _currentInput.length - 1);
          if (_currentInput.isEmpty) _currentInput = "0";
        }
        _output = _convertToNepali(_currentInput);
      } else if (buttonText == "+/-") {
        try {
          double val = double.parse(_currentInput);
          _currentInput = (-val).toString();
          _output = _convertToNepali(_currentInput);
        } on FormatException {
          // Do nothing or reset
        }
      } else if (buttonText == "%") {
        try {
          double val = double.parse(_currentInput);
          _currentInput = (val / 100).toString();
          _output = _convertToNepali(_currentInput);
        } on FormatException {
          // Do nothing or reset
        }
      } else if (buttonText == "=") {
        if (_isOperandPressed) {
          try {
            double num2 = double.parse(_currentInput);
            if (_operand == "+") {
              _result += num2;
            } else if (_operand == "-") {
              _result -= num2;
            } else if (_operand == "×") {
              _result *= num2;
            } else if (_operand == "÷") {
              _result /= num2;
            }
            _output = _convertToNepali(_formatResult(_result.toString()));
            _currentInput = _result.toString();
            _isOperandPressed = false;
            _operand = "";
          } on FormatException {
            _output = "त्रुटि";
            _currentInput = "0";
          }
        }
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "×" ||
          buttonText == "÷") {
        if (_isOperandPressed) {
          try {
            double num2 = double.parse(_currentInput);
            if (_operand == "+") {
              _result += num2;
            } else if (_operand == "-") {
              _result -= num2;
            } else if (_operand == "×") {
              _result *= num2;
            } else if (_operand == "÷") {
              _result /= num2;
            }
            _operand = buttonText;
            _currentInput = "0";
            _output = _convertToNepali(_formatResult(_result.toString()));
          } on FormatException {
            _output = "त्रुटि";
            _currentInput = "0";
          }
        } else {
          try {
            _result = double.parse(_currentInput);
            _operand = buttonText;
            _currentInput = "0";
            _isOperandPressed = true;
          } on FormatException {
            _output = "त्रुटि";
            _currentInput = "0";
          }
        }
      } else {
        // Number or decimal point
        if (_currentInput == "0" && englishButtonText != ".") {
          _currentInput = englishButtonText;
        } else if (englishButtonText == "." && _currentInput.contains(".")) {
          // Do nothing
        } else {
          _currentInput += englishButtonText;
        }
        _output = _convertToNepali(_currentInput);
      }
    });
  }

  String _formatResult(String result) {
    if (result == "Infinity" || result == "NaN") {
      return "अनन्त";
    }
    if (result == "-Infinity") {
      return "-अनन्त";
    }
    if (result.contains('.')) {
      List<String> parts = result.split('.');
      if (parts[1] == '0' || parts[1].isEmpty) {
        return parts[0];
      }
    }
    return result;
  }

  Widget _buildButton(
    String buttonText,
    Color buttonColor,
    Color textColor,
    bool isOperator,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: () => _onButtonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(
              fontFamily: 'Yantramanav',
              fontSize: isOperator ? 28 : 24,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // String formattedNepaliDate =
    //     '${_convertToNepali(_currentNepaliDate.year.toString())}/'
    //     '${_convertToNepali(_currentNepaliDate.month.toString().padLeft(2, '0'))}/'
    //     '${_convertToNepali(_currentNepaliDate.day.toString().padLeft(2, '0'))}';

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          'जीवन विज्ञान, गठ्ठाघर शाखा',
                          style: TextStyle(
                            fontFamily: 'Yantramanav',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: AppColors.maroonishRed,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'अर्थ व्यवस्थापन',
                          style: TextStyle(
                            fontFamily: 'Yantramanav',
                            fontWeight: FontWeight.w500,
                            fontSize: 24,
                            color: AppColors.maroonishRed,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.maroonishRed,
                    onPressed: () {
                      widget.onBackToHome();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.lighterGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _convertToNepali(_formatResult(_result.toString())),
                        style: const TextStyle(
                          fontFamily: 'Yantramanav',
                          fontSize: 18,
                          color: AppColors.gray,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.backspace_outlined),
                        color: AppColors.maroonishRed,
                        onPressed: () => _onButtonPressed("⌫"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _output,
                    style: const TextStyle(
                      fontFamily: 'Yantramanav',
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoalBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildButton(
                          "C",
                          AppColors.lighterGray,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "+/-",
                          AppColors.lighterGray,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "%",
                          AppColors.lighterGray,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "÷",
                          AppColors.brightSkyBlue,
                          AppColors.white,
                          true,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton(
                          "७",
                          AppColors.white,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "८",
                          AppColors.white,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "९",
                          AppColors.white,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "×",
                          AppColors.brightSkyBlue,
                          AppColors.white,
                          true,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton(
                          "४",
                          AppColors.white,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "५",
                          AppColors.white,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "६",
                          AppColors.white,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "-",
                          AppColors.brightSkyBlue,
                          AppColors.white,
                          true,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton(
                          "१",
                          AppColors.white,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "२",
                          AppColors.white,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "३",
                          AppColors.white,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "+",
                          AppColors.brightSkyBlue,
                          AppColors.white,
                          true,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton(
                          ".",
                          AppColors.white,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "०",
                          AppColors.white,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "⌫",
                          AppColors.white,
                          AppColors.charcoalBlack,
                          false,
                        ),
                        _buildButton(
                          "=",
                          AppColors.brightSkyBlue,
                          AppColors.white,
                          true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
