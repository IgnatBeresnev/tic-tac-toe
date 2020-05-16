class EventHandler {
  final handlers = Map<String, Function(Map<String, dynamic>)>();

  void onEvent(String eventName, Function(Map<String, dynamic>) action) {
    handlers[eventName] = action;
  }

  void handle(String eventName, Map<String, dynamic> eventMap) {
    print("Handling event: " + eventMap.toString());
    handlers[eventName]?.call(eventMap);
  }
}
