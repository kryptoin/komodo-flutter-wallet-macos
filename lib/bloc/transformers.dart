import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

EventTransformer<T> debounce<T>([int ms = 300]) {
  return (events, mapper) {
    final duration = Duration(milliseconds: ms);
    final Stream<T> debounced = debounceStream(events, duration);
    final Stream<Stream<T>> mapped = debounced.map(mapper);

    return flattenStream(mapped);
  };
}

Stream<T> flattenStream<T>(Stream<Stream<T>> source) async* {
  await for (var stream in source) {
    yield* stream;
  }
}

Stream<T> debounceStream<T>(Stream<T> source, Duration duration) {
  final controller = StreamController<T>.broadcast();
  Timer? timer;

  source.listen((T event) async {
    timer?.cancel();
    timer = Timer(duration, () {
      controller.sink.add(event);
    });
  });

  return controller.stream;
}
