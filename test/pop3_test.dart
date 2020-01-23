import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_mail/pop3/pop3client.dart';

import 'dart:async';
import 'dart:io';
import 'dart:convert';

void main() {

  final host = "pop3.poczta.onet.pl";

  Future<MapEntry<String, String>> readCredentials() async {
    final file = new File('credentials.json');
    final json = jsonDecode(await file.readAsString());
    return MapEntry<String, String>(json["user"], json["password"]);
  }

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
    var credentials = await readCredentials();

    var authenticationCompleter = Completer();

    pop3.initialize();

    pop3.onStatus = (status, mode) {
      if (status == State.IDLE && mode == Mode.CONNECTION) {
        pop3.authenticate(credentials.key, credentials.value);
      } else if (status == State.IDLE && mode == Mode.AUTENTICATION) {
        authenticationCompleter.complete();
      } else {
        fail("Wrong status $status");
      }
    };

    pop3.connect();

    await authenticationCompleter.future;
  });

  handleList(Pop3Client pop3, Completer listCompleter) async {

    var result = await pop3.command(Command.LIST);
    print("Items count: ${result.length}");

    if (result.length > 0) {
      listCompleter.complete();
    } else {
      fail("Empty list");
    }
  }

  test('POP3 List', () async {
    final pop3 = Pop3Client(host, 110);
    var credentials = await readCredentials();

    var listCompleter = Completer();

    pop3.initialize();

    pop3.onStatus = (status, mode)  {
      if (status == State.IDLE && mode == Mode.CONNECTION) {
        pop3.authenticate(credentials.key, credentials.value);
      } else if (status == State.IDLE && mode == Mode.AUTENTICATION) {
        handleList(pop3, listCompleter);
      } else {
        fail("Wrong status $status");
      }
    };

    pop3.connect();

    await listCompleter.future;
  });
}