import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jeevan_vigyan/constants/colors.dart';
import 'package:jeevan_vigyan/screens/add_transaction_form.dart';
import 'package:jeevan_vigyan/screens/add_member_form.dart';
import 'package:jeevan_vigyan/screens/date_month_picker.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

import 'package:jeevan_vigyan/models/financial_transaction.dart';
import 'package:jeevan_vigyan/models/member.dart';
import 'package:jeevan_vigyan/models/category.dart';
import 'package:jeevan_vigyan/services/database_service.dart';

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

// Enum to represent the transaction filter state
enum TransactionFilter { all, today, thisWeek, income, expense }

class TransactionListItem extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final String amount;
  final bool isIncome;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionListItem({
    super.key,
    required this.title,
    required this.date,
    required this.description,
    required this.amount,
    required this.isIncome,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(UniqueKey().toString()),
      background: Container(
        color: AppColors.brightGreen,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: AppColors.maroonishRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onDelete();
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        }
        return false;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                Icon(
                  isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isIncome
                      ? AppColors.brightGreen
                      : AppColors.maroonishRed,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Yantramanav',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontFamily: 'Yantramanav',
                        fontSize: 12,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Chip(
                    label: Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Yantramanav',
                        fontSize: 12,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                    backgroundColor: isIncome
                        ? AppColors.sageGreen
                        : AppColors.lightMaroon,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: const BorderSide(color: AppColors.lighterGray),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'रु. ${_convertToNepali(amount)}',
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
          ],
        ),
      ),
    );
  }
}

// New custom filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: isSelected ? AppColors.darkBlue : AppColors.lightGray,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        labelStyle: const TextStyle(fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          side: BorderSide(
            color: isSelected ? AppColors.darkBlue : AppColors.lighterGray,
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NepaliDateTime _currentNepaliDate = NepaliDateTime.now();

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

  TransactionFilter _activeFilter = TransactionFilter.all;

  List<FinancialTransaction> _transactions = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  List<Member> _members = [];
  List<Category> _categories = [];

  Future<void> _fetchFinancialData({TransactionFilter? filter}) async {
    final dbService = DatabaseService();

    List<FinancialTransaction> fetchedTransactions;
    double totalIncome = 0;
    double totalExpense = 0;

    final members = await dbService.getMembers();
    final categories = await dbService.getCategories();

    // Determine the date range based on the filter
    NepaliDateTime startDate;
    NepaliDateTime endDate;

    if (filter == TransactionFilter.today) {
      _currentNepaliDate = NepaliDateTime.now();
      startDate = _currentNepaliDate;
      endDate = _currentNepaliDate;
    } else if (filter == TransactionFilter.thisWeek) {
      _currentNepaliDate = NepaliDateTime.now();
      startDate = _currentNepaliDate.subtract(
        Duration(days: _currentNepaliDate.weekday - 1),
      );
      endDate = startDate.add(const Duration(days: 6));
    } else {
      startDate = NepaliDateTime(
        _currentNepaliDate.year,
        _currentNepaliDate.month,
        1,
      );
      endDate = NepaliDateTime(startDate.year, startDate.month + 1, 0);
    }

    // Fetch all transactions for the calculated period
    fetchedTransactions = await dbService.getTransactionsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    // Calculate totals for the entire time period
    for (var transaction in fetchedTransactions) {
      final category = categories.firstWhere(
        (cat) => cat.id == transaction.categoryId,
        orElse: () => Category(id: 0, type: 'unknown', name: 'अज्ञात'),
      );
      if (category.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    // Apply income/expense filters on the fetched transactions
    List<FinancialTransaction> filteredTransactions;
    if (filter == TransactionFilter.income) {
      filteredTransactions = fetchedTransactions.where((t) {
        final category = categories.firstWhere((cat) => cat.id == t.categoryId);
        return category.type == 'income';
      }).toList();
    } else if (filter == TransactionFilter.expense) {
      filteredTransactions = fetchedTransactions.where((t) {
        final category = categories.firstWhere((cat) => cat.id == t.categoryId);
        return category.type == 'expense';
      }).toList();
    } else {
      filteredTransactions = fetchedTransactions;
    }

    if (mounted) {
      setState(() {
        _transactions = filteredTransactions;
        _totalIncome = totalIncome;
        _totalExpense = totalExpense;
        _members = members;
        _categories = categories;
        _activeFilter = filter ?? TransactionFilter.all;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentNepaliDate = NepaliDateTime(
        _currentNepaliDate.year,
        _currentNepaliDate.month - 1,
        1,
      );
    });
    _fetchFinancialData();
  }

  void _goToNextMonth() {
    setState(() {
      _currentNepaliDate = NepaliDateTime(
        _currentNepaliDate.year,
        _currentNepaliDate.month + 1,
        1,
      );
    });
    _fetchFinancialData();
  }

  void _showAddTransactionForm({String? initialType}) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 80,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AddTransactionForm(initialType: initialType ?? 'income'),
      ),
    );

    if (result == true) {
      // Reload transactions after successful insert
      await _fetchFinancialData(filter: _activeFilter);
    }
  }

  // In lib/screens/home_page.dart
  // Inside the _HomePageState class

  void _openCalendarPicker() async {
    NepaliDateTime? pickedDate = await showDialog<NepaliDateTime>(
      context: context,
      builder: (context) => DateMonthPicker(initialDate: _currentNepaliDate),
    );

    if (pickedDate != null && pickedDate != _currentNepaliDate) {
      setState(() {
        _currentNepaliDate = pickedDate;
        _fetchFinancialData();
      });
    }
  }

  void _showAddMemberForm() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const AddMemberForm();
      },
    );
    _fetchFinancialData();
  }

  @override
  Widget build(BuildContext context) {
    final remainingBalance = _totalIncome - _totalExpense;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.lighterGray),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    onPressed: _goToPreviousMonth,
                  ),
                  GestureDetector(
                    onTap: _openCalendarPicker,
                    child: Row(
                      children: [
                        Text(
                          '${_convertToNepali(_currentNepaliDate.year.toString())} ${_nepaliMonths[_currentNepaliDate.month - 1]}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Yantramanav',
                            color: AppColors.charcoalBlack,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_month, size: 24),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: _goToNextMonth,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.lighterGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'बाँकी रकम: ',
                          style: TextStyle(
                            fontFamily: 'Yantramanav',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.charcoalBlack,
                          ),
                        ),
                        const TextSpan(
                          text: 'रु. ',
                          style: TextStyle(
                            fontFamily: 'Yantramanav',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.maroonishRed,
                          ),
                        ),
                        TextSpan(
                          text: _convertToNepali(
                            NumberFormat('#,##0').format(remainingBalance),
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _showAddTransactionForm(initialType: 'income'),
                          child: Container(
                            height: 150,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.darkBlue,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'कुल आम्दानी',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Yantramanav',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'रु. ${_convertToNepali(NumberFormat('#,##0').format(_totalIncome))}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Yantramanav',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _showAddTransactionForm(initialType: 'expense'),
                          child: Container(
                            height: 150,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.maroonishRed,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'कुल खर्च',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Yantramanav',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'रु. ${_convertToNepali(NumberFormat('#,##0').format(_totalExpense))}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Yantramanav',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'शुद्ध नतिजा: ',
                          style: TextStyle(
                            fontFamily: 'Yantramanav',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.charcoalBlack,
                          ),
                        ),
                        const TextSpan(
                          text: 'रु. ',
                          style: TextStyle(
                            fontFamily: 'Yantramanav',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.maroonishRed,
                          ),
                        ),
                        TextSpan(
                          text: _convertToNepali(
                            NumberFormat(
                              '#,##0',
                            ).format(_totalIncome - _totalExpense),
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
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _showAddMemberForm,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.lighterGray),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.charcoalBlack,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'सदस्य थप्नुहोस्',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.charcoalBlack),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'मासिक लेखा',
                style: TextStyle(
                  fontFamily: 'Yantramanav',
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  color: AppColors.maroonishRed,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.lighterGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _FilterChip(
                        label: 'आज',
                        isSelected: _activeFilter == TransactionFilter.today,
                        onTap: () {
                          _fetchFinancialData(filter: TransactionFilter.today);
                        },
                      ),
                      _FilterChip(
                        label: 'यो हप्ता',
                        isSelected: _activeFilter == TransactionFilter.thisWeek,
                        onTap: () {
                          _fetchFinancialData(
                            filter: TransactionFilter.thisWeek,
                          );
                        },
                      ),
                      _FilterChip(
                        label: 'आम्दानी',
                        isSelected: _activeFilter == TransactionFilter.income,
                        onTap: () {
                          _fetchFinancialData(filter: TransactionFilter.income);
                        },
                      ),
                      _FilterChip(
                        label: 'खर्च',
                        isSelected: _activeFilter == TransactionFilter.expense,
                        onTap: () {
                          _fetchFinancialData(
                            filter: TransactionFilter.expense,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._transactions.map((transaction) {
                    final memberName = _members
                        .firstWhere(
                          (member) => member.id == transaction.memberId,
                          orElse: () => Member(
                            id: 0,
                            name: 'अज्ञात',
                            contactNo: '',
                            memberAddedDate: '',
                          ),
                        )
                        .name;
                    final category = _categories.firstWhere(
                      (cat) => cat.id == transaction.categoryId,
                      orElse: () =>
                          Category(id: 0, type: 'अज्ञात', name: 'अज्ञात'),
                    );

                    return TransactionListItem(
                      title: memberName,
                      date: transaction.transactionDate,
                      description: category.name,
                      amount: transaction.amount.toStringAsFixed(0),
                      isIncome: category.type == 'income',
                      onEdit: () async {
                        final result = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 20,
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom + 80,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: AddTransactionForm(
                              initialType: category.type,
                              transaction: transaction,
                            ),
                          ),
                        );
                        if (result == true) {
                          await _fetchFinancialData(filter: _activeFilter);
                        }
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              'करोबार हटाउनुहोस्',
                              style: TextStyle(
                                fontFamily: 'Yantramanav',
                                fontWeight: FontWeight.bold,
                                color: AppColors.maroonishRed,
                              ),
                            ),
                            content: const Text(
                              'के तपाईं यो कारोबार हटाउन निश्चित हुनुहुन्छ?',
                              style: TextStyle(
                                fontFamily: 'Yantramanav',
                                color: AppColors.charcoalBlack,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text(
                                  'रद्द गर्नुहोस्',
                                  style: TextStyle(
                                    fontFamily: 'Yantramanav',
                                    color: AppColors.gray,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  'हटाउनुहोस्',
                                  style: TextStyle(
                                    fontFamily: 'Yantramanav',
                                    color: AppColors.maroonishRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await DatabaseService().database.then(
                            (db) => db.delete(
                              'Transactions',
                              where: 'id = ?',
                              whereArgs: [transaction.id],
                            ),
                          );
                          await _fetchFinancialData(filter: _activeFilter);
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
