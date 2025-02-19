import 'dart:async';

abstract class DataStream<T> {
  late StreamController<T> streamController;
  void init() {
    streamController = StreamController();
    reload();
  }

  Stream<T> get stream => streamController.stream;

  void addData(T data) {
    streamController.sink.add(data);
  }

  void addError(dynamic e) {
    streamController.sink.addError(e);
  }

  void reload();

  void dispose() {
    streamController.close();
  }
}
