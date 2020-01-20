import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_mail/pop3/pop3client.dart';

import 'dart:async';

void main() {

  final host = "pop3.poczta.onet.pl";
  final user = "user";
  final pass = "pass";

  test('POP3 Connection', () async {
    final pop3 = Pop3Client(host, 110);

    var readyCompleter = Completer();

    pop3.onReady = () {
      readyCompleter.complete();
    };

    pop3.initialize();

    pop3.connect();

    await readyCompleter.future;
  });

  test('POP3 Authentication', () async {
    final pop3 = Pop3Client(host, 110);

    var authenticationCompleter = Completer();

    pop3.initialize();

    pop3.onStatus = (status, mode) {
      if (status == State.IDLE && mode == Mode.CONNECTION) {
        pop3.authenticate(user, pass);
      } else if (status == State.IDLE && mode == Mode.AUTENTICATION) {
        authenticationCompleter.complete();
      } else {
        fail("Wrong status $status");
      }
    };

    pop3.connect();

    await authenticationCompleter.future;
  });

  test('POP3 State', () async {
    final pop3 = Pop3Client(host, 110);

    var stateCompleter = Completer();

    pop3.initialize();

    pop3.onStatus = (status, mode) {
      if (status == State.IDLE && mode == Mode.CONNECTION) {
        pop3.authenticate(user, pass);
      } else if (status == State.IDLE && mode == Mode.AUTENTICATION) {
        pop3.stat();
      } else if (status == State.IDLE && mode == Mode.STATE) {
        stateCompleter.complete();
      } else {
        fail("Wrong status $status");
      }
    };

    pop3.connect();

    await stateCompleter.future;
  });

  test('POP3 List', () async {
    final pop3 = Pop3Client(host, 110);

    var listCompleter = Completer();

    pop3.initialize();

    pop3.onStatus = (status, mode) {
      if (status == State.IDLE && mode == Mode.CONNECTION) {
        pop3.authenticate(user, pass);
      } else if (status == State.IDLE && mode == Mode.AUTENTICATION) {
        pop3.list();
      } else if (status == State.IDLE && mode == Mode.LIST) {
        listCompleter.complete();
      } else {
        fail("Wrong status $status");
      }
    };

    pop3.connect();

    await listCompleter.future;
  });
}