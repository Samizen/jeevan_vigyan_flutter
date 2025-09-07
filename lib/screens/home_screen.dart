import 'package:flutter/material.dart';
import 'package:jeevan_vigyan/constants/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'जीवन विज्ञान, गठ्ठाघर शाखा\nअर्थ व्यवस्थापन', // From the PDF Header [cite: 101]
          style: TextStyle(
            color: AppColors.charcoalBlack,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Monthly Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.arrow_back_ios),
                const Text(
                  'श्रावण २०८१ वि.सं.', // As per the design [cite: 102]
                  style: TextStyle(fontSize: 18),
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
            const SizedBox(height: 20),

            // --- Financial Summary Cards ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remaining Amount
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gray.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'बाँकी रकमः',
                          style: TextStyle(color: AppColors.charcoalBlack),
                        ),
                        Text(
                          'रु. १,००,०००', // From the design [cite: 103]
                          style: TextStyle(
                            color: AppColors.maroonishRed,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Income and Expense Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'कुल आम्दानी', // As per the design [cite: 104]
                          style: TextStyle(color: AppColors.white),
                        ),
                        Text(
                          'रु. ७,५००', // As per the design [cite: 106]
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: AppColors.maroonishRed,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'कुल खर्च', // As per the design [cite: 72]
                          style: TextStyle(color: AppColors.white),
                        ),
                        Text(
                          'रु. ७,५००', // As per the design [cite: 72]
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- "सदस्य थप्नुहोस्" Button ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '+ सदस्य थप्नुहोस्', // As per the design [cite: 111]
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.charcoalBlack),
              ),
            ),
            const SizedBox(height: 20),

            // --- Monthly Transactions Header and Filters ---
            const Text(
              'मासिक लेखा', // As per the design [cite: 112]
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterChip(
                  'आज',
                  true,
                ), // "आज" is selected in the design [cite: 113]
                _buildFilterChip(
                  'यो हप्ता',
                  false,
                ), // From the design [cite: 114]
                _buildFilterChip(
                  'आम्दानी',
                  false,
                ), // From the design [cite: 115]
                _buildFilterChip('खर्च', false), // From the design [cite: 116]
              ],
            ),
            const SizedBox(height: 20),

            // --- Transaction List (Placeholder) ---
            _buildTransactionTile(
              'सिता देवी', // From the design [cite: 117]
              '२०८२ श्रावण १७', // From the design [cite: 118]
              'मासिक सदस्यता', // From the design [cite: 121]
              'रु.३०००', // From the design [cite: 122]
              true, // Income
            ),
            _buildTransactionTile(
              'राम बहादुर', // From the design [cite: 119]
              '२०८२ श्रावण १७', // From the design [cite: 120]
              'कार्यालय भाडा', // From the design [cite: 123]
              'रु.३०००', // From the design [cite: 124]
              false, // Expense
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Chip(
      label: Text(label),
      backgroundColor: isSelected
          ? AppColors.brightSkyBlue
          : AppColors.lightGray,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.charcoalBlack,
      ),
    );
  }

  Widget _buildTransactionTile(
    String name,
    String date,
    String category,
    String amount,
    bool isIncome,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? AppColors.sageGreen : AppColors.maroonishRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(color: AppColors.darkGray)),
              ],
            ),
          ),
          Chip(
            label: Text(category),
            backgroundColor: isIncome
                ? AppColors.sageGreen
                : AppColors.lightMaroon,
          ),
          const SizedBox(width: 10),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
