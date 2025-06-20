String bookPublishDate(String publishedDate) {
  bool isNotOnlyYear = publishedDate.contains('-');
  return isNotOnlyYear ? publishedDate.substring(0, 4) : publishedDate;
}
