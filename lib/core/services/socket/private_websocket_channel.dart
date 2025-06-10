import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:presscue_patroller/core/constants/app_constants.dart';
import 'package:presscue_patroller/core/database/boxes.dart';

enum WebSocketChannelType { private, presence }

class PrivateWebSocketService {
  late final WebSocketChannel _channel;
  String? _socketId;

  final token = boxUsers.get(1)?.token ?? '';
  final sectorId = boxUsers.get(1)?.sector_id ?? '';
  final name = boxUsers.get(1)?.name ?? 'Unknown';
  final userId = boxUsers.get(1)?.userId ?? '';

  Function(String eventName, dynamic data)? _onEventReceived;

  void connect({
    required WebSocketChannelType channelType,
    Function(String eventName, dynamic data)? onEventReceived,
  }) {
    _onEventReceived = onEventReceived;

    final wsUrl =
        'ws://${AppConstants.host}:${AppConstants.wsPort}/app/${AppConstants.appKey}';
    final baseChannel = '${AppConstants.channelName}.$sectorId';
    final channelName = channelType == WebSocketChannelType.presence
        ? 'presence-$baseChannel'
        : 'private-$baseChannel';

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel.stream.listen(
      (message) async {
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

        if (event == 'pusher:connection_established') {
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
          }
        } else {
          final eventName = handleEvent(data);
          if (eventName != null) {
            final eventData = jsonDecode(data['data']);
            _onEventReceived?.call(eventName, eventData);
            print('Event "$eventName" handled with data: $eventData');
          }
        }
      },
      onDone: () {
        print('WebSocket connection closed.');
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
    );
  }

  String? handleEvent(Map<String, dynamic> data) {
    final event = data['event'];

    if (event == 'App\\Events\\NewTimeline') {
      return 'new_timeline';
    } else if (event == 'App\\Events\\InitialTimeline') {
      return 'initial_timeline';
    } else if (event == 'pusher:member_added') {
      return 'member_added';
    } else if (event == 'pusher:member_removed') {
      return 'member_removed';
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

        return {
          'auth': authData['auth'],
          'channel_data': authData['channel_data'],
        };
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

  void disconnect() {
    _channel.sink.close();
    print('WebSocket disconnected.');
  }
}
