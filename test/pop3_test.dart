import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_mail/pop3/pop3client.dart';

import 'dart:async';

void main() {
  test('POP3 Connect test', () async {
    final pop3 = Pop3Client("pop3.poczta.onet.pl", 110);

    var readyCompleter = Completer();
    var statusCompleter = Completer();

    pop3.onReady = () {
      readyCompleter.complete();
    };

    pop3.initialize();

    pop3.onStatus = (status) {
      if (status == State.SERVER_READY) {
        statusCompleter.complete();
      } else {
        fail("Wrong status $status");
      }
    };

    pop3.connect();

    await readyCompleter.future;
    await statusCompleter.future;
  });
}