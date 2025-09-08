import 'package:flutter/material.dart';
import 'package:jeevan_vigyan/models/member.dart';
import 'package:jeevan_vigyan/services/database_service.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

class AddMemberForm extends StatefulWidget {
  // Correctly define the optional named parameter and assign it to a final field.
  final Member? memberToEdit;

  const AddMemberForm({super.key, this.memberToEdit});

  @override
  State<AddMemberForm> createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<AddMemberForm> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  NepaliDateTime? _selectedDate = NepaliDateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize the form fields if a member is being edited
    if (widget.memberToEdit != null) {
      _nameController.text = widget.memberToEdit!.name;
      _contactNoController.text = widget.memberToEdit!.contactNo;
      _selectedDate = NepaliDateTime.tryParse(
        widget.memberToEdit!.memberAddedDate,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNoController.dispose();
    super.dispose();
  }

  // Utility method to convert English numbers to Nepali digits
  String _toNepaliDigits(String numberString) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const nepali = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];

    String result = numberString;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], nepali[i]);
    }
    return result;
  }

  // Utility method to format the Nepali date for display with Nepali digits
  String _formatNepaliDate(NepaliDateTime? date) {
    if (date == null) return 'मिति छान्नुहोस्';
    final year = _toNepaliDigits(date.year.toString());
    final month = _toNepaliDigits(date.month.toString().padLeft(2, '0'));
    final day = _toNepaliDigits(date.day.toString().padLeft(2, '0'));
    return '$year/$month/$day';
  }

  // Date Picker
  void _showDatePicker() async {
    final NepaliDateTime? pickedDate = await showMaterialDatePicker(
      context: context,
      initialDate: _selectedDate ?? NepaliDateTime.now(),
      firstDate: NepaliDateTime(2070),
      lastDate: NepaliDateTime(2090),
      initialDatePickerMode: DatePickerMode.day,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFD01018), // Header & selected date
              onPrimary: Colors.white, // Header text & selected date text
              onSurface: Colors.black, // Default day text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD01018), // Cancel/OK buttons
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Form Submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newMember = Member(
        // Assign the member ID if we are editing
        id: widget.memberToEdit?.id,
        name: _nameController.text,
        contactNo: _contactNoController.text,
        memberAddedDate:
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
      );

      try {
        if (widget.memberToEdit == null) {
          // It's a new member
          await _dbService.insertMember(newMember);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Member added successfully!')),
          );
        } else {
          // It's an existing member to update
          await _dbService.updateMember(newMember);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Member updated successfully!')),
          );
        }
        Navigator.of(context).pop();
      } catch (e) {
        print('Failed to process member: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save member: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    // Change the title based on whether it's an add or edit form
                    widget.memberToEdit == null
                        ? 'सदस्य थप्नुहोस्'
                        : 'सदस्य सम्पादन गर्नुहोस्',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: const Color(0xFFD01018),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Name Header and Textbox
              const Text(
                'नाम *',
                style: TextStyle(
                  color: Color(0xFFD01018),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'नाम',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'नाम आवश्यक छ।';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone Number Header and Textbox
              const Text(
                'सम्पर्क',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactNoController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'सम्पर्क',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Date Header and Selector
              const Text(
                'मिति',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        backgroundColor: const Color(0xFFD01018),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        widget.memberToEdit == null
                            ? 'ठीक छ'
                            : 'अपडेट गर्नुहोस्',
                      ),
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
}
