import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru/widgets/paged_list.dart';

class _FakeSource extends PagedSource<int> {
  _FakeSource(this.total);

  final int total;

  @override
  Future<List<int>> load({required int offset, required int limit}) async {
    if (offset >= total) return const <int>[];
    final int end = (offset + limit).clamp(0, total);
    return List<int>.generate(end - offset, (int i) => offset + i);
  }
}

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('shows a spinner, then the first page', (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      PagedListView<int>(
        source: _FakeSource(75),
        pageStorageKey: "test",
        pageSize: 30,
        itemExtent: 50.0,
        itemBuilder: (BuildContext context, int item) => Text("Item $item"),
      ),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text("Item 0"), findsOneWidget);
    expect(find.text("Item 29"), findsNothing);
  });

  testWidgets('loads more when scrolled to the end', (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      PagedListView<int>(
        source: _FakeSource(75),
        pageStorageKey: "test",
        pageSize: 30,
        itemExtent: 50.0,
        itemBuilder: (BuildContext context, int item) => Text("Item $item"),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text("Item 74"),
      500.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text("Item 74"), findsOneWidget);
  });

  testWidgets('shows the empty message when there are no items',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      PagedListView<int>(
        source: _FakeSource(0),
        pageStorageKey: "test",
        itemExtent: 50.0,
        emptyMessage: "Nothing here.",
        itemBuilder: (BuildContext context, int item) => Text("Item $item"),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text("Nothing here."), findsOneWidget);
  });

  testWidgets('resetKey change reloads from the first page',
      (WidgetTester tester) async {
    final ValueNotifier<int> total = ValueNotifier<int>(75);
    final ValueNotifier<Object?> resetKey = ValueNotifier<Object?>(0);

    await tester.pumpWidget(_host(
      ValueListenableBuilder<Object?>(
        valueListenable: resetKey,
        builder: (BuildContext context, Object? key, Widget? child) {
          return ValueListenableBuilder<int>(
            valueListenable: total,
            builder: (BuildContext context, int value, Widget? child) {
              return PagedListView<int>(
                source: _FakeSource(value),
                pageStorageKey: "test",
                pageSize: 30,
                itemExtent: 50.0,
                resetKey: key,
                itemBuilder: (BuildContext context, int item) =>
                    Text("Item $item"),
              );
            },
          );
        },
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text("Item 0"), findsOneWidget);

    total.value = 3;
    resetKey.value = 1;
    await tester.pumpAndSettle();

    expect(find.text("Item 0"), findsOneWidget);
    expect(find.text("Item 3"), findsNothing);
  });

  testWidgets('reloadListenable refreshes the loaded window',
      (WidgetTester tester) async {
    final ValueNotifier<int> notifier = ValueNotifier<int>(0);

    await tester.pumpWidget(_host(
      PagedListView<int>(
        source: _FakeSource(10),
        pageStorageKey: "test",
        pageSize: 30,
        itemExtent: 50.0,
        reloadListenable: notifier,
        itemBuilder: (BuildContext context, int item) => Text("Item $item"),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    notifier.value = 1;
    await tester.pumpAndSettle();
    expect(find.text("Item 0"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
