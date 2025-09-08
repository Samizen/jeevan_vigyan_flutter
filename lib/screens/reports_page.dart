import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jeevan_vigyan/constants/colors.dart';
import 'package:jeevan_vigyan/screens/date_month_picker.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

import 'package:jeevan_vigyan/models/financial_transaction.dart';
import 'package:jeevan_vigyan/models/category.dart';
import 'package:jeevan_vigyan/services/database_service.dart';
import 'package:jeevan_vigyan/screens/monthly_membership_report_page.dart';

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

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  NepaliDateTime _currentNepaliDate = NepaliDateTime.now();
  final DatabaseService _dbService = DatabaseService();

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

  List<FinancialTransaction> _transactions = [];
  Map<String, double> _incomeCategoryTotals = {};
  Map<String, double> _expenseCategoryTotals = {};
  List<Category> _categories = [];
  double _totalIncome = 0;
  double _totalExpense = 0;

  // Define a set of distinct colors for the donut chart segments
  final List<Color> _chartColors = [
    AppColors.sageGreen,
    AppColors.maroonishRed,
    AppColors.darkBlue,
    AppColors.lightBlue,
    AppColors.brightGreen,
    AppColors.brightSkyBlue,
    AppColors.darkMaroon,
    AppColors.darkerGray,
  ];

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    final categories = await _dbService.getCategories();

    final startDate = NepaliDateTime(
      _currentNepaliDate.year,
      _currentNepaliDate.month,
      1,
    );
    final endDate = NepaliDateTime(startDate.year, startDate.month + 1, 0);

    final fetchedTransactions = await _dbService.getTransactionsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    // Reset totals and category maps
    _incomeCategoryTotals = {};
    _expenseCategoryTotals = {};
    _totalIncome = 0;
    _totalExpense = 0;

    for (var transaction in fetchedTransactions) {
      final category = categories.firstWhere(
        (cat) => cat.id == transaction.categoryId,
        orElse: () => Category(id: 0, type: 'अज्ञात', name: 'अज्ञात'),
      );
      final categoryName = category.name;

      if (category.type == 'आय') {
        _incomeCategoryTotals.update(
          categoryName,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
        _totalIncome += transaction.amount;
      } else {
        _expenseCategoryTotals.update(
          categoryName,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
        _totalExpense += transaction.amount;
      }
    }

    if (mounted) {
      setState(() {
        _transactions = fetchedTransactions;
        _categories = categories;
      });
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentNepaliDate = NepaliDateTime(
        _currentNepaliDate.year,
        _currentNepaliDate.month - 1,
        1,
      );
      _fetchReportData();
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentNepaliDate = NepaliDateTime(
        _currentNepaliDate.year,
        _currentNepaliDate.month + 1,
        1,
      );
      _fetchReportData();
    });
  }

  void _openCalendarPicker() async {
    NepaliDateTime? pickedDate = await showDialog<NepaliDateTime>(
      context: context,
      builder: (context) => DateMonthPicker(initialDate: _currentNepaliDate),
    );

    if (pickedDate != null && pickedDate != _currentNepaliDate) {
      setState(() {
        _currentNepaliDate = pickedDate;
        _fetchReportData();
      });
    }
  }

  // Modal to show transactions for a specific category
  void _showTransactionsModal(String categoryName, String type) {
    final categoryTransactions = _transactions.where((t) {
      final category = _categories.firstWhere((cat) => cat.id == t.categoryId);
      return category.name == categoryName && category.type == type;
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$categoryName लेनदेन',
                style: const TextStyle(
                  fontFamily: 'Yantramanav',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroonishRed,
                ),
              ),
              const SizedBox(height: 16),
              if (categoryTransactions.isEmpty)
                const Text(
                  'यस वर्गमा कुनै लेनदेन छैन।',
                  style: TextStyle(
                    fontFamily: 'Yantramanav',
                    color: AppColors.gray,
                  ),
                )
              else
                ...categoryTransactions.map((transaction) {
                  return ListTile(
                    title: Text(
                      'रु. ${_convertToNepali(transaction.amount.toStringAsFixed(0))}',
                      style: const TextStyle(
                        fontFamily: 'Yantramanav',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      transaction.transactionDate,
                      style: const TextStyle(fontFamily: 'Yantramanav'),
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  // Helper to build donut chart segments
  List<Widget> _buildDonutChartSegments(
    Map<String, double> categoryTotals,
    double totalAmount,
  ) {
    if (totalAmount == 0) {
      return [
        SizedBox(
          width: 150,
          height: 150,
          child: CircularProgressIndicator(
            value: 1, // Full circle if no data
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.lighterGray,
            ),
            backgroundColor: Colors.transparent,
            strokeWidth: 25, // Thicker
          ),
        ),
      ];
    }

    List<Widget> segments = [];
    double startAngle = 0;

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (var i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final categoryAmount = entry.value;
      final sweepAngle = (categoryAmount / totalAmount) * 2 * 3.14159;
      final displayColor =
          _chartColors[i %
              _chartColors.length]; // Use index for consistent color

      segments.add(
        Positioned.fill(
          child: CustomPaint(
            painter: _DonutSegmentPainter(
              startAngle: startAngle,
              sweepAngle: sweepAngle,
              color: displayColor,
              strokeWidth: 25,
            ),
          ),
        ),
      );
      startAngle += sweepAngle;
    }
    return segments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
              const SizedBox(height: 24),

              // Monthly Membership Report Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MonthlyMembershipReportPage(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.lighterGray),
                  ),
                  child: const Text(
                    'मासिक सदस्यता रिपोर्ट',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Yantramanav',
                      color: AppColors.charcoalBlack,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Income Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'आम्दानी विवरण',
                  style: TextStyle(
                    fontFamily: 'Yantramanav',
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    color: AppColors.maroonishRed,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildReportSection(
                categoryTotals: _incomeCategoryTotals,
                totalAmount: _totalIncome,
                type: 'आय',
              ),
              const SizedBox(height: 24),

              // Expense Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'खर्च विवरण',
                  style: TextStyle(
                    fontFamily: 'Yantramanav',
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    color: AppColors.maroonishRed,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildReportSection(
                categoryTotals: _expenseCategoryTotals,
                totalAmount: _totalExpense,
                type: 'खर्च',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportSection({
    required Map<String, double> categoryTotals,
    required double totalAmount,
    required String type,
  }) {
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lighterGray),
      ),
      child: Column(
        children: [
          // Month Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.lighterGray),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 14),
                  onPressed: _goToPreviousMonth,
                ),
                GestureDetector(
                  onTap: _openCalendarPicker,
                  child: Row(
                    children: [
                      Text(
                        '${_convertToNepali(_currentNepaliDate.year.toString())} ${_nepaliMonths[_currentNepaliDate.month - 1]}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Yantramanav',
                          color: AppColors.charcoalBlack,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.calendar_month, size: 20),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 14),
                  onPressed: _goToNextMonth,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Donut Chart
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  children: _buildDonutChartSegments(
                    categoryTotals,
                    totalAmount,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'रु. ',
                      style: TextStyle(
                        fontFamily: 'Yantramanav',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                    TextSpan(
                      text: _convertToNepali(
                        NumberFormat('#,##0').format(totalAmount),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Yantramanav',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: AppColors.maroonishRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category List Items
          ...sortedEntries.map((entry) {
            final categoryName = entry.key;
            final amount = entry.value;
            final categoryColorIndex = sortedEntries.indexOf(entry);
            final displayColor =
                _chartColors[categoryColorIndex % _chartColors.length];

            return GestureDetector(
              onTap: () => _showTransactionsModal(categoryName, type),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: displayColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          categoryName,
                          style: const TextStyle(
                            fontFamily: 'Yantramanav',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.charcoalBlack,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'रु. ${_convertToNepali(NumberFormat('#,##0').format(amount))}',
                      style: const TextStyle(
                        fontFamily: 'Yantramanav',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          if (categoryTotals.isEmpty && totalAmount == 0)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'यस महिना कुनै लेनदेन छैन।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Yantramanav',
                  fontSize: 16,
                  color: AppColors.gray,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom Painter for Donut Chart Segments
class _DonutSegmentPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;
  final double strokeWidth;

  _DonutSegmentPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap =
          StrokeCap.butt; // Use butt to avoid rounded ends for segments

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - strokeWidth / 2,
    );

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _DonutSegmentPainter oldDelegate) {
    return oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
