import 'package:intl/intl.dart';

class DateTimeUtil {
  
  static String timeStampAsString(int timestamp, String? format) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat(format ?? 'dd-MM-yyyy hh:mm').format(dateTime);
  }
}