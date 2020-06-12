class BibleNotes {
  final int id;
  final String title;
  final String content;
  final String date;

  BibleNotes({this.id, this.title, this.content, this.date});

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
    };
  }

}
