import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jeevan_vigyan/constants/colors.dart';
import 'package:jeevan_vigyan/services/database_service.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:jeevan_vigyan/models/member.dart';

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

class MonthlyMembershipReportPage extends StatefulWidget {
  const MonthlyMembershipReportPage({super.key});

  @override
  State<MonthlyMembershipReportPage> createState() =>
      _MonthlyMembershipReportPageState();
}

class _MonthlyMembershipReportPageState
    extends State<MonthlyMembershipReportPage> {
  final DatabaseService _dbService = DatabaseService();
  NepaliDateTime _currentYear = NepaliDateTime.now();
  List<Member> _members = [];
  Map<int, Map<int, double>> _monthlyContributions = {};
  bool _isLoading = true;

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

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    setState(() {
      _isLoading = true;
    });

    final members = await _dbService.getMembers();
    final monthlyData = await _dbService.getMonthlyContributions(
      _currentYear.year,
    );

    if (mounted) {
      setState(() {
        _members = members;
        _monthlyContributions = monthlyData;
        _isLoading = false;
      });
    }
  }

  void _goToPreviousYear() {
    setState(() {
      _currentYear = NepaliDateTime(_currentYear.year - 1, 1, 1);
      _fetchReportData();
    });
  }

  void _goToNextYear() {
    setState(() {
      _currentYear = NepaliDateTime(_currentYear.year + 1, 1, 1);
      _fetchReportData();
    });
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
              // Header with an 'X' button on the right
              Row(
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
                  // 'X' button
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.maroonishRed,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Page Title
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'मासिक सदस्यता शुल्क तालिका',
                  style: TextStyle(
                    fontFamily: 'Yantramanav',
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    color: AppColors.maroonishRed,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Year Selector
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.lighterGray),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 14),
                      onPressed: _goToPreviousYear,
                    ),
                    Text(
                      _convertToNepali(_currentYear.year.toString()),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Yantramanav',
                        color: AppColors.charcoalBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 14),
                      onPressed: _goToNextYear,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Membership Table
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.maroonishRed,
                      ),
                    )
                  : _members.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'यस वर्ष कुनै सदस्य छैनन्।',
                          style: TextStyle(
                            fontFamily: 'Yantramanav',
                            fontSize: 16,
                            color: AppColors.gray,
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16.0,
                        dataRowMinHeight: 48,
                        dataRowMaxHeight: 48,
                        headingRowColor: WidgetStateColor.resolveWith(
                          (states) => AppColors.offWhite,
                        ),
                        columns: [
                          const DataColumn(
                            label: Text(
                              'सदस्यको नाम',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ..._nepaliMonths.map(
                            (month) => DataColumn(
                              label: Text(
                                month,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: _members.map((member) {
                          return DataRow(
                            cells: [
                              DataCell(Text(member.name)),
                              ...List<DataCell>.generate(12, (index) {
                                final month = index + 1;
                                final amount =
                                    _monthlyContributions[member.id!]?[month] ??
                                    0.0;
                                return DataCell(
                                  Text(
                                    amount > 0
                                        ? _convertToNepali(
                                            NumberFormat(
                                              '#,##0',
                                            ).format(amount),
                                          )
                                        : '-',
                                  ),
                                );
                              }),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
