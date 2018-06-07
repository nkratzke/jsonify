import 'dart:convert';

JSONMap jsonify(Map<String, String> storage) => new JSONMap(storage);

class JSONMap implements Map<String, Object> {

  Map<String, String> _storage;
  Map<String, Object> _json;

  JSONMap(this._storage) {
    _json = new Map<String, Object>();
    _storage.forEach((key, value) {
      try { _json[key] = JSON.decode(_storage[key].toString()); }
      catch (ex) { _json[key] = _storage[key]; }
    });
  }

  Iterable<String> get keys => _json.keys;
  Iterable<Object> get values => _json.values;
  int get hashCode => _json.hashCode;
  bool get isEmpty => keys.isEmpty;
  bool get isNotEmpty => !isEmpty;
  int get length => keys.length;

  Object operator [](Object k) {
    if (!_json.containsKey(k)) return null;
    Object v = _json[k];
    if (v is Map) return jsonify(v);
    if (v is List) { return v.map((i) => i is Map ? jsonify(i) : i).toList(); }
    return v;
  }

  void operator []=(String k, Object v) {
    _json[k] = v;
    _json.forEach((k, v) => _storage[k] = JSON.encode(_json[k]));
  }

  bool operator ==(other) => other.asMap() == this.asMap();

  void addAll(Map<String, Object> other) => other.forEach((k, v) => this[k] = v);

  void clear() {
    _json.clear();
    _storage.clear();
  }

  void forEach(void f(String k, Object v)) => _json.forEach(f);

  Object putIfAbsent(String k, Object ifAbsent()) {
    Object current = this[k];
    if (current == null) this[k] = ifAbsent();
    return current;
  }

  Object remove(Object k) {
    _storage.remove(k);
    return _json.remove(k);
  }

  Map<String, Object> asMap() => _json;

  Map<String, String> backend() => _storage;

  static String _getter(Symbol s) => s.toString().split('"')[1];
  static String _setter(Symbol s) => s.toString().split('"')[1].replaceAll("=", "");

  Object noSuchMethod(Invocation i) {
    if (i.isSetter) {
      return this[_setter(i.memberName)] = i.positionalArguments.first;
    }
    return this[_getter(i.memberName)];
  }

  String toString() => _storage.toString();

}
