
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_care/main.dart';

void main() {
  testWidgets('CampusCare app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusCareApp());

    expect(find.text('CampusCare'), findsOneWidget);
  });
}
