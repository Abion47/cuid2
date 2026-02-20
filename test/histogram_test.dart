import 'package:test/test.dart';

import './utils.dart';

void main() {
  group('histogram', () {
    const n = 100000;
    info('Testing $n unique IDs...');
    final pool = createIdPool(max: n);
    final ids = pool['ids']!.split(':');
    final sampleIds = ids.take(10);
    final set = Set.from(ids);

    test('given lots of ids generated, should generate no collisions', () {
      expect(set, hasLength(n));
    });

    // Arrange
    const idTolerance = 0.1;
    const idLength = 23;
    const totalLetters = idLength * n;
    const base = 36;
    final expectedIdBinSize = (totalLetters / base).ceil();
    final minIdBinSize = (expectedIdBinSize * (1 - idTolerance)).ceil();
    final maxIdBinSize = (expectedIdBinSize * (1 + idTolerance)).ceil();

    // Act
    // Drop the first character because it will always be a letter, making
    // the letter frequency skewed.
    final testIds = ids.map((id) => id.substring(2));
    final charFrequencies = <String, int>{};
    for (final id in testIds) {
      for (final char in id.split('')) {
        charFrequencies[char] = (charFrequencies[char] ?? 0) + 1;
      }
    }

    info("Testing character frequency...");
    info('expectedBinSize: $expectedIdBinSize');
    info('minBinSize: $minIdBinSize');
    info('maxBinSize: $maxIdBinSize');
    info('charFrequencies: $charFrequencies');

    test('given lots of ids generated, should produce even character frequency',
        () {
      expect(charFrequencies.values,
          everyElement((x) => x > minIdBinSize && x < maxIdBinSize));
    });

    test('given lots of ids generated, should represent all character values',
        () {
      expect(charFrequencies.length, base);
    });

    final histogram = pool['histogram']!.split(':').map(int.parse);
    info('sample ids:');
    for (var id in sampleIds) {
      info('  $id');
    }
    info('histogram: $histogram');
    final expectedHistoBinSize = (n / histogram.length).ceil();
    const histoTolerance = 0.1;
    final minHistoBinSize =
        (expectedHistoBinSize * (1 - histoTolerance)).round();
    final maxHistoBinSize =
        (expectedHistoBinSize * (1 + histoTolerance)).round();
    info('expectedBinSize: $expectedHistoBinSize');
    info('minBinSize: $minHistoBinSize');
    info('maxBinSize: $maxHistoBinSize');

    test(
        'given lots of ids generated, should produce a histogram within distribution tolerance',
        () {
      expect(histogram,
          everyElement((x) => x > minHistoBinSize && x < maxHistoBinSize));
    });
  });
}
