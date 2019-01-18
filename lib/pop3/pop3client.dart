library pop3client;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

part 'src/SocketCommunication.dart';

enum State {
  SERVER_READY,
  AUTHENTICATED,
  AUTHENTICATION_ERROR,
  ERROR
}

enum Mode {
  CONNECTION,
  AUTENTICATION,
  LIST
}

class Pop3Client {

  Pop3Client(this.address, this.port);

  String address;
  num port;

  SocketCommunication _socketCommunication;
  Mode _mode;

  Stream get errorStream => _socketCommunication.errorStream;
  Stream get dataStream => _socketCommunication.dataStream;

  var onReady = () => { };
  var onStatus = (State) => { };

  initialize() {
    _socketCommunication = SocketCommunication(address, port);
    _socketCommunication.onReady = onReady;
    _socketCommunication.dataStream.listen((data) => _handleData(data));
  }

  connect() {
    _mode = Mode.CONNECTION;
    _socketCommunication.connect();
  }

  authenticate(String username, String password) {
    _mode = Mode.AUTENTICATION;
    _socketCommunication.write("USER $username\n");
    _socketCommunication.write("PASS $password\n");
  }

  list() async {

  }

  _handleData(String data) {
    switch(_mode) {
      case Mode.CONNECTION:
        _handleConnection(data);
        break;
      case Mode.AUTENTICATION:
        _handleAuthentication(data);
        break;
      case Mode.LIST:

        break;
    }
  }

  _handleConnection(data) {
    if (data[0] == "+") {
      onStatus(State.SERVER_READY);
    } else {
      onStatus(State.ERROR);
    }
  }

  _handleAuthentication(data) {
    if (data[0] == "+") {
      onStatus(State.AUTHENTICATED);
    } else {
      onStatus(State.AUTHENTICATION_ERROR);
    }
  }
}