import 'package:flutter_test/flutter_test.dart';
import 'package:marumaro/core/core.dart';

void main() {
  group("formatCount", () {
    test("leaves sub-thousand counts untouched", () {
      expect(formatCount(0), "0");
      expect(formatCount(999), "999");
    });

    test("formats thousands with one decimal", () {
      expect(formatCount(1000), "1K");
      expect(formatCount(183703), "183.7K");
    });

    test("formats millions with one decimal", () {
      expect(formatCount(2227190), "2.2M");
    });

    test("promotes to the next unit at the rounding boundary", () {
      expect(formatCount(999949), "999.9K");
      expect(formatCount(999950), "1M");
      expect(formatCount(999949999), "999.9M");
      expect(formatCount(999950000), "1B");
    });
  });
}
