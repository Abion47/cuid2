import 'dart:typed_data';

import 'package:cuid2/cuid2.dart';
import 'package:cuid2/src/cuid2_base.dart';
import 'package:cuid2/src/utility.dart';
import 'package:test/test.dart';

import 'utils.dart' show info;

void main() {
  group('cuid', () {
    test('given nothing, should return a cuid of default length', () {
      final id = cuid();
      info(id);

      expect(id, isNotEmpty);
      expect(isCuid(id), isTrue);
      expect(id, hasLength(Cuid.defaultLength));
    });

    test(
        'given a smaller length, should return a cuid with the specified smaller length',
        () {
      final length = 10;
      final cuid = cuidConfig(length: length);
      final id = cuid.gen();
      info(id);

      expect(id, isNotEmpty);
      expect(isCuid(id), isTrue);
      expect(id, hasLength(length));
    });

    test(
        'given a larger length, should return a cuid with the specified larger length',
        () {
      final length = 32;
      final cuid = cuidConfig(length: length);
      final id = cuid.gen();
      info(id);

      expect(id, isNotEmpty);
      expect(isCuid(id), isTrue);
      expect(id, hasLength(length));
    });

    test('given a length greater than the maximum, should throw an error', () {
      final length = Cuid.maxLength + 1;
      action() => cuidConfig(length: length);

      expect(action, throwsArgumentError);
    });

    test('given a length much greater than the maximum, should throw an error',
        () {
      final length = 100;
      action() => cuidConfig(length: length);

      expect(action, throwsArgumentError);

      ArgumentError? error;
      try {
        action();
      } on ArgumentError catch (e) {
        error = e;
      }

      expect(error, isNotNull);
      expect(error?.message, matches(RegExp('.*$length.*')));
    });

    test(
        'given a length much greater than the maximum, should include the length in the error message',
        () {
      final length = 100;
      ArgumentError? error;

      try {
        cuidConfig(length: length);
      } on ArgumentError catch (e) {
        error = e;
      }

      expect(error, isNotNull);
      expect(error?.message, matches(RegExp('.*$length.*')));
    });
  });

  group('createCounter', () {
    test(
        'given a starting number, should return a function that increments the number',
        () {
      final counter = createCounter(10);
      final expected = [10, 11, 12, 13];
      final actual = [counter(), counter(), counter(), counter()];
      info(actual);

      expect(actual, hasLength(expected.length));
      expect(actual, orderedEquals(expected));
    });
  });

  group('bufToBigInt', () {
    test('given an empty Uint8List, should return 0', () {
      final expected = BigInt.zero;
      final actual = bufToBigInt(Uint8List(2));
      info(actual);

      expect(actual, equals(expected));
    });

    test('given a maximum value Uint8List, should return 2^32 - 1', () {
      final expected = BigInt.from(4294967295);
      final actual = bufToBigInt(Uint8List.fromList([0xff, 0xff, 0xff, 0xff]));
      info(actual);

      expect(actual, equals(expected));
    });
  });

  group('createFingerprint', () {
    test('given nothing, should return a string of sufficient length', () {
      final fingerprint = createFingerprint();
      info('Host fingerprint: $fingerprint');

      expect(fingerprint.length >= 24, isTrue);
    });

    test('given an empty environment, should fall back on random entropy', () {
      final fingerprint = createFingerprint(environment: '');
      info('Empty environment fingerprint: $fingerprint');

      expect(fingerprint.length >= 24, isTrue);
    });
  });

  group('isCuid', () {
    test('given a valid cuid, should return true', () {
      final actual = isCuid(cuid());

      expect(actual, isTrue);
    });

    test('given a cuid that is too long, should return false', () {
      final actual = isCuid('${cuid()}${cuid()}${cuid()}');

      expect(actual, isFalse);
    });

    test('given an empty string, should return false', () {
      final actual = isCuid('');

      expect(actual, isFalse);
    });

    test('given a non-CUID string, should return false', () {
      final actual = isCuid('42');

      expect(actual, isFalse);
    });

    test('given a string with capital letters, should return false', () {
      final actual = isCuid('aaaaDLL');

      expect(actual, isFalse);
    });

    test('given a valid CUID2 string, should return true', () {
      final actual = isCuid('yi7rqj1trke');

      expect(actual, isTrue);
    });

    test('given a string with invalid characters (1), should return false', () {
      final actual = isCuid('-x!ha');

      expect(actual, isFalse);
    });

    test('given a string with invalid characters (2), should return false', () {
      final actual = isCuid('ab*%@#x');

      expect(actual, isFalse);
    });
  });

  group('CSPRNG', () {
    test('given multiple cuid2 calls, should generate unique IDs using CSPRNG',
        () {
      // Test that crypto is being used by default
      final id1 = cuid();
      final id2 = cuid();
      final actual = id1 != id2;
      info('ID1: $id1, ID2: $id2');

      expect(actual, isTrue);
    });

    test(
        'given a custom random function, should use the random function instead of CSPRNG',
        () {
      var callCount = 0;
      customRandom() {
        callCount++;
        return 0.5;
      }

      final cuid = cuidConfig(random: customRandom);
      final id = cuid.gen();
      info('Custom random ID: $id, calls: $callCount');

      expect(callCount, greaterThan(0));
    });

    test('given 100 IDs generated with CSPRNG, should all be valid and unique',
        () {
      final ids = List.generate(100, (_) => cuid());
      final allValid = ids.every((id) => isCuid(id));
      final allUnique = Set.from(ids).length == ids.length;

      expect(allValid, isTrue);
      expect(allUnique, isTrue);
    });
  });
}
