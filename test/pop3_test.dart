import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_mail/pop3/pop3client.dart';

void main() {
  test('POP3 Connect test', () async {
      final pop3 = Pop3Client();

      var stream = await pop3.list() as Stream<String>;

      stream.listen(expectAsync1((data) { expect(data.trim(), "+OK Onet server ready."); }));
  });
}
