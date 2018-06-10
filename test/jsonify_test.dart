import 'package:test/test.dart';

import 'package:jsonify/jsonify.dart';
import 'dart:convert';

void main() {
    Map<String, Object> testdata = {
      'a': "much more",
      'complicated': 'example',
      'twice': ["as", "complex"],
      'correct?': true
    };

    Map<String, String> storage = new Map<String, String>();

    test('List handling', () {
      storage.clear();
      JSONStorage jstorage = new JSONStorage.fromStorage(storage);
      jstorage['answer'] = [42, 56, 46, 76];
      jstorage['empty'] = [];

      expect(jstorage.keys.length, 2);
      expect(jstorage['answer'], [42, 56, 46, 76]);
      expect(jstorage['empty'], []);
    });

    test('Nested map handling', () {
      storage.clear();
      JSONStorage jstorage = new JSONStorage.fromStorage(storage);
      jstorage['nested'] = testdata;

      print(storage);

      expect(jstorage.keys.length, 1);
      expect(jstorage['notExisting'], null);
      expect(jstorage.notExisting, null);
      expect(jstorage['nested']['a'], "much more");
      expect(jstorage.nested.a, "much more");
      expect(jstorage['nested']['twice'], ["as", "complex"]);
      expect(jstorage.nested.twice, ["as", "complex"]);
      expect(jstorage['nested']['correct?'], true);
      expect(jstorage.nested['correct?'], true);
    });

    test('Remove handling', () {
      storage.clear();
      JSONStorage jstorage = new JSONStorage.fromStorage(storage);
      jstorage['nested'] = testdata;

      expect(jstorage.nested.length, 4);
      expect(jstorage.nested.remove('a'), 'much more');
      expect(jstorage.nested.length, 3);
      expect(jstorage.length, 1);
      expect(jstorage.remove('missing'), null);
      expect(jstorage.length, 1);
    });

    test('Clear handling', () {
      storage.clear();
      JSONStorage jstorage = new JSONStorage.fromStorage(storage);
      jstorage['nested'] = testdata;

      expect(jstorage.nested.isNotEmpty, true);
      jstorage.nested.clear();
      expect(jstorage.nested.isEmpty, true);
      expect(jstorage.isEmpty, false);
      expect(jstorage.length, 1);
      jstorage.clear();
      expect(jstorage.length, 0);
      expect(jstorage.isNotEmpty, false);
    });

    /*
    test('Put if absent', () {
      storage.clear();
      JSONStorage jstorage = new JSONStorage.fromStorage(storage);
      jstorage['nested'] = testdata;

      jstorage.putIfAbsent('missing', () => 42);
      expect(jstorage.missing, 42);
      jstorage.putIfAbsent('missing', () => 84);
      expect(jstorage.missing, 42);
    });
    */

    test('Setter and getter testing', () {
      storage.clear();
      JSONStorage jstorage = new JSONStorage.fromStorage(storage);

      jstorage['insert'] = { 'example': [42, 56, 86], 'such a': 'small' };
      expect(jstorage.insert.example.last, 86);
      expect(jstorage.insert.example.first, 42);
      expect(jstorage.insert['such a'], 'small');

      jstorage.insert = { 'such a': 'big', 'example': [{'a': 'b'}, 42, {'c': 'd'}] };
      expect(jstorage.insert.example is JList, true);
      expect(jstorage.insert.example.first is JMap, true);
      expect(jstorage.insert['example'].first is JMap, true);
      expect(jstorage.insert.example.last.c, 'd');
    });

    test('Backend testing', () {
      Map<String, String> backend = new Map<String, String>();
      JSONStorage jstorage = new JSONStorage.fromStorage(backend);
      jstorage.answer = 42;
      jstorage.list = [];
      jstorage.nested = { 'a': 'b', 'c': 3, 'd': ['a', 'b', 'c', 'd']};
      expect(backend['answer'], JSON.encode(42));
      expect(backend['list'], JSON.encode([]));
      expect(backend['nested'], JSON.encode({ 'a': 'b', 'c': 3, 'd': ['a', 'b', 'c', 'd']}));
      expect(JSON.decode(backend['nested'])['c'], 3);
      expect(jstorage.nested.c, 3);
      expect(JSON.decode(backend['nested'])['d'], ['a', 'b', 'c', 'd']);
      expect(jstorage.nested.d.last, 'd');
      expect(backend.length, 3);
    });
}