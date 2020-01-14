part of pop3client;

class SocketCommunication {

  SocketCommunication(this.address, this.port);

  String address;
  num port;

  Socket _socket;

  StreamController<String> _dataStreamController;

  connect() async {
    _socket = await Socket.connect(address, port);
    _socket.listen(_onSocketData, onError: _onSocketError, onDone: _onSocketDone);

    _dataStreamController = StreamController<String>();
    return _dataStreamController.stream;
  }

  close() {
    _socket.close();
  }

  _onSocketData(data) {
    var decodedData = String.fromCharCodes(data);
    _dataStreamController.add(decodedData);
  }

  _onSocketError(error, StackTrace trac) {
    print(error);
  }

  _onSocketDone() {
    print("Done");
    _socket.destroy();
  }
}