library pop3client;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

part 'src/SocketCommunication.dart';

enum State {
  ERROR,
  IDLE
}

enum Mode {
  CONNECTION,
  AUTENTICATION,
  STATE,
  LIST
}

class Pop3Client {

  Pop3Client(this.address, this.port);

  final bool DISPLAY_LOGS = true;

  String address;
  num port;

  SocketCommunication _socketCommunication;
  var _commandQueue = List<String>();
  Mode _mode;

  Stream get errorStream => _socketCommunication.errorStream;
  Stream get dataStream => _socketCommunication.dataStream;

  var onReady = () => { };
  var onStatus = (State, Mode) => { };

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
    _commandQueue
      ..add("USER $username")
      ..add("PASS $password");
    _execute();
  }

  stat() async {
    _mode = Mode.STATE;
    _commandQueue.add("STAT");
    _execute();
  }

  list() async {
    _mode = Mode.STATE;
    _commandQueue.add("LIST");
    _execute();
  }

  _execute() {
    if (_commandQueue.isNotEmpty) {
      var command = _commandQueue.removeAt(0);
      _log("Write: ${command.trim()} ");
      _socketCommunication.write("$command\n");
    } else {
      onStatus(State.IDLE, _mode);
    }
  }

  _handleData(String data) {
    _log("Data: $data");

    if (data[0] == "+") {
      _execute();
    } else {
      onStatus(State.ERROR, _mode);
    }
  }

  _log(String message) {
    if (DISPLAY_LOGS) {
      print(message);
    }
  }
}