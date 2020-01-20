import 'action_cable_stream_states.dart';
import 'channel_id.dart';
import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';

class ActionCable {
  IOWebSocketChannel _socketChannel;
  StreamSubscription _listener;
  PublishSubject<ActionCableDataState> stream;

  ActionCable.Stream(
    String url, {
    Map<String, String> headers: const {},
  }) {
    _socketChannel = IOWebSocketChannel.connect(url, headers: headers);
    stream = PublishSubject<ActionCableDataState>();
    stream.sink.add(ActionCableConnectionLoading());
    _listener = _socketChannel.stream.listen(_onData, onError: (Object err) {
      stream.sink.add(ActionCableError('Something went wrong while trying to connect.'));
    });
  }

  void disconnect() {
    _socketChannel.sink.close();
    stream.close();
    _listener.cancel();
  }

  // channelName being 'Chat' will be considered as 'ChatChannel',
  // 'Chat', { id: 1 } => { channel: 'ChatChannel', id: 1 }
  void subscribeToChannel(String channelName, {Map channelParams}) {
    stream.sink.add(ActionCableSubscribeLoading());
    final channelId = encodeChannelId(channelName, channelParams);
    _send({'identifier': channelId, 'command': 'subscribe'});
  }

  void unsubscribeToChannel(String channelName, {Map channelParams}) {
    stream.sink.add(ActionCableUnsubscribeLoading());
    final channelId = encodeChannelId(channelName, channelParams);
    _socketChannel.sink.add(jsonEncode({'identifier': channelId, 'command': 'unsubscribe'}));
  }

  void performAction(String channelName, String actionName, {Map channelParams, Map actionParams}) {
    final channelId = encodeChannelId(channelName, channelParams);

    actionParams ??= {};
    actionParams['action'] = actionName;

    _send({'identifier': channelId, 'command': 'message', 'data': jsonEncode(actionParams)});
  }

  void _onData(dynamic payload) {
    payload = jsonDecode(payload);

    if (payload['type'] != null) {
      _handleProtocolMsg(payload);
    } else {
      _handleDataMsg(payload);
    }
  }

  void _handleProtocolMsg(Map payload) {
    switch (payload['type']) {
      case 'ping':
        // stream.sink.add(ActionCablePing());
        break;
      case 'welcome':
        stream.sink.add(ActionCableConnected());
        break;
      case 'disconnect':
        stream.sink.add(ActionCableDisconnected());
        break;
      case 'confirm_subscription':
        final channelId = parseChannelId(payload['identifier']);
        stream.sink.add(ActionCableSubscriptionConfirmed(channelId));
        break;
      case 'reject_subscription':
        final channelId = parseChannelId(payload['identifier']);
        stream.sink.add(ActionCableSubscriptionRejected(channelId));
        break;
      default:
        stream.sink.add(ActionCableError("Invalid Protocol Message: ${payload['type']}"));
    }
  }

  void _handleDataMsg(Map payload) {
    final channelId = parseChannelId(payload['identifier']);
    stream.sink.add(ActionCableMessage(payload['message']));
  }

  void _send(Map payload) {
    _socketChannel.sink.add(jsonEncode(payload));
  }
}
