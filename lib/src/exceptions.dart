import 'dart:core';

class InvalidGenerationSource implements Exception {
  final String message;
  InvalidGenerationSource(this.message);

  @override
  String toString() => 'InvalidGenerationSource: $message';
}
