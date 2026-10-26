# PushService: prompt, keputusan, dan verifikasi

## Prompt yang diminta

Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.

## Output awal AI

Salinan persis draft awal ada di [ai-push-service-initial-ai-draft.txt](ai-push-service-initial-ai-draft.txt).

## Perbaikan manual pada project

- Mengganti `register` dan `onRegistered` lama dengan `getToken` dan `onTokenRefresh`.
- Menghubungkan `POST /devices` ke Dio API client project. Request mengirim `token` dan `platform`; interceptor menambahkan bearer token dari `TokenStore`.
- Tidak menyimpan atau mencetak token FCM maupun header/body autentikasi. Error registrasi hanya mencatat status HTTP atau kegagalan jaringan.
- Menampilkan notifikasi foreground secara manual di Android dan iOS. iOS foreground presentation otomatis tidak diaktifkan agar tidak muncul banner ganda.
- Membuat channel Android, menangani tap dari pesan saat app berjalan, background, dan terminated, serta membaca payload lokal saat notifikasi lokal membuka app.
- Menggunakan `GoRouter` yang diinjeksi dari Riverpod. `PushService` dan background handler tidak membaca atau menyimpan `BuildContext`.
- Menambahkan `subscribeToAnnouncements` dan `unsubscribeFromAnnouncements`.
- Menandai perilaku izin Android 13+ dan iOS pada kode, serta menambahkan deklarasi `POST_NOTIFICATIONS` dan `INTERNET` di Android manifest.

## Catatan konfigurasi

`lib/data/api_client.dart` saat ini memakai `https://example-campus-api.test`. Ganti `baseUrl` dengan alamat backend sebelum demo; route yang dipanggil adalah `POST /devices` dengan body JSON:

    {"token": "<FCM token>", "platform": "android|ios"}

Backend perlu menerima bentuk body tersebut dan autentikasi bearer yang dipasang interceptor. Jangan menaruh token nyata di README atau log.

## Checklist hasil

| Pemeriksaan | Hasil | Catatan |
|---|---|---|
| Flutter analyze | Lulus | `flutter analyze --no-pub`: No issues found. |
| Flutter test | Lulus | 4 tests passed, sesuai hasil terminal project. |
| Background handler top-level dan `@pragma('vm:entry-point')` | Lulus inspeksi kode | Fungsi hanya menginisialisasi Firebase; tidak mengakses UI/provider. |
| `getToken` dan `onTokenRefresh` mendaftarkan token ke backend | Lulus inspeksi kode | Keduanya memanggil Dio `POST /devices`; perlu backend aktif untuk membuktikan respons server. |
| Foreground memakai local notification manual | Lulus inspeksi kode | Android channel dan iOS presentation disiapkan; perlu perangkat untuk memastikan tampilan OS. |
| Tap saat app foreground | Belum diuji pada perangkat | Kirim pesan saat app terbuka, tap notifikasi lokal, pastikan `data.route` terbuka. |
| Tap saat app background | Belum diuji pada perangkat | Kirim pesan notification+data, tap banner, pastikan route benar. |
| Tap saat app terminated | Belum diuji pada perangkat | Akhiri app, kirim pesan, tap banner, pastikan route benar. |
| Android 13+ permission | Belum diuji pada perangkat | ADB server gagal start pada sesi ini; belum dapat cek dialog OS. |
| iOS permission/APNs | Belum dapat diuji | File `ios/Runner/GoogleService-Info.plist` tidak ditemukan; perlu konfigurasi Firebase/APNs dan perangkat fisik. |

Catatan: unit test lulus, tetapi belum menggantikan uji push nyata pada perangkat. Upaya cek perangkat dengan `adb devices` gagal karena ADB server tidak dapat dimulai.

## Cara menjalankan verifikasi perangkat

1. Isi URL backend yang benar pada `lib/data/api_client.dart` dan pastikan endpoint `POST /devices` tersedia.
2. Pastikan aplikasi terdaftar di Firebase dan konfigurasi native (`google-services.json` / `GoogleService-Info.plist`) cocok dengan bundle/application ID.
3. Di iOS, aktifkan Push Notifications capability dan unggah APNs key ke Firebase.
4. Kirim test FCM dengan data `route`, misalnya `/pengumuman/123`, untuk ketiga keadaan aplikasi pada tabel.
5. Catat hasil aktual pada kolom tabel sebelum demo.




Catatan versi: pubspec memakai firebase_messaging 17.0.1. Analyzer menandai getToken dan onTokenRefresh deprecated, tetapi kedua API masih tersedia; keduanya dipertahankan karena diwajibkan prompt.

