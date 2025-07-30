String bookTitle(String text, int maxLength, {String suffix = '...'}) {
  if (text.length <= maxLength) return text;

  // find last space before max character
  final truncated = text.substring(0, maxLength + 1); 
  final lastSpace = truncated.lastIndexOf(' ');

  if (lastSpace == -1) {
    return text.substring(0, maxLength) + suffix;
  }

  return text.substring(0, lastSpace).trimRight() + suffix;
}
