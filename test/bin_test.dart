import 'dart:convert';
import 'dart:io';

import 'package:cuid2/cuid2.dart';
import 'package:test/test.dart';

class CliResult {
  final int exitCode;
  final String stdout;
  final String stderr;

  CliResult(this.exitCode, this.stdout, this.stderr);
}

CliResult runCli([List<String>? args]) {
  final result = Process.runSync(
    'dart',
    ['${Directory.current.path}/bin/cuid2.dart', ...(args ?? [])],
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  return CliResult(result.exitCode, result.stdout.trim(), result.stderr.trim());
}

void main() {
  group('CLI bin/cuid2.dart', () {
    test('given no arguments, should generate a single valid identifier', () {
      final result = runCli();
      final lines = result.stdout.split('\n');

      expect(result.exitCode, isZero);
      expect(lines, hasLength(1));
      expect(isCuid(lines[0]), isTrue);
    });

    test(
        'given a count parameter, should generate the requested number of identifiers',
        () {
      final result = runCli(['--count', '3']);
      final lines = result.stdout.split('\n');

      expect(result.exitCode, isZero);
      expect(lines, hasLength(3));
      expect(lines, everyElement((l) => isCuid(l)));
    });

    test(
        'given slug mode, should generate a short identifier suitable for URL disambiguation',
        () {
      final result = runCli(['--slug']);
      final id = result.stdout;

      expect(result.exitCode, isZero);
      expect(id, hasLength(5));
      expect(isCuid(id), isTrue);
    });

    test(
        'given slug mode with a count parameter, should generate the requested number of short identifiers',
        () {
      final result = runCli(['--slug', '--count', '2']);
      final lines = result.stdout.split('\n');

      expect(result.exitCode, isZero);
      expect(lines, hasLength(2));
      expect(lines, everyElement(hasLength(5)));
      expect(lines, everyElement((l) => isCuid(l)));
    });

    test(
        'given a custom length parameter, should generate an identifier of the specified length',
        () {
      final result = runCli(['--length', '10']);
      final id = result.stdout;

      expect(result.exitCode, isZero);
      expect(id, hasLength(10));
      expect(isCuid(id), isTrue);
    });

    test(
        'given a custom length parameter with a count parameter, should generate an identifier of the specified length',
        () {
      final result = runCli(['--length', '8', '--count', '3']);
      final lines = result.stdout.split('\n');

      expect(result.exitCode, isZero);
      expect(lines, hasLength(3));
      expect(lines, everyElement(hasLength(8)));
      expect(lines, everyElement((l) => isCuid(l)));
    });

    test(
        'given a custom fingerprint, should generate valid identifiers incorporating the provided fingerprint',
        () {
      final result1 = runCli(['--fingerprint', 'server-1']);
      final result2 = runCli(['--fingerprint', 'server-2']);
      final id1 = result1.stdout;
      final id2 = result2.stdout;

      expect(result1.exitCode, isZero);
      expect(isCuid(id1), isTrue);
      expect(result2.exitCode, isZero);
      expect(isCuid(id2), isTrue);
    });

    test(
        'given multiple configuration options, should generate identifiers respecting all provided options',
        () {
      final result =
          runCli(['--length', '6', '--fingerprint', 'test', '-n', '2']);
      final lines = result.stdout.split('\n');

      expect(result.exitCode, isZero);
      expect(lines, hasLength(2));
      expect(lines, everyElement(hasLength(6)));
      expect(lines, everyElement((l) => isCuid(l)));
    });

    test(
        'given the help flag, should display usage information with options and examples',
        () {
      final result = runCli(["--help"]);
      final hasUsage = result.stdout.contains("Usage:");
      final hasOptions = result.stdout.contains("Options:");
      final hasExamples = result.stdout.contains("Examples:");

      expect(result.exitCode, isZero);
      expect(hasUsage, isTrue);
      expect(hasOptions, isTrue);
      expect(hasExamples, isTrue);
    });
  });
}
