String sanitizeDescription(String raw) {
  if (raw == "No Description") return raw;

  String clean = raw
      .replaceAll(
        RegExp(r'</?(?:p|br|div|h[1-6]|li|ul|ol|blockquote|section)[^>]*>'),
        '\n',
      )
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ')
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();

  return clean.isEmpty ? "No Description" : clean;
}
