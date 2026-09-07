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

    // 1. Verifikasi AppBar, TabBar, dan Kontak Awal (termasuk Kategori dan null-aware operator ??)
    expect(find.text('BUKU KONTAK'), findsWidgets);
    expect(find.text('Kontak'), findsWidgets);
    expect(find.text('Favorit'), findsWidgets);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verifikasi kategori kontak awal: 'Teman' dan 'Tanpa kategori' (dari null safety)
    expect(find.text('Annisa Kusumastuti'), findsOneWidget);
    expect(find.text('Teman'), findsOneWidget);
    expect(find.text('Abror Abiyyi'), findsOneWidget);
    expect(find.text('Tanpa kategori'), findsOneWidget);

    // 2. Navigasi ke Halaman Tambah Kontak via FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verifikasi Halaman Tambah Kontak terbuka dengan input Kategori
    expect(find.text('Tambah Kontak'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Nama Lengkap'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'No Handphone'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Kategori (Opsional)'), findsOneWidget);

    // Isi formulir kontak baru dengan kategori 'Keluarga'
    await tester.enterText(
        find.widgetWithText(TextField, 'Nama Lengkap'), 'Budi Santoso');
    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'budi@gmail.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'No Handphone'), '089912345678');
    await tester.enterText(
        find.widgetWithText(TextField, 'Kategori (Opsional)'), 'Keluarga');
    await tester.pump();

    // Tekan tombol Simpan
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
    await tester.pumpAndSettle();

    // Verifikasi kembali ke beranda dan kontak baru tampil dengan kategorinya
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('089912345678'), findsOneWidget);
    expect(find.text('Keluarga'), findsOneWidget);

    // 3. Tambah Kontak kedua tanpa mengisi Kategori (dikosongkan untuk menguji null safety)
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Nama Lengkap'), 'Citra Dewi');
    await tester.enterText(
        find.widgetWithText(TextField, 'No Handphone'), '087711223344');
    // Kategori dibiarkan kosong
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
    await tester.pumpAndSettle();

    // Verifikasi Citra Dewi muncul dengan 'Tanpa kategori' (menggunakan operator ??)
    expect(find.text('Citra Dewi'), findsOneWidget);
    expect(find.text('087711223344'), findsOneWidget);
    expect(find.text('Tanpa kategori'), findsNWidgets(2));
  });
}
