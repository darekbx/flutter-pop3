library pop3client;

import 'dart:async';
import 'dart:io';

part 'src/SocketCommunication.dart';

class Pop3Client {

  list() async {
    var stream = await SocketCommunication("pop3.poczta.onet.pl", 110)
        .connect() as Stream<String>;
    return stream;
  }
}