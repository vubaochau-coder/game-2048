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
    logic/                  Engine (di chuyển/ghép ô), AI tự chơi, local store, enums
    models/                 Ván chơi đã lưu
    sections/, views/       Các phần giao diện
assets/fonts/               Font ClearSans
test/game/                  Test cho engine và bloc
```

- **Chế độ tự chơi**: bấm nút "Tự chơi" để máy tự đi, bấm "Dừng" hoặc tự vuốt
  để lấy lại quyền điều khiển. AI (`lib/game/logic/game_2048_solver.dart`) dùng
  expectimax độ sâu 2 với bảng tra cứu tính sẵn cho mọi hàng 4 ô; trong mô phỏng
  nó đạt 2048 ở 10/10 ván, mất trung bình chưa tới 1ms mỗi nước.
- Điểm cao nhất và ván đang chơi được lưu bằng `flutter_secure_storage`, nên mở lại app vẫn chơi tiếp được.
- Sửa chuỗi dịch trong `lib/l10n/*.arb` rồi chạy `flutter gen-l10n`.

## Kiểm tra

```bash
flutter analyze
flutter test
```
