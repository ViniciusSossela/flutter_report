import 'package:intl/intl.dart';

const enUS = 'en';
const pt = 'pt';
const enUSDatetimeFormat = 'yyyy/MM/dd HH:mm';
const enUSDateFormat = 'yyyy/MM/dd';
const ptDatetimeFormat = 'dd/MM/yyyy HH:mm';
const ptDateFormat = 'dd/MM/yyyy';

extension DateTimeFormatExtension on DateTime {
  String parseToLocalizedDateTime({String locale = enUS}) {
    switch (locale) {
      case enUS:
        return DateFormat(enUSDatetimeFormat).format(this);
      case pt:
        return DateFormat(ptDatetimeFormat).format(this);
      default:
        return DateFormat(enUSDatetimeFormat).format(this);
    }
  }

  String parseToLocalizedDate({String locale = enUS}) {
    switch (locale) {
      case enUS:
        return DateFormat(enUSDateFormat).format(this);
      case pt:
        return DateFormat(ptDateFormat).format(this);
      default:
        return DateFormat(enUSDateFormat).format(this);
    }
  }
}
