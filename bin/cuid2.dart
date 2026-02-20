import 'dart:io';

import 'package:cuid2/src/cuid2_base.dart';

const acceptedParameters = {
  '--help',
  '--length',
  '--fingerprint',
  '--failIfInsecure',
  '--count',
  '--slug',
};

void printHelp() {
  print('''
cuid2 - Secure, collision-resistant ID generator

Usage: cuid2 [options]

Options:
  --count, -n        Number of IDs to generate (default: 1)
  --slug             Generate a short 5-character ID
  --length <n>       Custom ID length (default: 24)
  --fingerprint <s>  Custom fingerprint for ID generation
  --help, -h         Show this help message

Examples:
  cuid2                           # Generate one ID
  cuid2 --count 5                 # Generate 5 IDs
  cuid2 --slug                    # Generate a short ID (5 chars)
  cuid2 --length 10               # Generate 10-character ID
  cuid2 --fingerprint "server1"   # Generate ID with custom fingerprint
''');
}

bool parseBool(String value) {
  switch (value.toLowerCase()) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw FormatException('"$value" is not a valid boolean value.');
  }
}

Map<String, dynamic> parseArguments(List<String> arguments) {
  final parsed = <String, String>{};

  String lastFlag = '';
  for (final arg in arguments) {
    if (arg == '') continue;

    if (arg.startsWith('-')) {
      final equalsIdx = arg.indexOf('=');
      if (equalsIdx < 0) {
        parsed[arg] = 'true';
        lastFlag = arg;
      } else {
        final key = arg.substring(0, equalsIdx);
        final value = arg.substring(equalsIdx + 1);
        parsed[key] = value;
        lastFlag = '';
      }
    } else if (lastFlag != '') {
      parsed[lastFlag] = arg;
      lastFlag = '';
    } else {
      throw ArgumentError('Unexpected positional argument "$arg".');
    }
  }

  return parsed;
}

void expandAliases(Map<String, dynamic> parsedArgs) {
  if (parsedArgs.containsKey('-n')) {
    parsedArgs['--count'] = parsedArgs['-n'];
    parsedArgs.remove('-n');
  }

  if (parsedArgs.containsKey('-h')) {
    parsedArgs['--help'] = parsedArgs['-h'];
    parsedArgs.remove('-h');
  }
}

void main(List<String> arguments) {
  final parsedArgs = parseArguments(arguments);
  expandAliases(parsedArgs);

  final definedArgs = Set<String>.from(parsedArgs.keys);
  final unrecognizedArgs = definedArgs.difference(acceptedParameters);

  if (unrecognizedArgs.isNotEmpty) {
    throw ArgumentError(
        'Unrecognized parameters: ${unrecognizedArgs.join(', ')}');
  }

  if (parsedArgs['--help'] != null) {
    printHelp();
    return;
  }

  try {
    var length = parsedArgs['--length'] != null
        ? int.parse(parsedArgs['--length'])
        : Cuid.defaultLength;
    final fingerprint = parsedArgs['--fingerprint'];
    final failIfInsecure = parsedArgs['--failIfInsecure'] != null
        ? parseBool(parsedArgs['--failIfInsecure'])
        : false;
    final count =
        parsedArgs['--count'] != null ? int.parse(parsedArgs['--count']) : 1;
    final slugMode =
        parsedArgs['--slug'] != null ? parseBool(parsedArgs['--slug']) : false;

    if (slugMode) {
      length = 5;
    }

    if (count <= 0) {
      throw ArgumentError('The value of count must be greater than 0');
    }

    final cuid = Cuid(
      idLength: length,
      fingerprint: fingerprint,
      throwIfInsecure: failIfInsecure,
    );

    for (int i = 0; i < count; i++) {
      print(cuid.gen());
    }
  } catch (e) {
    print(e);
    exit(255);
  }
}
