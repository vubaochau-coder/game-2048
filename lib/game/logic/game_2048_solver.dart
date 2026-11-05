import 'dart:math';

import 'game_2048_enums.dart';

/// AI chọn nước đi cho chế độ tự chơi, dùng thuật toán expectimax:
/// - Nút "max": máy chọn hướng đi tốt nhất.
/// - Nút "chance": ô mới xuất hiện ngẫu nhiên (2 với xác suất 90%, 4 với 10%).
///
/// Bàn cờ được biểu diễn bằng 4 hàng, mỗi hàng là số 16 bit gồm 4 "rank"
/// (rank = log2 của giá trị ô, 0 = ô trống). Cách này cho phép tra bảng tính
/// sẵn cho mọi hàng (65536 hàng) và chỉ dùng số nguyên ≤ 32 bit nên chạy đúng
/// cả trên web.
///
/// Hàm đánh giá dựa trên heuristic phổ biến cho 2048: thưởng ô trống và các
/// cặp ô có thể ghép, phạt hàng/cột không đơn điệu và tổng giá trị ô lớn
/// nằm rải rác.
class Game2048Solver {
  /// Số tầng chance tối đa được tìm (độ sâu thực tế còn phụ thuộc bàn cờ).
  final int maxDepth;

  Game2048Solver({this.maxDepth = 2});

  static const _probabilityCutoff = 0.0001;
  static const _maxRank = 15;

  static final _Tables _tables = _Tables();

  late int _depthLimit;
  final Map<(int, int), _CacheEntry> _cache = {};

  /// Trả về hướng đi tốt nhất, hoặc `null` nếu không còn nước đi.
  Game2048Direction? bestMove(List<int> board) {
    final rows = _encode(board);
    _depthLimit = _depthFor(rows);
    _cache.clear();

    Game2048Direction? best;
    double bestScore = -1;
    for (final direction in Game2048Direction.values) {
      final moved = _move(rows, direction);
      if (_sameBoard(moved, rows)) continue;

      final score = _scoreChance(moved, 0, 1.0);
      if (score > bestScore) {
        bestScore = score;
        best = direction;
      }
    }
    return best;
  }

  /// Tìm sâu hơn khi bàn cờ nhiều loại ô (giai đoạn khó), nông hơn khi còn
  /// đơn giản để giữ tốc độ.
  int _depthFor(List<int> rows) {
    final distinct = <int>{};
    for (final row in rows) {
      for (int i = 0; i < 4; i++) {
        final rank = (row >> (4 * i)) & 0xF;
        if (rank != 0) distinct.add(rank);
      }
    }
    return (distinct.length - 2).clamp(1, maxDepth);
  }

  double _scoreChance(List<int> rows, int depth, double probability) {
    if (probability < _probabilityCutoff || depth >= _depthLimit) {
      return _heuristic(rows);
    }

    final key = (rows[0] | (rows[1] << 16), rows[2] | (rows[3] << 16));
    final cached = _cache[key];
    if (cached != null && cached.depth <= depth) return cached.score;

    int empty = 0;
    for (final row in rows) {
      for (int i = 0; i < 4; i++) {
        if ((row >> (4 * i)) & 0xF == 0) empty++;
      }
    }
    if (empty == 0) return _heuristic(rows);

    final childProbability = probability / empty;
    double total = 0;
    for (int r = 0; r < 4; r++) {
      for (int i = 0; i < 4; i++) {
        final shift = 4 * i;
        if ((rows[r] >> shift) & 0xF != 0) continue;

        final original = rows[r];
        rows[r] = original | (1 << shift); // ô 2
        total += _scoreMax(rows, depth, childProbability * 0.9) * 0.9;
        rows[r] = original | (2 << shift); // ô 4
        total += _scoreMax(rows, depth, childProbability * 0.1) * 0.1;
        rows[r] = original;
      }
    }
    final score = total / empty;
    _cache[key] = _CacheEntry(depth, score);
    return score;
  }

  double _scoreMax(List<int> rows, int depth, double probability) {
    double best = 0;
    for (final direction in Game2048Direction.values) {
      final moved = _move(rows, direction);
      if (_sameBoard(moved, rows)) continue;
      best = max(best, _scoreChance(moved, depth + 1, probability));
    }
    return best;
  }

  double _heuristic(List<int> rows) {
    final heur = _tables.heuristic;
    final cols = _transpose(rows);
    return heur[rows[0]] +
        heur[rows[1]] +
        heur[rows[2]] +
        heur[rows[3]] +
        heur[cols[0]] +
        heur[cols[1]] +
        heur[cols[2]] +
        heur[cols[3]];
  }

  // --- Biểu diễn bàn cờ ---

  static List<int> _encode(List<int> board) {
    final rows = List<int>.filled(4, 0);
    for (int r = 0; r < 4; r++) {
      int row = 0;
      for (int c = 0; c < 4; c++) {
        final value = board[r * 4 + c];
        final rank = value == 0 ? 0 : _log2(value).clamp(1, _maxRank);
        row |= rank << (4 * c);
      }
      rows[r] = row;
    }
    return rows;
  }

  static int _log2(int value) {
    int rank = 0;
    while (value > 1) {
      value >>= 1;
      rank++;
    }
    return rank;
  }

  static List<int> _move(List<int> rows, Game2048Direction direction) {
    final left = _tables.moveLeft;
    final right = _tables.moveRight;
    switch (direction) {
      case Game2048Direction.left:
        return [left[rows[0]], left[rows[1]], left[rows[2]], left[rows[3]]];
      case Game2048Direction.right:
        return [right[rows[0]], right[rows[1]], right[rows[2]], right[rows[3]]];
      case Game2048Direction.up:
        final cols = _transpose(rows);
        return _transpose([
          left[cols[0]],
          left[cols[1]],
          left[cols[2]],
          left[cols[3]],
        ]);
      case Game2048Direction.down:
        final cols = _transpose(rows);
        return _transpose([
          right[cols[0]],
          right[cols[1]],
          right[cols[2]],
          right[cols[3]],
        ]);
    }
  }

  /// Hàng i của kết quả = cột i của đầu vào.
  static List<int> _transpose(List<int> rows) {
    final result = List<int>.filled(4, 0);
    for (int c = 0; c < 4; c++) {
      final shift = 4 * c;
      result[c] =
          ((rows[0] >> shift) & 0xF) |
          (((rows[1] >> shift) & 0xF) << 4) |
          (((rows[2] >> shift) & 0xF) << 8) |
          (((rows[3] >> shift) & 0xF) << 12);
    }
    return result;
  }

  static bool _sameBoard(List<int> a, List<int> b) {
    return a[0] == b[0] && a[1] == b[1] && a[2] == b[2] && a[3] == b[3];
  }
}

class _CacheEntry {
  final int depth;
  final double score;

  const _CacheEntry(this.depth, this.score);
}

/// Bảng tính sẵn cho mọi hàng 16 bit: kết quả trượt trái/phải và điểm
/// heuristic. Tạo một lần (lazy) khi solver được dùng lần đầu.
class _Tables {
  final List<int> moveLeft = List<int>.filled(65536, 0);
  final List<int> moveRight = List<int>.filled(65536, 0);
  final List<double> heuristic = List<double>.filled(65536, 0);

  static const _lostPenalty = 200000.0;
  static const _monotonicityPower = 4.0;
  static const _monotonicityWeight = 47.0;
  static const _sumPower = 3.5;
  static const _sumWeight = 11.0;
  static const _mergesWeight = 700.0;
  static const _emptyWeight = 270.0;

  _Tables() {
    final line = List<int>.filled(4, 0);
    for (int row = 0; row < 65536; row++) {
      for (int i = 0; i < 4; i++) {
        line[i] = (row >> (4 * i)) & 0xF;
      }
      heuristic[row] = _heuristic(line);

      final slid = _slideLeft(line);
      final result = _pack(slid);
      moveLeft[row] = result;
      moveRight[_reverse(row)] = _reverse(result);
    }
  }

  static double _heuristic(List<int> line) {
    double sum = 0;
    int empty = 0;
    int merges = 0;
    int previous = 0;
    int counter = 0;
    for (final rank in line) {
      sum += pow(rank, _sumPower);
      if (rank == 0) {
        empty++;
      } else {
        if (previous == rank) {
          counter++;
        } else if (counter > 0) {
          merges += 1 + counter;
          counter = 0;
        }
        previous = rank;
      }
    }
    if (counter > 0) merges += 1 + counter;

    double monotonicityLeft = 0;
    double monotonicityRight = 0;
    for (int i = 1; i < 4; i++) {
      final a = pow(line[i - 1], _monotonicityPower);
      final b = pow(line[i], _monotonicityPower);
      if (line[i - 1] > line[i]) {
        monotonicityLeft += a - b;
      } else {
        monotonicityRight += b - a;
      }
    }

    return _lostPenalty +
        _emptyWeight * empty +
        _mergesWeight * merges -
        _monotonicityWeight * min(monotonicityLeft, monotonicityRight) -
        _sumWeight * sum;
  }

  /// Trượt và ghép một hàng sang trái (theo rank). Hai ô rank 15 không ghép
  /// để không tràn 4 bit.
  static List<int> _slideLeft(List<int> line) {
    final tiles = line.where((r) => r != 0).toList();
    final result = <int>[];
    int i = 0;
    while (i < tiles.length) {
      if (i + 1 < tiles.length && tiles[i] == tiles[i + 1] && tiles[i] < 15) {
        result.add(tiles[i] + 1);
        i += 2;
      } else {
        result.add(tiles[i]);
        i++;
      }
    }
    while (result.length < 4) {
      result.add(0);
    }
    return result;
  }

  static int _pack(List<int> line) {
    return line[0] | (line[1] << 4) | (line[2] << 8) | (line[3] << 12);
  }

  static int _reverse(int row) {
    return ((row & 0xF) << 12) |
        (((row >> 4) & 0xF) << 8) |
        (((row >> 8) & 0xF) << 4) |
        ((row >> 12) & 0xF);
  }
}
