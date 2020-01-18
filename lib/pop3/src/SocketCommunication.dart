part of pop3client;

class SocketCommunication {

  SocketCommunication(this.address, this.port) {
    _errorStreamController = StreamController<String>();
    _dataStreamController = StreamController<String>();
  }

  String address;
  num port;

  Socket _socket;

  StreamController<String> _dataStreamController;
  StreamController<String> _errorStreamController;

  Stream get dataStream => _dataStreamController.stream;
  Stream get errorStream => _errorStreamController.stream;

  var onReady = () => { };

  connect() {
    Socket.connect(address, port).then((socket) {
      _socket = socket;
      onReady();
      socket.listen(
          _onSocketData,
          onError: _onSocketError,
          onDone: _onSocketDone
      );
    });
  }

  write(String data) async {
    var encodedData = utf8.encode(data);
    _socket.add(encodedData);
  }

  close() {
    _socket.close();
  }

  _onSocketData(data) {
    var decodedData = utf8.decode(data);
    _dataStreamController.add(decodedData);
  }

  _onSocketError(error, StackTrace trac) {
    _errorStreamController.add(error);
    print(error);
  }

  _onSocketDone() {
    _socket.destroy();
  }
}