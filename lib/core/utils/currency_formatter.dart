import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Ekstraksi hanya angka
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) return newValue.copyWith(text: '');

    // Format dengan titik setiap 3 angka dan prefix Rp
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    String newText = formatter.format(int.parse(numericOnly));

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// Fungsi utilitas untuk mengekstrak nilai angka bersih sebelum disimpan ke database
double parseCurrency(String formattedValue) {
  String numericOnly = formattedValue.replaceAll(RegExp(r'[^0-9]'), '');
  if (numericOnly.isEmpty) return 0.0;
  return double.parse(numericOnly);
}
