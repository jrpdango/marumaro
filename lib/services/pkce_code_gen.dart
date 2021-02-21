import 'dart:math';

class CodeGenerator {
  static final Random _random = Random.secure();

  static String getChar(int number) {
    while (RegExp(r"[^\w\d_-]").hasMatch(String.fromCharCode(number))) {
      number--;
    }
    return String.fromCharCode(number);
  }

  static String next(int min, int max) =>
      getChar(min + _random.nextInt(max - min));

  static String genPKCEcode([int length = 128]) {
    var values = List<String>.generate(length, (i) => next(65, 122));
    return values.join();
  }
}
