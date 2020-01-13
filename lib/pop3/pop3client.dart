library pop3client;

import 'dart:async';
import 'dart:io';

part 'src/SocketCommunication.dart';

class Pop3Client {

  list() async {
    await SocketCommunication().connect();

  }
}