import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:presscue_patroller/core/constants/app_constants.dart';
import 'package:presscue_patroller/core/database/boxes.dart';

enum WebSocketChannelType { private, presence }

enum WebSocketConnectionStatus { connected, disconnected }

class PrivateWebSocketService {
  late WebSocketChannel _channel;
  String? _socketId;
  Timer? _reconnectTimer;
  Duration _reconnectDelay =
      const Duration(seconds: 5); // Fixed or increase this for backoff
  bool _shouldReconnect = false;

  final token = boxUsers.get(1)?.token ?? '';
  final sectorId = boxUsers.get(1)?.sector_id ?? '';
  final name = boxUsers.get(1)?.name ?? 'Unknown';
  final userId = boxUsers.get(1)?.userId ?? '';

  Function(String eventName, dynamic data)? _onEventReceived;
  Function(WebSocketConnectionStatus)? _onStatusChanged;
  WebSocketChannelType? _channelType;

  void connect({
    required WebSocketChannelType channelType,
    required Function(WebSocketConnectionStatus) onStatusChanged,
    Function(String eventName, dynamic data)? onEventReceived,
    String? customChannelPrefix,
  }) {
    _onEventReceived = onEventReceived;
    _onStatusChanged = onStatusChanged;
    _channelType = channelType;
    _shouldReconnect = true;

    final wsUrl =
        'ws://${AppConstants.host}:${AppConstants.wsPort}/app/${AppConstants.appKey}';
    final channelName = channelType == WebSocketChannelType.presence
        ? 'presence-${AppConstants.channelName}.$sectorId'
        : '${customChannelPrefix ?? "private-patroller"}';

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel.stream.listen(
      (message) async {
        _onStatusChanged?.call(WebSocketConnectionStatus.connected);
        print('Received message: $message');

        Map<String, dynamic> data;
        try {
          data = jsonDecode(message);
        } catch (e) {
          print('JSON decode error: $e');
          return;
        }

        final event = data['event'];
        print('Parsed event: $event');

        if (event == 'pusher:ping' || message.toString().contains('ping')) {
          _channel.sink.add(jsonEncode({"event": "pusher:pong"}));
          print('pong sent');
          return;
        }

        final eventName = handleEvent(data);
        final dynamic rawData = data['data'];
        final dynamic eventData =
            rawData is String ? jsonDecode(rawData) : rawData;

        if (event == 'pusher:connection_established' && eventName != null) {
          final connectionData = jsonDecode(data['data']);
          _socketId = connectionData['socket_id'];

          final authResult =
              await _authenticate(_socketId!, channelName, token);

          if (authResult != null) {
            _subscribeToChannel(
              channelType,
              channelName,
              authResult['auth']!,
              channelData: authResult['channel_data'],
            );
            _onEventReceived?.call(eventName, eventData);
          }
        } else {
          if (eventName != null) {
            _onEventReceived?.call(eventName, eventData);
            // print('Event "$eventName" handled with data: $eventData');
          }
        }
      },
      onDone: () {
        print('WebSocket connection closed.');
        _onStatusChanged?.call(WebSocketConnectionStatus.disconnected);
        if (_shouldReconnect) _scheduleReconnect();
      },
      onError: (error) {
        print('WebSocket error: $error');
        _onStatusChanged?.call(WebSocketConnectionStatus.disconnected);
        if (_shouldReconnect) _scheduleReconnect();
      },
      cancelOnError: true,
    );
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    print('Attempting reconnect in ${_reconnectDelay.inSeconds} seconds...');
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_shouldReconnect &&
          _channelType != null &&
          _onStatusChanged != null) {
        connect(
          channelType: _channelType!,
          onStatusChanged: _onStatusChanged!,
          onEventReceived: _onEventReceived,
        );
      }
    });
  }

  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _channel.sink.close();
    print('WebSocket manually disconnected.');
  }

  String? handleEvent(Map<String, dynamic> data) {
    final event = data['event'];

    if (event == 'pusher:connection_established') {
      return 'connection_established';
    } else if (event == 'pusher:error') {
      return 'error';
    } else if (event == 'App\\Events\\NewTimeline') {
      return 'new_timeline';
    } else if (event == 'App\\Events\\InitialTimeline') {
      return 'initial_timeline';
    } else if (event == 'App\\Events\\PatrollerDispatched') {
      return 'patroller_dispatched';
    }

    return null;
  }

  Future<Map<String, String>?> _authenticate(
    String socketId,
    String channelName,
    String sanctumToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.authEndPoint),
        headers: {
          'Authorization': 'Bearer $sanctumToken',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: Uri(queryParameters: {
          'socket_id': socketId,
          'channel_name': channelName,
        }).query,
      );

      print('Auth response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final authData = jsonDecode(response.body);

        final result = <String, String>{
          'auth': authData['auth'],
        };

        if (authData['channel_data'] != null) {
          result['channel_data'] = authData['channel_data'];
        }

        return result;
      } else {
        print('Auth failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Authentication Error: $e');
      return null;
    }
  }

  void _subscribeToChannel(
    WebSocketChannelType type,
    String channelName,
    String authToken, {
    String? channelData,
  }) {
    final subscriptionData = {
      'auth': authToken,
      'channel': channelName,
      if (type == WebSocketChannelType.presence && channelData != null)
        'channel_data': channelData,
    };

    final subscriptionMessage = {
      'event': 'pusher:subscribe',
      'data': subscriptionData,
    };

    print(subscriptionMessage);
    _channel.sink.add(jsonEncode(subscriptionMessage));
    print('Subscribed to ${type.name} channel "$channelName"');
  }
}

final webSocketConnectionStatusProvider =
    StateProvider<WebSocketConnectionStatus>(
  (ref) => WebSocketConnectionStatus.disconnected,
);
