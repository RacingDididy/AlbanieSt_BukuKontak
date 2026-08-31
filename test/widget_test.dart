import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daftarnama/main.dart';

void main() {
  testWidgets('Buku Kontak renders AppBar, Tabs, Drawer, and navigates correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Verifikasi AppBar dan TabBar
    expect(find.text('BUKU KONTAK'), findsWidgets);
    expect(find.text('Kontak'), findsWidgets);
    expect(find.text('Favorit'), findsWidgets);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // 2. Navigasi ke Halaman Tambah Kontak via FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verifikasi Halaman Tambah Kontak terbuka
    expect(find.text('Tambah Kontak'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Nama Lengkap'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'No Handphone'), findsOneWidget);

    // Isi formulir kontak baru
    await tester.enterText(
        find.widgetWithText(TextField, 'Nama Lengkap'), 'Budi Santoso');
    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'budi@gmail.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'No Handphone'), '081234567890');
    await tester.pump();

    // Tekan tombol Simpan
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
    await tester.pumpAndSettle();

    // Verifikasi kembali ke beranda dan kontak baru tampil
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('081234567890'), findsOneWidget);
  });
}
