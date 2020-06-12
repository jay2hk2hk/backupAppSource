class BibleCrown {
  final int id;
  final int type;//1 = crown
  final String date;

  BibleCrown({this.id, this.type, this.date});

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'date': date,
    };
  }

}