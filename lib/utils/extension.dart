import 'package:intl/intl.dart';

extension DateFormatter on String {
  String get formattedDate {
    try {
      DateTime dateTime = DateTime.parse(this);
      return DateFormat('d MMM yyyy').format(dateTime);
    } catch (e) {
      return this;
    }
  }
}

extension CurrencyFormatting on int {
  String toMMks({String symbol = ' Ks'}) {
    final NumberFormat numberFormat = NumberFormat.currency(
      locale: 'en_US', // Using en_US for standard thousands separator
      symbol: '', // We'll add the symbol manually
      decimalDigits: 0,
    );

    return '${numberFormat.format(this).replaceAll('Ks', '').trim()}$symbol';
  }

  String toCurrency({String locale = 'en_US', String symbol = '\$'}) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 0,
    );
    return currencyFormat.format(this);
  }
}
