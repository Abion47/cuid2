import 'package:cuid2/src/utility.dart';

class Cuid {
  static final _cache = <String, Cuid>{};
  static final _alphabet =
      List.generate(26, (i) => String.fromCharCode(i + 97), growable: false);

  static const int defaultLength = 24;
  static const int maxLength = 32;

  // ~22k hosts before 50% chance of initial counter collision
  // with a remaining counter range of 9.0e+15 in JavaScript.
  static const int _initialCountMax = 476782367;

  final int idLength;
  late final double Function() random;
  late final int Function() counter;
  late final String fingerprint;

  Cuid._create({
    this.idLength = defaultLength,
    double Function()? random,
    int Function()? counter,
    String? fingerprint,
    bool throwIfInsecure = false,
  }) : random = random ?? createRandom(throwIfInsecure: throwIfInsecure) {
    this.fingerprint = fingerprint ?? createFingerprint(random: this.random);
    this.counter =
        counter ?? createCounter((this.random() * _initialCountMax).floor());
  }

  factory Cuid({
    int idLength = defaultLength,
    double Function()? random,
    int Function()? counter,
    String? fingerprint,
    bool throwIfInsecure = false,
  }) {
    if (idLength < 2 || idLength > maxLength) {
      throw ArgumentError(
          'Length must be between 2 and $maxLength. Received: $idLength');
    }

    return _cache.putIfAbsent(
      '${random.hashCode}$idLength${counter.hashCode}$fingerprint',
      () => Cuid._create(
        idLength: idLength,
        random: random,
        counter: counter,
        fingerprint: fingerprint,
        throwIfInsecure: throwIfInsecure,
      ),
    );
  }

  static String _randomLetter(double Function() random) {
    return _alphabet[(random() * _alphabet.length).floor()];
  }

  /// Generates a new id based on the instance configuration
  String gen() {
    final firstLetter = _randomLetter(random);
    final time = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    String count = counter().toRadixString(36);

    // The salt should be long enough to be globally unique across the full
    // length of the hash. For simplicity, we use the same length as the
    // intended id output.
    final salt = createEntropy(random, length: idLength);
    final hashInput = "$time$salt$count$fingerprint";

    return "$firstLetter${hash(hashInput).substring(1, idLength)}";
  }
}
