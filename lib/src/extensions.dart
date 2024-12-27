extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;

    final firstLetter = this[0].toUpperCase();
    if (length == 1) {
      return firstLetter;
    }

    return firstLetter + substring(1);
  }
}

String typeToString<T>() {
  return T.toString();
}
