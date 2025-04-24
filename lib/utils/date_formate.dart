import 'package:intl/intl.dart';

class DateFormatter {

static String currentDateFormate(DateTime? date) {
  
  final now = date?.toLocal() ?? DateTime.now().toLocal();
  return DateFormat('dd-MM-yyyy').format(now);  
}

}