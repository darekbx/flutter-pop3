library pop3client;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'dart:math';

part 'src/SocketCommunication.dart';

enum State {
  ERROR,
  IDLE
}

enum Mode {
  CONNECTION,
  AUTENTICATION,
  COMMAND
}

enum Command {
  STAT,
  LIST,
  TOP,
  RETR,
  DELE,
  NOOP,
  QUIT,
  RSET
}

class Pop3Client {

  Pop3Client(this.address, this.port);

  final bool DISPLAY_LOGS = true;
  final CRLF = '\n';
  final END_CHAR = '.';

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

  Completer _commandCompleter = null;
  List<String> _commandData = null;

  Future<List<String>> command(Command command, {List<String> arguments}) async {
    _mode = Mode.COMMAND;

    var commandString = "${command.toString().split('.').last}";
    if (arguments != null && arguments.length > 0) {
      arguments.forEach((argument) {
        commandString += " $argument";
      });
    }

    _commandCompleter = Completer<List<String>>();
    _commandData = List<String>();
    _commandQueue.clear();
    _commandQueue.add(commandString);
    _execute();

    return await _commandCompleter.future;
  }

  _execute() {
    if (_commandQueue.isNotEmpty) {
      var command = _commandQueue.removeAt(0);
      _log("Write: $command");
      _socketCommunication.write("${command.trim()}$CRLF");
    } else {
      onStatus(State.IDLE, _mode);
    }
  }

  _handleData(String data) {
    print(data);
    if (data[0] == "-") {
      onStatus(State.ERROR, _mode);
    } else {
      if (_mode == Mode.COMMAND) {
        var last = data[data.length - 3];
        if (last == END_CHAR) {
          _commandCompleter.complete(_commandData);
        } else {
          _commandData.add(data);
        }
      } else if (_mode == Mode.AUTENTICATION || _mode == Mode.CONNECTION) {
        _execute();
      }
    }
  }

  _log(String message) {
    if (DISPLAY_LOGS) {
      print(message);
    }
  }
}