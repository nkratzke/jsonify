# jsonify

A library for Dart developers to lift up the [webstorage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API) to an (almost) full JSON client-side storage.

- `window.localstorage` and
- `window.sessionstorage`

have the restriction to store only Strings as keys and values.
So, if you have to store an highscore of 456431 points you have to
convert the integer into a string of "456431" and store it to webstorage.

    int highscore = 456431;
    window.localstorage['highscore'] = highscore.toString();

If you want to read this highscore later-on you have to convert it into an integer value again.

    int highscore = int.parse(window.localstorage['highscore']);

These into-from-to-string-conversions are cumbersome and error-prone.
It would be more convenient to do something like that:

    int score = 456431;
    storage.highscore = 456431;

    // Do something with the highscore.
    score = storage.highscore;

But this is not possible using webstorage.
If you want to store even more complex states it gets even trickier.
One option would be to use JSON.

    Map<String, Object> dayscore = {
        'name': 'Max Musterman',
        'score': 456431,
        'date': '2018-06-06'
    }
    List<Map> scores = JSON.decode(window.localstorage['scores']);
    scores.add(dayscore);
    window.localstorage['scores'] = JSON.encode(scores);

But now we have not even a string but a JSON-from-to-into-conversion.


That is where `jsonify` comes into play. It is merely more than a JSON wrapper
for `window.sessionstorage` and `window.localstorage` (and every other
`Map<String, String>`).

## Usage

A simple usage example of `jsonify` may look like that:

    import 'package:jsonify/jsonify.dart';

    main() {
      final jstorage = jsonify(window.localstorage);   // jsonify persistent storage
      final jsession = jsonify(window.sessionstorage); // jsonify session storage
    }

Doing that you can now use local/session-storage
as an (almost) full featured JSON store.

No we can store more complex data structures. Check the following example.

    jstorage['get'] = {
        'this': 'is',
        'a': [
            'more',
            'complex',
            'example',
            {
                'answer': 42,
                'question': null
                'usefulness': 'unknown'
            }
        ]
    };

And we can access this object and its parts like that:

    jstorage['get']['a'].last['answer'] == 42

If we have keys that are valid Dart identifiers, (and thanks to `noSuchMethod()`) we can even use the following getter/setter based-notation (which is often used by Ruby libraries):

    jstorage.get.a.last.answer == 42

It is possible to use the same notation to write into the webstorage:

    jstorage.is = { 'astonishing?': true };

However, if a key is not a valid Dart identifier (or a reserved Dart keyword), we must (and always can) fallback to the more classical Map notation

    jstorage.is['astonishing?']

That is basically all ... not less, not more. However, it might be helpful.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
