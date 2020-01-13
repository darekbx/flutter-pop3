part of pop3client;

class SocketCommunication {

  Socket _socket;

  connect() async {
    _socket = await Socket.connect("pop3.poczta.onet.pl", 110);
    _socket.listen(_onSocketData, onError: _onSocketError, onDone: _onSocketDone);
  }

  close() {
    _socket.close();
  }

  _onSocketData(data) {
    print(String.fromCharCodes(data));
  }

  _onSocketError(error, StackTrace trac) {
    print(error);
  }

  _onSocketDone() {
    print("Done");
    _socket.destroy();
  }
}