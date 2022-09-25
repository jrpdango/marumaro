import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Deletes locally-stored tokens.
///
void deleteLocalTokens() async {
  Directory directory = await getApplicationDocumentsDirectory();
  File('${directory.path}/miruTokens.json').deleteSync();
}
