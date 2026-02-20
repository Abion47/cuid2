// Copyright 2023 (c) George Mamar
//
// Licensed under MIT license
// ...

/// `cuid2` is a [Dart](https://dart.dev/) implementation of the [cuid2](https://github.com/paralleldrive/cuid2) library.
///
/// For technical details is recommended to check the original documentation where the inner details are explained.
///
/// Example usage:
///
/// ```dart
///   // cuid generator
///   print(cuid()); // => cl8qj639w000l7n6e6p689uad
///
///   // cuid using secure random generator
///   print(cuidSecure()); // => cl8qjcei8000kfq6e3a1q19os
///
///   // custom id length (defaults to 24)
///   print(cuid(30)); // => oxjkyfqo3aqk3jigelnuyp3ef299qx
///
///   final myCuid = cuidConfig(length: 30);
///   final id = myCuid.gen();
/// ```
library cuid2;

import 'dart:math';

import 'src/cuid2_base.dart' show Cuid;

/// Generates a new id (default length of 24).
///
/// Attempts to use a cryptographic random generator by default. Falls back to `Random()` if the system
/// can not provide a secure source of random numbers. Check [Random.secure()]
String cuid([int length = Cuid.defaultLength]) => Cuid(idLength: length).gen();

/// Generates a new id using cryptographic random generator (default length of 24).
///
/// Identical to [cuid] with the exception that an [UnsupportedError] is thrown if the system can not
/// provide a secure source of random numbers.
String cuidSecure([int length = Cuid.defaultLength]) {
  try {
    return Cuid(idLength: length, throwIfInsecure: true).gen();
  } on UnsupportedError {
    rethrow;
  }
}

/// Creates a generator with the given options.
///
/// `length` _optional_ sets the length of the generated IDs (default is 24).
///
/// `counter` _optional_ custom session counter function. Ex. with increments of 5:
/// ```dart
///   myCounter(int start) => () => count+=5;
///   final config = cuidConfig(counter: myCounter(3));
/// ```
/// `fingerprint` _optional_ custom fingerprint value:
/// ```dart
///   String myfingerprint = "uniqueFingerprint123";
///   final config = cuidConfig(fingerprint: myfingerprint);
/// ```
///
/// `random` _optional_ custom random number generator function. Defaults to using [Random.secure]
/// whenever possible and falls back to [Random] if the system can not provide a cryptographic
/// number generator.
/// ```dart
///   int value = 0;
///   final myrandom = () => value++;
///   final config = cuidConfig(random: myrandom);
/// ```
///
/// `throwIfInsecure` _optional_ disallows falling back to [Random] if [Random.secure] is unavailable
/// and will instead throw an [UnsupportedError] in that scenario (default is false).
Cuid cuidConfig({
  int length = Cuid.defaultLength,
  int Function()? counter,
  String? fingerprint,
  double Function()? random,
  bool throwIfInsecure = false,
}) =>
    Cuid(
      idLength: length,
      random: random,
      counter: counter,
      fingerprint: fingerprint,
      throwIfInsecure: throwIfInsecure,
    );

/// Determines if the given string `id` is a valid CUID based on the specified length constraints.
///
/// The function checks if the input string `id` consists only of alphanumeric lowercase characters and
/// if its length is within the given range. The minimum and maximum length constraints can be
/// customized using the optional named parameters `minLength` and `maxLength`, which default to 2 and 32, respectively.
///
/// Returns `true` if the input string `id` is a valid CUID, otherwise returns `false`.
///
/// Example usage:
///
/// ```dart
/// bool isValid = isCuid('abc123');
/// ```
///
/// `id`: The input string to check for validity.
/// `minLength`: The minimum length constraint for the input string (default: 2).
/// `maxLength`: The maximum length constraint for the input string (default: 32).
bool isCuid(String id, {int minLength = 2, int maxLength = Cuid.maxLength}) {
  final length = id.length;
  final regex = RegExp(r'^[a-z][0-9a-z]+$');

  if (length >= minLength && length <= maxLength && regex.hasMatch(id)) {
    return true;
  }

  return false;
}
