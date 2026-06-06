import 'package:flutter_test/flutter_test.dart';
import 'package:conciencia/main.dart';

void main() {
  setUpAll(() async {
    await initializeAppLocale();
  });

  testWidgets('ConciencIA app arranca correctamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ConciencIAApp());
    expect(find.text('ConciencIA'), findsOneWidget);
    expect(find.text('Origen'), findsAtLeastNWidgets(1));
    expect(find.text('Destino'), findsAtLeastNWidgets(1));
    expect(find.text('Buscar rutas seguras'), findsOneWidget);
  });
}
