// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'states.dart';

void main() {
  testWidgets('Empty ScrollGrid', (WidgetTester tester) async {
    await tester.pumpWidget(new ScrollGrid.count(
      crossAxisCount: 4,
      children: const <Widget>[],
    ));
  });

  testWidgets('ScrollGrid.count control test', (WidgetTester tester) async {
    List<String> log = <String>[];

    await tester.pumpWidget(new ScrollGrid.count(
      crossAxisCount: 4,
      children: kStates.map((String state) {
        return new GestureDetector(
          onTap: () {
            log.add(state);
          },
          child: new Container(
            decoration: const BoxDecoration(
              backgroundColor: const Color(0xFF0000FF),
            ),
            child: new Text(state),
          ),
        );
      }).toList(),
    ));

    expect(tester.getSize(find.text('Arkansas')), equals(const Size(200.0, 200.0)));

    for (int i = 0; i < 8; ++i) {
      await tester.tap(find.text(kStates[i]));
      expect(log, equals(<String>[kStates[i]]));
      log.clear();
    }

    expect(find.text(kStates[12]), findsNothing);
    expect(find.text('Nevada'), findsNothing);

    await tester.scroll(find.text('Arkansas'), const Offset(0.0, -200.0));
    await tester.pump();

    for (int i = 0; i < 4; ++i)
      expect(find.text(kStates[i]), findsNothing);

    for (int i = 4; i < 12; ++i) {
      await tester.tap(find.text(kStates[i]));
      expect(log, equals(<String>[kStates[i]]));
      log.clear();
    }

    await tester.scroll(find.text('Delaware'), const Offset(0.0, -4000.0));
    await tester.pump();

    expect(find.text('Alabama'), findsNothing);
    expect(find.text('Pennsylvania'), findsNothing);

    expect(tester.getCenter(find.text('Tennessee')),
        equals(const Point(300.0, 100.0)));

    await tester.tap(find.text('Tennessee'));
    expect(log, equals(<String>['Tennessee']));
    log.clear();

    await tester.scroll(find.text('Tennessee'), const Offset(0.0, 200.0));
    await tester.pump();

    await tester.tap(find.text('Tennessee'));
    expect(log, equals(<String>['Tennessee']));
    log.clear();

    await tester.tap(find.text('Pennsylvania'));
    expect(log, equals(<String>['Pennsylvania']));
    log.clear();
  });

  testWidgets('ScrollGrid.extent control test', (WidgetTester tester) async {
    List<String> log = <String>[];

    await tester.pumpWidget(new ScrollGrid.extent(
      maxCrossAxisExtent: 200.0,
      children: kStates.map((String state) {
        return new GestureDetector(
          onTap: () {
            log.add(state);
          },
          child: new Container(
            decoration: const BoxDecoration(
              backgroundColor: const Color(0xFF0000FF),
            ),
            child: new Text(state),
          ),
        );
      }).toList(),
    ));

    expect(tester.getSize(find.text('Arkansas')), equals(const Size(200.0, 200.0)));

    for (int i = 0; i < 8; ++i) {
      await tester.tap(find.text(kStates[i]));
      expect(log, equals(<String>[kStates[i]]));
      log.clear();
    }

    expect(find.text('Nevada'), findsNothing);

    await tester.scroll(find.text('Arkansas'), const Offset(0.0, -4000.0));
    await tester.pump();

    expect(find.text('Alabama'), findsNothing);

    expect(tester.getCenter(find.text('Tennessee')),
        equals(const Point(300.0, 100.0)));

    await tester.tap(find.text('Tennessee'));
    expect(log, equals(<String>['Tennessee']));
    log.clear();
  });

  testWidgets('ScrollGrid large scroll jump', (WidgetTester tester) async {
    List<int> log = <int>[];

    await tester.pumpWidget(
      new ScrollGrid.extent(
        scrollDirection: Axis.horizontal,
        maxCrossAxisExtent: 200.0,
        childAspectRatio: 0.75,
        children: new List<Widget>.generate(80, (int i) {
          return new Builder(
            builder: (BuildContext context) {
              log.add(i);
              return new Container(
                child: new Text('$i'),
              );
            }
          );
        }),
      ),
    );

    expect(tester.getSize(find.text('4')), equals(const Size(200.0 / 0.75, 200.0)));

    expect(log, equals(<int>[
      0, 1, 2, // col 0
      3, 4, 5, // col 1
      6, 7, 8, // col 2
    ]));
    log.clear();


    Scrollable2State state = tester.state(find.byType(Scrollable2));
    AbsoluteScrollPosition position = state.position;
    position.jumpTo(3025.0);

    expect(log, isEmpty);
    await tester.pump();

    expect(log, equals(<int>[
      33, 34, 35, // col 11
      36, 37, 38, // col 12
      39, 40, 41, // col 13
      42, 43, 44, // col 14
    ]));
    log.clear();

    position.jumpTo(975.0);

    expect(log, isEmpty);
    await tester.pump();

    expect(log, equals(<int>[
      9, 10, 11, // col 3
      12, 13, 14, // col 4
      15, 16, 17, // col 5
      18, 19, 20, // col 6
    ]));
    log.clear();
  });

  testWidgets('ScrollGrid - change crossAxisCount', (WidgetTester tester) async {
    List<int> log = <int>[];

    await tester.pumpWidget(
      new ScrollGrid(
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        children: new List<Widget>.generate(40, (int i) {
          return new Builder(
            builder: (BuildContext context) {
              log.add(i);
              return new Container(
                child: new Text('$i'),
              );
            }
          );
        }),
      ),
    );

    expect(tester.getSize(find.text('4')), equals(const Size(200.0, 200.0)));

    expect(log, equals(<int>[
      0, 1, 2, 3, // row 0
      4, 5, 6, 7, // row 1
      8, 9, 10, 11, // row 2
    ]));
    log.clear();

    await tester.pumpWidget(
      new ScrollGrid(
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        children: new List<Widget>.generate(40, (int i) {
          return new Builder(
            builder: (BuildContext context) {
              log.add(i);
              return new Container(
                child: new Text('$i'),
              );
            }
          );
        }),
      ),
    );

    expect(log, equals(<int>[
      0, 1, 2, 3, // row 0
      4, 5, 6, 7, // row 1
      8, 9, 10, 11, // row 2
    ]));
    log.clear();

    expect(tester.getSize(find.text('3')), equals(const Size(400.0, 400.0)));
    expect(find.text('4'), findsNothing);
  });

  testWidgets('ScrollGrid - change maxChildCrossAxisExtent', (WidgetTester tester) async {
    List<int> log = <int>[];

    await tester.pumpWidget(
      new ScrollGrid(
        gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.0,
        ),
        children: new List<Widget>.generate(40, (int i) {
          return new Builder(
            builder: (BuildContext context) {
              log.add(i);
              return new Container(
                child: new Text('$i'),
              );
            }
          );
        }),
      ),
    );

    expect(tester.getSize(find.text('4')), equals(const Size(200.0, 200.0)));

    expect(log, equals(<int>[
      0, 1, 2, 3, // row 0
      4, 5, 6, 7, // row 1
      8, 9, 10, 11, // row 2
    ]));
    log.clear();

    await tester.pumpWidget(
      new ScrollGrid(
        gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400.0,
        ),
        children: new List<Widget>.generate(40, (int i) {
          return new Builder(
            builder: (BuildContext context) {
              log.add(i);
              return new Container(
                child: new Text('$i'),
              );
            }
          );
        }),
      ),
    );

    expect(log, equals(<int>[
      0, 1, 2, 3, // row 0
      4, 5, 6, 7, // row 1
      8, 9, 10, 11, // row 2
    ]));
    log.clear();

    expect(tester.getSize(find.text('3')), equals(const Size(400.0, 400.0)));
    expect(find.text('4'), findsNothing);
  });
}
