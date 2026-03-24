import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_game/ninja_frog_app.dart';

void main() {
  testWidgets('launcher exposes the upgraded app flow', (tester) async {
    await tester.pumpWidget(const NinjaFrogApp());

    expect(find.text('NINJA FROG'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('STAGES'), findsOneWidget);
    expect(find.text('CONTROLS'), findsNothing);

    await tester.tap(find.text('STAGES'));
    await tester.pumpAndSettle();

    expect(find.text('STAGES'), findsWidgets);
    expect(find.textContaining('CANOPY RUN'), findsOneWidget);
    expect(find.textContaining('RUINS RELAY'), findsOneWidget);
  });
}
