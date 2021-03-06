import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:action_cable_stream/action_cable_stream.dart';
import 'package:action_cable_stream/action_cable_stream_states.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Action Cable Stream example',
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _channel = 'MyChannel';
  final String _action_cable_url = 'wss://example.com/cable';
  ActionCable _cable;

  @override
  void initState() {
    super.initState();
    _cable = ActionCable.Stream(_action_cable_url);
    _cable.stream.listen((value) {
      if (value is ActionCableConnected) {
        print('ActionCableConnected');
        _cable.subscribeToChannel(_channel, channelParams: {'id': 10});
      } else if (value is ActionCableSubscriptionConfirmed) {
        print('ActionCableSubscriptionConfirmed');
        _cable.performAction(_channel, 'send_message',
            channelParams: {'id': 10}, actionParams: {'body': 'hello world'});
      } else if (value is ActionCableMessage) {
        print('ActionCableMessage ${jsonEncode(value.message)}');
      }
    });
  }

  @override
  void dispose() {
    _cable.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Action Cable Stream example"),
        ),
        body: StreamBuilder(
          stream: _cable.stream,
          initialData: ActionCableInitial(),
          builder: (context, AsyncSnapshot<ActionCableDataState> snapshot) {
            return Center(child: buildBody(snapshot));
          },
        ));
  }
}

Widget buildBody(AsyncSnapshot<ActionCableDataState> snapshot) {
  final state = snapshot.data;

  if (state is ActionCableInitial ||
      state is ActionCableConnectionLoading ||
      state is ActionCableSubscribeLoading) {
    return Text('Loading...');
  } else if (state is ActionCableError) {
    return Text('Error... ${state.message}');
  } else if (state is ActionCableSubscriptionConfirmed) {
    return Text('Subscription confirmed');
  } else if (state is ActionCableSubscriptionRejected) {
    return Text('Subscription rejected');
  } else if (state is ActionCableMessage) {
    return Text('Message received ${jsonEncode(state.message)}');
  } else if (state is ActionCableDisconnected) {
    return Text('Disconnected');
  } else {
    return Text('Something went wrong');
  }
}
