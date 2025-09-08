import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:jeevan_vigyan/constants/colors.dart';

class DateMonthPicker extends StatefulWidget {
  final NepaliDateTime initialDate;

  const DateMonthPicker({super.key, required this.initialDate});

  @override
  State<DateMonthPicker> createState() => _DateMonthPickerState();
}

class _DateMonthPickerState extends State<DateMonthPicker> {
  late NepaliDateTime _selectedDate;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;

  static const List<String> _nepaliMonths = [
    'बैशाख',
    'जेठ',
    'असार',
    'साउन',
    'भदौ',
    'असोज',
    'कार्तिक',
    'मंसिर',
    'पुस',
    'माघ',
    'फाल्गुन',
    'चैत',
  ];

  final List<int> _years = List.generate(
    20, // number of years to display
    (index) => 2075 + index,
  );

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _yearController = FixedExtentScrollController(
      initialItem: _years.indexOf(_selectedDate.year),
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedDate.month - 1,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('महिना र वर्ष छान्नुहोस्', textAlign: TextAlign.center),
      content: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: ListWheelScrollView.useDelegate(
                controller: _yearController,
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedDate = NepaliDateTime(
                      _years[index],
                      _selectedDate.month,
                    );
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) =>
                      Center(child: Text(_years[index].toString())),
                  childCount: _years.length,
                ),
              ),
            ),
            Expanded(
              child: ListWheelScrollView.useDelegate(
                controller: _monthController,
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedDate = NepaliDateTime(
                      _selectedDate.year,
                      index + 1,
                    );
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) =>
                      Center(child: Text(_nepaliMonths[index])),
                  childCount: _nepaliMonths.length,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor:
                AppColors.maroonishRed, // 'रद्द गर्नुहोस्' text color
          ),
          child: const Text('रद्द गर्नुहोस्'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedDate);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.maroonishRed, // 'ठीक छ' background color
            foregroundColor: AppColors.white, // 'ठीक छ' text color
          ),
          child: const Text('ठीक छ'),
        ),
      ],
    );
  }
}
