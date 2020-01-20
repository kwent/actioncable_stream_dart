class ActionCableDataState {}

class ActionCableInitial extends ActionCableDataState {}

class ActionCablePing extends ActionCableDataState {}

class ActionCableConnected extends ActionCableDataState {}

class ActionCableConnectionLoading extends ActionCableDataState {}

class ActionCableDisconnected extends ActionCableDataState {}

class ActionCableError extends ActionCableDataState {
  final Object message;

  ActionCableError(this.message);
}

class ActionCableSubscribeLoading extends ActionCableDataState {}

class ActionCableSubscriptionConfirmed extends ActionCableDataState {
  final String channelId;

  ActionCableSubscriptionConfirmed(this.channelId);
}

class ActionCableSubscriptionRejected extends ActionCableDataState {
  final String channelId;

  ActionCableSubscriptionRejected(this.channelId);
}

class ActionCableUnsubscribeLoading extends ActionCableDataState {}

class ActionCableMessage extends ActionCableDataState {
  final Map message;

  ActionCableMessage(this.message);
}
