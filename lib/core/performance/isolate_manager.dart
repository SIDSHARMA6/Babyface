import 'dart:async';
import 'dart:isolate';
import 'dart:developer' as developer;

/// Isolate manager for background processing
/// Follows master plan performance standards - Zero ANR Policy
class IsolateManager {
  static final IsolateManager _instance = IsolateManager._internal();
  factory IsolateManager() => _instance;
  IsolateManager._internal();

  final Map<String, Isolate> _isolates = {};
  final Map<String, Completer> _completers = {};

  /// Execute heavy computation in isolate
  static Future<T> compute<Q, T>(
    ComputeCallback<Q, T> callback,
    Q message, {
    String? debugLabel,
  }) async {
    return await IsolateManager()._executeInIsolate(callback, message, debugLabel);
  }

  /// Execute computation in isolate with custom isolate
  Future<T> _executeInIsolate<Q, T>(
    ComputeCallback<Q, T> callback,
    Q message,
    String? debugLabel,
  ) async {
    final completer = Completer<T>();
    final isolateId = debugLabel ?? 'isolate_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      // Create isolate
      final isolate = await Isolate.spawn(
        _isolateEntryPoint<Q, T>,
        _IsolateData<Q, T>(
          callback: callback,
          message: message,
          sendPort: _createSendPort(completer, isolateId),
        ),
        debugName: debugLabel,
      );
      
      _isolates[isolateId] = isolate;
      _completers[isolateId] = completer;
      
      // Set up timeout
      Timer(const Duration(minutes: 5), () {
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException('Isolate execution timeout', const Duration(minutes: 5)));
          _cleanupIsolate(isolateId);
        }
      });
      
      return await completer.future;
    } catch (e) {
      developer.log(
        'Isolate execution failed: $e',
        name: 'IsolateManager',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Create send port for isolate communication
  SendPort _createSendPort<T>(Completer<T> completer, String isolateId) {
    final receivePort = ReceivePort();
    
    receivePort.listen((data) {
      if (data is _IsolateResult<T>) {
        if (data.isError) {
          completer.completeError(data.error!);
        } else {
          completer.complete(data.result);
        }
        _cleanupIsolate(isolateId);
        receivePort.close();
      }
    });
    
    return receivePort.sendPort;
  }

  /// Cleanup isolate resources
  void _cleanupIsolate(String isolateId) {
    _isolates[isolateId]?.kill();
    _isolates.remove(isolateId);
    _completers.remove(isolateId);
  }

  /// Kill all isolates
  void killAllIsolates() {
    for (final isolate in _isolates.values) {
      isolate.kill();
    }
    _isolates.clear();
    _completers.clear();
  }

  /// Get active isolate count
  int get activeIsolateCount => _isolates.length;

  /// Check if isolate is running
  bool isIsolateRunning(String isolateId) => _isolates.containsKey(isolateId);
}

/// Isolate entry point
void _isolateEntryPoint<Q, T>(_IsolateData<Q, T> data) async {
  try {
    final result = await data.callback(data.message);
    data.sendPort.send(_IsolateResult<T>.success(result));
  } catch (e, stackTrace) {
    data.sendPort.send(_IsolateResult<T>.error(e, stackTrace));
  }
}

/// Data passed to isolate
class _IsolateData<Q, T> {
  final ComputeCallback<Q, T> callback;
  final Q message;
  final SendPort sendPort;

  _IsolateData({
    required this.callback,
    required this.message,
    required this.sendPort,
  });
}

/// Result from isolate
class _IsolateResult<T> {
  final T? result;
  final Object? error;
  final StackTrace? stackTrace;
  final bool isError;

  _IsolateResult._({
    this.result,
    this.error,
    this.stackTrace,
    required this.isError,
  });

  factory _IsolateResult.success(T result) {
    return _IsolateResult._(
      result: result,
      isError: false,
    );
  }

  factory _IsolateResult.error(Object error, StackTrace stackTrace) {
    return _IsolateResult._(
      error: error,
      stackTrace: stackTrace,
      isError: true,
    );
  }
}

/// Compute callback type
typedef ComputeCallback<Q, T> = Future<T> Function(Q message);

/// Timeout exception
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}
