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

    // Verifikasi inisial nama kontak awal di CircleAvatar ('A' untuk Annisa dan Abror)
    expect(find.descendant(of: find.byType(CircleAvatar), matching: find.text('A')), findsNWidgets(2));

    // 2. Navigasi ke Halaman Tambah Kontak via FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verifikasi Halaman Tambah Kontak terbuka dengan widget Form dan input TextFormField
    expect(find.text('Tambah Kontak'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Nama Lengkap'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'No Handphone'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Kategori (Opsional)'), findsOneWidget);

    // Tes Validasi Form: Tekan Simpan saat form masih kosong
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
    await tester.pumpAndSettle();

    // Verifikasi pesan error validasi muncul
    expect(find.text('Nama wajib diisi'), findsOneWidget);
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('No Handphone wajib diisi'), findsOneWidget);

    // Tes Validasi Email dan No HP
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Lengkap'), 'Budi Santoso');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'email_tanpa_at');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'No Handphone'), '12345');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Email harus mengandung karakter @'), findsOneWidget);
    expect(find.text('No Handphone minimal 10 digit'), findsOneWidget);

    // Isi formulir kontak baru dengan data yang valid
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'budi@gmail.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'No Handphone'), '089912345678');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Kategori (Opsional)'), 'Keluarga');
    await tester.pump();

    // Tekan tombol Simpan
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
    await tester.pumpAndSettle();

    // Verifikasi kembali ke beranda dan kontak baru tampil dengan kategorinya
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('089912345678'), findsOneWidget);
    expect(find.text('Keluarga'), findsOneWidget);
    expect(find.descendant(of: find.byType(CircleAvatar), matching: find.text('B')), findsOneWidget);

    // 3. Tambah Kontak kedua tanpa mengisi Kategori (dikosongkan untuk menguji null safety)
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Lengkap'), 'Citra Dewi');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'citra@gmail.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'No Handphone'), '087711223344');
    // Kategori dibiarkan kosong
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
    await tester.pumpAndSettle();

    // Verifikasi Citra Dewi muncul dengan 'Tanpa kategori' (menggunakan operator ??)
    expect(find.text('Citra Dewi'), findsOneWidget);
    expect(find.text('087711223344'), findsOneWidget);
    expect(find.text('Tanpa kategori'), findsNWidgets(2));
    expect(find.descendant(of: find.byType(CircleAvatar), matching: find.text('C')), findsOneWidget);

    // 4. Pengujian Pencarian Real-time dengan Stream (Tugas 6)
    final searchFinder = find.widgetWithText(TextField, 'Cari nama atau kategori kontak...');
    expect(searchFinder, findsOneWidget);

    // Tes Cari berdasarkan Nama ('Abror')
    await tester.enterText(searchFinder, 'Abror');
    await tester.pumpAndSettle();
    expect(find.text('Abror Abiyyi'), findsOneWidget);
    expect(find.text('Annisa Kusumastuti'), findsNothing);
    expect(find.text('Budi Santoso'), findsNothing);

    // Tes Cari berdasarkan Kategori ('Keluarga')
    await tester.enterText(searchFinder, 'keluarga');
    await tester.pumpAndSettle();
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Abror Abiyyi'), findsNothing);

    // Tes Cari kata kunci yang tidak ada ('xyz999')
    await tester.enterText(searchFinder, 'xyz999');
    await tester.pumpAndSettle();
    expect(find.text('Kontak tidak ditemukan'), findsOneWidget);

    // Reset pencarian (kosongkan)
    await tester.enterText(searchFinder, '');
    await tester.pumpAndSettle();
    expect(find.text('Annisa Kusumastuti'), findsOneWidget);
    expect(find.text('Abror Abiyyi'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
  });
}
