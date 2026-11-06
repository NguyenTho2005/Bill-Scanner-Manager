/// Utilities for normalizing Vietnamese text for local-only matching.
///
/// All processing happens on-device; no data leaves the app.
class VietnameseTextUtils {
  const VietnameseTextUtils._();

  /// Vietnamese lowercase letters with diacritics, in a fixed order.
  static const List<String> _from = [
    'à',
    'á',
    'ạ',
    'ả',
    'ã',
    'â',
    'ầ',
    'ấ',
    'ậ',
    'ẩ',
    'ẫ',
    'ă',
    'ằ',
    'ắ',
    'ặ',
    'ẳ',
    'ẵ',
    'è',
    'é',
    'ẹ',
    'ẻ',
    'ẽ',
    'ê',
    'ề',
    'ế',
    'ệ',
    'ể',
    'ễ',
    'ì',
    'í',
    'ị',
    'ỉ',
    'ĩ',
    'ò',
    'ó',
    'ọ',
    'ỏ',
    'õ',
    'ô',
    'ồ',
    'ố',
    'ộ',
    'ổ',
    'ỗ',
    'ơ',
    'ờ',
    'ớ',
    'ợ',
    'ở',
    'ỡ',
    'ù',
    'ú',
    'ụ',
    'ủ',
    'ũ',
    'ư',
    'ừ',
    'ứ',
    'ự',
    'ử',
    'ữ',
    'ỳ',
    'ý',
    'ỵ',
    'ỷ',
    'ỹ',
    'đ',
  ];

  /// ASCII base letters, parallel to [_from] entry-by-entry.
  static const List<String> _to = [
    'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', // â-group (11)
    'a', 'a', 'a', 'a', 'a', 'a', // ă-group (17 total)
    'e', 'e', 'e', 'e', 'e', // è-group (5)
    'e', 'e', 'e', 'e', 'e', 'e', // ê-group (11 total)
    'i', 'i', 'i', 'i', 'i', // 5
    'o', 'o', 'o', 'o', 'o', 'o', 'o', 'o', 'o', 'o', 'o', // ô-group (11)
    'o', 'o', 'o', 'o', 'o', 'o', // ơ-group (17 total)
    'u', 'u', 'u', 'u', 'u', // ù-group (5)
    'u', 'u', 'u', 'u', 'u', 'u', // ư-group (11 total)
    'y', 'y', 'y', 'y', 'y',
    'd',
  ];

  /// Character-level replacement table built from the parallel lists.
  static final Map<String, String> _diacriticsMap =
      Map.fromIterables(_from, _to);

  /// Collapses runs of whitespace into a single space and trims the result.
  static String squashWhitespace(String input) =>
      input.replaceAll(_whitespaceRegex, ' ').trim();

  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  /// Removes Vietnamese diacritics, lowercases and collapses whitespace.
  ///
  /// Useful for fuzzy text comparisons such as "WinMart+ Tháng 3" vs
  /// "winmart thang 3".
  static String normalize(String input) =>
      squashWhitespace(stripDiacritics(input.toLowerCase()));

  /// Removes Vietnamese diacritics character-by-character.
  ///
  /// Every character maps to exactly one character, so string length and
  /// offsets align with the original input.
  static String stripDiacritics(String input) {
    final buffer = StringBuffer();
    for (final codeUnit in input.codeUnits) {
      final ch = String.fromCharCode(codeUnit);
      buffer.write(_diacriticsMap[ch] ?? ch);
    }
    return buffer.toString();
  }

  /// Similarity between two strings, from 0.0 (different) to 1.0 (equal),
  /// based on normalized Levenshtein distance.
  static double similarity(String a, String b) {
    final na = normalize(a);
    final nb = normalize(b);
    if (na.isEmpty && nb.isEmpty) return 1;
    if (na.isEmpty || nb.isEmpty) return 0;
    if (na == nb) return 1;
    final distance = _levenshtein(na, nb);
    final longest = na.length > nb.length ? na.length : nb.length;
    return 1 - distance / longest;
  }

  /// Token-overlap similarity between 0.0 and 1.0. "highlands nguyen trai"
  /// vs "highlands coffee nguyen trai" scores high because every token of
  /// the shorter string appears in the longer one.
  static double tokenOverlapSimilarity(String a, String b) {
    final tokensA = normalize(a).split(' ')..removeWhere((t) => t.isEmpty);
    final tokensB = normalize(b).split(' ')..removeWhere((t) => t.isEmpty);
    if (tokensA.isEmpty && tokensB.isEmpty) return 1;
    if (tokensA.isEmpty || tokensB.isEmpty) return 0;

    final shortTokens = tokensA.length <= tokensB.length ? tokensA : tokensB;
    final longTokens = identical(shortTokens, tokensA) ? tokensB : tokensA;

    var matched = 0;
    final remaining = List<String>.from(longTokens);
    for (final token in shortTokens) {
      if (remaining.remove(token)) matched++;
    }
    return matched / shortTokens.length;
  }

  static int _levenshtein(String a, String b) {
    final aLen = a.length;
    final bLen = b.length;
    var previous = List<int>.generate(bLen + 1, (i) => i);
    var current = List<int>.filled(bLen + 1, 0);

    for (var i = 1; i <= aLen; i++) {
      current[0] = i;
      for (var j = 1; j <= bLen; j++) {
        final substitutionCost = a[i - 1] == b[j - 1] ? 0 : 1;
        current[j] = _minOf(
          previous[j - 1] + substitutionCost,
          previous[j] + 1,
          current[j - 1] + 1,
        );
      }
      final swap = previous;
      previous = current;
      current = swap;
    }
    return previous[bLen];
  }

  static int _minOf(int a, int b, int c) =>
      a < b ? (a < c ? a : c) : (b < c ? b : c);
}
