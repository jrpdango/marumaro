import 'package:flutter_test/flutter_test.dart';
import 'package:marumaro/core/core.dart';

void main() {
  group("parseIsNsfw", () {
    test("treats gray and black as adult content", () {
      expect(parseIsNsfw("gray"), isTrue);
      expect(parseIsNsfw("black"), isTrue);
      expect(parseIsNsfw("GRAY"), isTrue);
    });

    test("treats white and missing values as safe", () {
      expect(parseIsNsfw("white"), isFalse);
      expect(parseIsNsfw(null), isFalse);
      expect(parseIsNsfw("unknown"), isFalse);
    });

    test("accepts bools for backward compatibility", () {
      expect(parseIsNsfw(true), isTrue);
      expect(parseIsNsfw(false), isFalse);
    });
  });
}
