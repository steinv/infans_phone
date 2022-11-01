import 'package:intl/intl.dart';

class FormatterUtil {
  
  static String timeStampAsString(int timestamp, String? format) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat(format ?? 'dd-MM-yyyy hh:mm').format(dateTime);
  }

  static String timeAsString(int timeInSeconds) {
    double hours = timeInSeconds / 3600;
    double minutes = hours.remainder(1) * 60;
    double seconds = minutes.remainder(1) * 60;

    return '${hours.floor() > 0 ? '${hours.floor()}u ' : ''}${minutes.floor() > 0 ? '${minutes.floor()}min ' : ''}${seconds.floor()}sec ';
  }

  static phoneNumberToIntlFormat(String? telephoneNumber) {
    if(telephoneNumber == null) {
      return null;
    }
    String telTrimmed = telephoneNumber.replaceAll(RegExp(r"\D"), '');
    if (telTrimmed.startsWith('00')) {
      return '+${telTrimmed.substring(2)}';
    } else if (telTrimmed.startsWith('0')) {
      return '+32${telTrimmed.substring(1)}';
    } else {
      return '+$telTrimmed';
    }
  }
}