# 2048

Game ghép ô 2048 viết bằng Flutter, tách ra từ project Nexora.

## Chạy game

```bash
flutter pub get
flutter run
```

Hỗ trợ Android, iOS và Web. Giao diện có tiếng Việt và tiếng Anh (theo ngôn ngữ máy).

## Cấu trúc

```
lib/
  main.dart                 MaterialApp + localization
  core/                     Font, spacing, extension BuildContext
  l10n/                     Chuỗi dịch (app_en.arb, app_vi.arb) + file sinh tự động
  game/
    game_2048_page.dart     Màn hình game
    bloc/                   Game2048Bloc (trạng thái ván chơi, điểm, best)
    logic/                  Engine (di chuyển/ghép ô), local store, enums
    models/                 Ván chơi đã lưu
    sections/, views/       Các phần giao diện
assets/fonts/               Font ClearSans
test/game/                  Test cho engine và bloc
```

- Điểm cao nhất và ván đang chơi được lưu bằng `flutter_secure_storage`, nên mở lại app vẫn chơi tiếp được.
- Sửa chuỗi dịch trong `lib/l10n/*.arb` rồi chạy `flutter gen-l10n`.

## Kiểm tra

```bash
flutter analyze
flutter test
```
