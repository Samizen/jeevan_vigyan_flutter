import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jeevan_vigyan/constants/colors.dart';
import 'package:jeevan_vigyan/screens/members/add_member_screen.dart';

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

// Placeholder for a single transaction list item
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
          // Swiped left for delete
          onDelete();
          return false; // Prevents item from being dismissed
        } else if (direction == DismissDirection.startToEnd) {
          // Swiped right for edit
          onEdit();
          return false; // Prevents item from being dismissed
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Placeholder values for the UI
  final double _remainingBalance = 100000;
  final double _totalIncome = 7500;
  final double _totalExpense = 7500;
  final double _netResult = 15000;

  final List<Map<String, dynamic>> _transactions = [
    {
      'name': 'सिता देवी',
      'date': '२०८२ श्रावण १७',
      'category': 'मासिक सदस्यता',
      'amount': 3000.0,
      'isIncome': true,
    },
    {
      'name': 'राम बहादुर',
      'date': '२०८२ श्रावण १७',
      'category': 'कार्यालय भाडा',
      'amount': 3000.0,
      'isIncome': false,
    },
    {
      'name': 'सिता देवी',
      'date': '२०८२ श्रावण १६',
      'category': 'मासिक सदस्यता',
      'amount': 3000.0,
      'isIncome': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    String formattedRemainingBalance = NumberFormat(
      '#,##0',
    ).format(_remainingBalance);
    String formattedNetResult = NumberFormat('#,##0').format(_netResult);
    String formattedTotalIncome = NumberFormat('#,##0').format(_totalIncome);
    String formattedTotalExpense = NumberFormat('#,##0').format(_totalExpense);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        flexibleSpace: Container(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
          child: const Column(
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
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Date Selector in a Rounded Box ---
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
                    onPressed: () {},
                  ),
                  const Row(
                    children: [
                      Text(
                        'श्रावण २०८१ वि.सं.',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Yantramanav',
                          color: AppColors.charcoalBlack,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.calendar_month, size: 24),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // --- Financial Summary Container (combined) ---
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
                  // Remaining Balance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'बाँकी रकम: ',
                        style: TextStyle(
                          fontFamily: 'Yantramanav',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: AppColors.charcoalBlack,
                        ),
                      ),
                      Text(
                        'रु. ${_convertToNepali(formattedRemainingBalance)}',
                        style: const TextStyle(
                          fontFamily: 'Yantramanav',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: AppColors.maroonishRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Income and Expense Boxes
                  Row(
                    children: [
                      Expanded(
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
                                'रु. ${_convertToNepali(formattedTotalIncome)}',
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
                      const SizedBox(width: 16),
                      Expanded(
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
                                'रु. ${_convertToNepali(formattedTotalExpense)}',
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Net Result
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'शुद्ध नतिजा: ',
                        style: TextStyle(
                          fontFamily: 'Yantramanav',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: AppColors.charcoalBlack,
                        ),
                      ),
                      Text(
                        'रु. ${_convertToNepali(formattedNetResult)}',
                        style: const TextStyle(
                          fontFamily: 'Yantramanav',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: AppColors.maroonishRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // --- Add Member Button ---
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddMemberScreen(),
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
            // --- Transaction Header ---
            const Text(
              'मासिक लेखा',
              style: TextStyle(
                fontFamily: 'Yantramanav',
                fontWeight: FontWeight.w500,
                fontSize: 24,
                color: AppColors.maroonishRed,
              ),
            ),
            const SizedBox(height: 8),
            // --- Transaction Filters & Details Container ---
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
                      const Chip(
                        label: Text('आज'),
                        backgroundColor: AppColors.lightGray,
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                        labelStyle: TextStyle(fontSize: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      const Chip(
                        label: Text('यो हप्ता'),
                        backgroundColor: AppColors.lightGray,
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                        labelStyle: TextStyle(fontSize: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      const Chip(
                        label: Text('आम्दानी'),
                        backgroundColor: AppColors.lightGray,
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                        labelStyle: TextStyle(fontSize: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      const Chip(
                        label: Text('खर्च'),
                        backgroundColor: AppColors.lightGray,
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                        labelStyle: TextStyle(fontSize: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Placeholder transaction list
                  ..._transactions.map((transaction) {
                    return TransactionListItem(
                      title: transaction['name'],
                      date: transaction['date'],
                      description: transaction['category'],
                      amount: transaction['amount'].toStringAsFixed(0),
                      isIncome: transaction['isIncome'],
                      onEdit: () {
                        // Implement your edit logic here
                        print('Editing transaction: ${transaction['name']}');
                      },
                      onDelete: () {
                        // Implement your delete logic here
                        print('Deleting transaction: ${transaction['name']}');
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
