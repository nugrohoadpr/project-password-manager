class NoteItem {
  final int id;
  final String title;
  final String content;
  final String firstLetter;

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
  }) : firstLetter = title.isNotEmpty ? title[0].toUpperCase() : '?';
}
