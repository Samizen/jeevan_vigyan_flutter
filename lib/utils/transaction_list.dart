// You may need to import this at the top of the file
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

// Add this utility method to the file where you display transactions
String formatStoredNepaliDate(String dateString) {
  try {
    // 1. Parse the string back into a NepaliDateTime object
    final nepaliDate = NepaliDateTime.parse(dateString);

    // 2. Format it using the desired pattern
    final formatter = NepaliDateFormat('yyyy/MM/dd', Language.nepali);
    return formatter.format(nepaliDate);
  } catch (e) {
    // Return the original string or a default value if parsing fails
    return dateString;
  }
}
