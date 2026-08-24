import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daftarnama/main.dart';

void main() {
  testWidgets('Buku Kontak loads and can add new contact', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Buku Kontak'), findsOneWidget);
    expect(find.text('Ahmad Fauzi'), findsOneWidget);

    // Enter new contact details
    await tester.enterText(find.widgetWithText(TextField, 'Nama Lengkap *'), 'Dewi Lestari');
    await tester.enterText(find.widgetWithText(TextField, 'No Handphone / WhatsApp *'), '081233445566');
    await tester.enterText(find.widgetWithText(TextField, 'Kategori / Jabatan (cth: Teman, Guru, OSIS)'), 'Sekretaris OSIS');
    await tester.pump();

    // Tap save button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Kontak'));
    await tester.pumpAndSettle();

    // Verify new contact is added
    expect(find.text('Dewi Lestari'), findsOneWidget);
    expect(find.text('081233445566'), findsOneWidget);
    expect(find.text('Sekretaris OSIS'), findsOneWidget);
  });
}
