import 'dart:convert';

class JMap {
  JSONStorage _root;
  Map<dynamic, dynamic> _map;

  JMap(this._map, this._root);

  bool get isEmpty => _map.isEmpty;
  bool get isNotEmpty => !isEmpty;
  int get length => _map.length;

  JList get values => new JList(_map.values, _root);

  dynamic operator[](dynamic key) => _wrap(_map[key], _root);

  void operator[]=(dynamic key, dynamic value) {
    _map[key] = value;
    _root.write();
  }

  void addAll(Map<dynamic, dynamic> other) {
    _map.addAll(other);
    _root.write();
  }

  void clear() { _map.clear(); _root.write(); }

  dynamic remove(dynamic key) {
    dynamic before = _map.remove(key);
    _root.write();
    return before;
  }

  dynamic noSuchMethod(Invocation i) {
    if (i.isGetter) return this[_getter(i.memberName)];
    if (i.isSetter) {
      this[_setter(i.memberName)] = i.positionalArguments.single;
      _root.write();
    }
  }
}

dynamic _wrap(dynamic element, JSONStorage root) {
  if (element is Map) return new JMap(element, root);
  if (element is List) return new JList(element, root);
  return element;
}

String _getter(Symbol s) => s.toString().split('"')[1];

String _setter(Symbol s) => s.toString().split('"')[1].replaceAll("=", "");

class JList extends Iterable {
  JSONStorage _root;
  List<dynamic> _list;

  JList(this._list, this._root);

  int get length => _list.length;
  JList get reversed => new JList(_list.reversed.toList(), _root);
  Iterator<dynamic> get iterator => _list.iterator;
  dynamic get first => this[0];
  dynamic get last => this[length - 1];
  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => !isEmpty;

  dynamic operator[](int i) =>_wrap(_list[i], _root);

  void operator[]=(int i, dynamic value) {
    _list[i] = value;
    _root.write();
  }

  void add(dynamic value) {
    _list.add(value);
    _root.write();
  }

  void addAll(Iterable<dynamic> values) {
    _list.addAll(values);
    _root.write();
  }

  void clear() {
    _list.clear();
    _root.write();
  }

  bool remove(dynamic value) {
    bool removed = _list.remove(value);
    if (removed) _root.write();
    return removed;
  }

  bool removeAt(int i) {
    dynamic element = _wrap(_list.removeAt(i), _root);
    if (element != null) _root.write();
    return element;
  }

  JList sublist(int start, [int end]) {
    if (end == null) end = _list.length;
    return new JList(_list.sublist(start, end), _root);
  }
}

JSONStorage jsonify(Map<String, String> storage) => new JSONStorage.fromStorage(storage);

class JSONStorage {

  Map<String, dynamic> _map;
  Map<String, String> _storage;

  JSONStorage.fromStorage(this._storage) {
    _map = new Map<String, dynamic>();
    _storage.forEach((k, v) => _map[k] = JSON.decode(v));
  }

  bool get isEmpty => _map.isEmpty;
  bool get isNotEmpty => !isEmpty;
  Iterable<String> get keys => _map.keys;
  int get length => _map.length;
  Iterable<dynamic> get values => _map.values;

  operator[](String key) => _wrap(_map[key], this);
  operator[]=(String key, dynamic value) {
    _map[key] = value;
    _storage[key] = JSON.encode(value);
  }

  void write() => _map.forEach((k, v) => _storage[k] = JSON.encode(v));

  void clear() {
    _map.clear();
    _storage.clear();
  }

  dynamic remove(String key) {
    _storage.remove(key);
    return _wrap(_map.remove(key), this);
  }

  dynamic noSuchMethod(Invocation i) {
    if (i.isGetter) return this[_getter(i.memberName)];
    if (i.isSetter) {
      this[_setter(i.memberName)] = i.positionalArguments.single;
      this.write();
    }
  }
}