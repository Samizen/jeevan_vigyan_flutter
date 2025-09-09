import 'package:flutter/material.dart';
import 'package:jeevan_vigyan/models/category.dart';
import 'package:jeevan_vigyan/models/financial_transaction.dart';
import 'package:jeevan_vigyan/models/member.dart';
import 'package:jeevan_vigyan/services/database_service.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:jeevan_vigyan/screens/add_category_form.dart';

class AddTransactionForm extends StatefulWidget {
  final String initialType;
  final FinancialTransaction? transaction; // <-- Add this

  AddTransactionForm({
    super.key,
    required this.initialType,
    this.transaction, // <-- Add this
  });

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  String _selectedType = '';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  NepaliDateTime? _selectedDate = NepaliDateTime.now();
  Member? _selectedMember;
  Category? _selectedCategory;

  List<Member> _members = [];
  List<Category> _incomeCategories = [];
  List<Category> _expenseCategories = [];

  // This future will be used to show a loading indicator while data is fetched.
  late Future<void> _dataLoadingFuture;

  @override
  void initState() {
    super.initState();
    _selectedType = (widget.initialType == 'income') ? 'income' : 'expense';
    _dataLoadingFuture = _loadData();

    // Prefill text fields and date if editing
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _amountController.text = t.amount.toString();
      _descriptionController.text = t.description ?? '';
      // Parse Nepali date string (YYYY/MM/DD)
      final parts = t.transactionDate.split('/');
      if (parts.length == 3) {
        _selectedDate = NepaliDateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }
  }

  Future<void> _loadData() async {
    final members = await _dbService.getMembers();
    final incomeCategories = await _dbService.getCategoriesByType('income');
    final expenseCategories = await _dbService.getCategoriesByType('expense');

    setState(() {
      _members = members;
      _incomeCategories = incomeCategories;
      _expenseCategories = expenseCategories;

      // Set selected member and category if editing
      if (widget.transaction != null) {
        _selectedMember = _members.firstWhere(
          (m) => m.id == widget.transaction!.memberId,
          orElse: () => _members.isNotEmpty
              ? _members.first
              : Member(id: null, name: '', contactNo: '', memberAddedDate: ''),
        );

        _selectedCategory =
            (_selectedType == 'income' ? _incomeCategories : _expenseCategories)
                .firstWhere(
                  (c) => c.id == widget.transaction!.categoryId,
                  orElse: () => (_selectedType == 'income'
                      ? (_incomeCategories.isNotEmpty
                            ? _incomeCategories.first
                            : Category(id: null, type: 'income', name: ''))
                      : (_expenseCategories.isNotEmpty
                            ? _expenseCategories.first
                            : Category(id: null, type: 'expense', name: ''))),
                );
      } else {
        _selectedMember = _members.isNotEmpty ? _members.first : null;
        _selectedCategory = _selectedType == 'income'
            ? (_incomeCategories.isNotEmpty ? _incomeCategories.first : null)
            : (_expenseCategories.isNotEmpty ? _expenseCategories.first : null);
      }
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMember == null || _selectedCategory == null) {
        // This is a safety check.
        print('DEBUG: Member or Category not selected.');
        return;
      }

      // --- FIX START: Correctly format the date with slashes for the database query
      final formattedDate =
          '${_selectedDate!.year}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}';
      // --- FIX END

      final newTransaction = FinancialTransaction(
        memberId: _selectedMember!.id!,
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategory!.id!,
        description: _descriptionController.text,
        transactionDate: formattedDate, // Use the corrected date format
      );

      try {
        final insertedId = await _dbService.insertTransaction(newTransaction);
        print('DEBUG: Transaction successfully inserted with ID: $insertedId');

        if (mounted) {
          // Pass 'true' back to the home screen to indicate a successful save
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        print('ERROR: Failed to insert transaction: $e');
        // You might want to show a SnackBar or a dialog to the user here.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save transaction: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDatePicker() async {
    final NepaliDateTime? pickedDate = await showMaterialDatePicker(
      context: context,
      initialDate: _selectedDate ?? NepaliDateTime.now(),
      firstDate: NepaliDateTime(2070),
      lastDate: NepaliDateTime(2090),
      initialDatePickerMode: DatePickerMode.day,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('ne'),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: const Color(0xFFD01018),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD01018),
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  String _toNepaliDigits(String numberString) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const nepali = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];

    String result = numberString;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], nepali[i]);
    }
    return result;
  }

  String _formatNepaliDate(NepaliDateTime? date) {
    if (date == null) return 'मिति छान्नुहोस्';

    final year = _toNepaliDigits(date.year.toString());
    final month = _toNepaliDigits(date.month.toString().padLeft(2, '0'));
    final day = _toNepaliDigits(date.day.toString().padLeft(2, '0'));

    return '$year/$month/$day';
  }

  void _addNewCategory() async {
    final newCategoryId = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: AddCategoryForm(
          // Correctly pass the consistent _selectedType
          categoryType: _selectedType,
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    );

    if (newCategoryId != null) {
      await _loadData();
      setState(() {
        final categoryList = _selectedType == 'income'
            ? _incomeCategories
            : _expenseCategories;
        final newCategory = categoryList.firstWhere(
          (cat) => cat.id == newCategoryId,
        );
        _selectedCategory = newCategory;
      });
    }
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = 'income'; // Use consistent English identifier
                  _selectedCategory = _incomeCategories.isNotEmpty
                      ? _incomeCategories.first
                      : null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _selectedType == 'income'
                      ? Colors.red[800]
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                alignment: Alignment.center,
                child: Text(
                  'आम्दानी',
                  style: TextStyle(
                    color: _selectedType == 'income'
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType =
                      'expense'; // Use consistent English identifier
                  _selectedCategory = _expenseCategories.isNotEmpty
                      ? _expenseCategories.first
                      : null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _selectedType == 'expense'
                      ? Colors.red[800]
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                alignment: Alignment.center,
                child: Text(
                  'खर्च',
                  style: TextStyle(
                    color: _selectedType == 'expense'
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataLoadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // All data has loaded, build the form
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'कारोबार थप्नुहोस्',
                          style: Theme.of(context).textTheme.headlineSmall!
                              .copyWith(color: Colors.red[800]),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Type Selector (Income/Expense)
                    _buildTypeSelector(),
                    const SizedBox(height: 20),

                    // Amount Header and Textbox
                    const Text(
                      'रकम *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'रकम',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        prefixText: 'रु. ',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'रकम आवश्यक छ।';
                        }
                        if (double.tryParse(value) == null) {
                          return 'वैध नम्बर प्रविष्ट गर्नुहोस्।';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Member Header and Dropdown
                    const Text(
                      'सदस्य *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Member>(
                      decoration: InputDecoration(
                        labelText: 'सदस्य',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      initialValue: _selectedMember,
                      items: _members.map((member) {
                        return DropdownMenuItem<Member>(
                          value: member,
                          child: Text(member.name),
                        );
                      }).toList(),
                      onChanged: (member) {
                        setState(() {
                          _selectedMember = member;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'सदस्य छान्नुहोस्।' : null,
                    ),
                    const SizedBox(height: 20),

                    // Category Selector (Chips)
                    Text(
                      'श्रेणी',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        ...(_selectedType == 'income'
                                ? _incomeCategories
                                : _expenseCategories)
                            .map(
                              (category) => ChoiceChip(
                                label: Text(category.name),
                                selected: _selectedCategory?.id == category.id,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                selectedColor: _selectedType == 'income'
                                    ? Colors.green[700]
                                    : Colors.red[300],
                                backgroundColor: Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                labelStyle: TextStyle(
                                  color: _selectedCategory?.id == category.id
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                              ),
                            ),
                        ActionChip(
                          label: const Text('+ नयाँ श्रेणी'),
                          onPressed: _addNewCategory,
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Date Header and Selector
                    const Text(
                      'मिति *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showDatePicker,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'मिति छान्नुहोस्',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(_formatNepaliDate(_selectedDate)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description Header and Textbox
                    const Text(
                      'विवरण',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'विवरण',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('रद्द गर्नुहोस्'),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[800],
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('ठीक छ'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
