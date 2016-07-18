part of domelement;

// TODO: implement one() method
// TODO: return false; stops the bubble event cycle
abstract class EventCapable {
  Element get nativeElement;

  static Map<_EventHandler, EventListener> _eventHandlers =
      new HashMap<_EventHandler, EventListener>(
          equals: (_EventHandler key1, _EventHandler key2) =>
              key1.element == key2.element &&
              key1.type == key2.type &&
              key1.handler == key2.handler);

  void off(String type, Function handler) {
    nativeElement.removeEventListener(type,
        _eventHandlers.remove(new _EventHandler(nativeElement, type, handler)));
  }

  void on(String type, Function handler) {
    EventListener listener = _eventHandlers.putIfAbsent(
        new _EventHandler(nativeElement, type, handler),
        () => _createEventListener(type, handler));
    nativeElement.addEventListener(type, listener);
  }

  void trigger(String type, {dynamic data}) {
    nativeElement.dispatchEvent(new CustomEvent(type, detail: data));
  }

  EventListener _createEventListener(String type, Function handler) {
    return (Event event) {
      List<dynamic> params1 = [
        event,
        event is CustomEvent ? event.detail : null
      ];

      // parameters
      List<dynamic> params2 = [];
      ClosureMirror mirror = reflect(handler);
      List<ParameterMirror> handlerParams = mirror.function.parameters;
      int numParams = handlerParams.length;
      for (int i = 0; i < numParams; i++) {
        if (i >= params1.length) {
          throw new RangeError('The listener has to many parameters');
        }

        // checks the paramter type
        ParameterMirror handlerParam = handlerParams[i];
        TypeMirror paramType = reflectType(params1[i].runtimeType);
        if (params1[i] != null && !paramType.isSubtypeOf(handlerParam.type)) {
          throw new ArgumentError(
              '${paramType.reflectedType} is not a subtype of ' +
                  '${handlerParam.type.reflectedType}');
        }

        params2.add(params1[i]);
      }

      Function.apply(handler, params2);
    };
  }
}

class _EventHandler {
  final Element element;
  final String type;
  final Function handler;
  _EventHandler(this.element, this.type, this.handler);

  @override
  int get hashCode => hash3(element, type, handler);
}
