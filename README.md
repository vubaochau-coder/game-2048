# 2048

[![CI](https://github.com/vubaochau-coder/game-2048/actions/workflows/ci.yml/badge.svg)](https://github.com/vubaochau-coder/game-2048/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.41.9-02569B?logo=flutter)
![State](https://img.shields.io/badge/state-flutter__bloc-blue)
![Platforms](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey)

Game ghép ô 2048 viết bằng Flutter, tách ra từ project Nexora.

## Tính năng

- Lối chơi 2048 cổ điển trên bàn 4×4: vuốt để trượt và ghép các ô cùng số.
- Điểm hiện tại và điểm cao nhất (best).
- **Lưu ván chơi**: thoát app rồi mở lại vẫn chơi tiếp được ván đang dở.
- Đạt 2048 có thể chọn **Tiếp tục** để chơi lên số lớn hơn, hoặc **Ván mới**.
- **Chế độ tự chơi**: AI expectimax tự đi nước, đạt 2048 ở 10/10 ván trong mô phỏng.
- Giao diện tiếng Việt và tiếng Anh (theo ngôn ngữ của máy).
- Chạy trên Android, iOS và Web.

## Cách chơi

| Thao tác | Kết quả |
| --- | --- |
| Vuốt lên/xuống/trái/phải | Mọi ô trượt theo hướng đó, hai ô cùng số chạm nhau thì ghép lại |
| Ghép hai ô | Cộng giá trị ô mới vào điểm |
| Nút **Tự chơi** | Máy tự đi; bấm **Dừng** hoặc tự vuốt để lấy lại quyền điều khiển |
| Nút **Ván mới** | Bắt đầu lại từ đầu |

Thắng khi tạo được ô 2048; thua khi bàn đầy và không còn nước đi.

## Chạy game

```bash
flutter pub get
flutter run
```

Phiên bản Flutter được ghim trong `.fvmrc`. Nếu dùng [FVM](https://fvm.app/):

```bash
fvm install
fvm flutter run
```

## Công nghệ

- [Flutter](https://flutter.dev/) + [flutter_bloc](https://pub.dev/packages/flutter_bloc) để quản lý trạng thái
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) để lưu điểm cao và ván đang chơi
- `flutter_localizations` + `intl` (file `.arb`) cho đa ngôn ngữ
- Font ClearSans

## Cấu trúc

```
lib/
  main.dart                 MaterialApp + localization
  core/                     Font, spacing, extension BuildContext
  l10n/                     Chuỗi dịch (app_en.arb, app_vi.arb) + file sinh tự động
  game/
    game_2048_page.dart     Màn hình game
    bloc/                   Game2048Bloc (trạng thái ván chơi, điểm, best)
    logic/                  Engine (di chuyển/ghép ô), AI tự chơi, local store, enums
    models/                 Ván chơi đã lưu
    sections/, views/       Các phần giao diện
assets/fonts/               Font ClearSans
test/game/                  Test cho engine, AI và bloc
```

## Ghi chú kỹ thuật

- **AI tự chơi** (`lib/game/logic/game_2048_solver.dart`): expectimax độ sâu 2
  với bảng tra cứu tính sẵn cho mọi hàng 4 ô; trong mô phỏng nó đạt 2048 ở
  10/10 ván, mất trung bình chưa tới 1ms mỗi nước. Khi tự chơi, mỗi nước cách nhau 250ms.
- Điểm cao nhất và ván đang chơi được lưu bằng `flutter_secure_storage`, nên mở lại app vẫn chơi tiếp được.
- Sửa chuỗi dịch trong `lib/l10n/*.arb` rồi chạy `flutter gen-l10n`.

## Kiểm tra

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Phát hành (Firebase App Distribution)

- Package Android: `com.chauvb.game2048`
- Dự án Firebase: `chess-app-chauvb` (dùng chung với app chess)
- Flutter: phiên bản ghim trong `.fvmrc` (cũng được ghim ở `pubspec.yaml`)

Hai workflow trong `.github/workflows/`:

- **CI** (`ci.yml`): kiểm tra format, `flutter analyze`, `flutter test` cho mỗi PR và mỗi lần push lên `main`.
- **Distribute** (`distribute.yml`): khi CI trên `main` xanh (hoặc chạy tay ở tab Actions), build APK release đã ký rồi đẩy lên Firebase App Distribution. Số build tự tăng theo số lần chạy workflow.

Cấu hình cần có trong *Settings → Secrets and variables → Actions*:

| Loại | Tên | Giá trị |
| --- | --- | --- |
| Secret | `FIREBASE_SERVICE_ACCOUNT_JSON` | Nội dung file JSON của service account có quyền *Firebase App Distribution Admin* |
| Secret | `ANDROID_KEYSTORE_BASE64` | File keystore mã hoá base64 (`base64 -w0 upload-keystore.jks`) |
| Secret | `ANDROID_KEYSTORE_PASSWORD` | Mật khẩu keystore |
| Secret | `ANDROID_KEY_ALIAS` | Alias của key |
| Secret | `ANDROID_KEY_PASSWORD` | Mật khẩu key |
| Variable | `FIREBASE_APP_ID` | App ID trên Firebase (dạng `1:540704428434:android:...`) |
| Variable | `FIREBASE_TESTER_GROUPS` và/hoặc `FIREBASE_TESTERS` | Alias nhóm tester / email tester, cách nhau bằng dấu phẩy |

Build và ký trên máy: tạo `android/key.properties` (không commit) với nội dung

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=upload-keystore.jks
```

và đặt file keystore ở `android/app/upload-keystore.jks`. Không có `key.properties` thì bản release được ký bằng debug key.
