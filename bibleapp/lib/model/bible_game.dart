class BibleGame {
  final int id;
  final int type;//1 = MC
  final int correctQuestionNum;//
  final int totalAnsweredNum;//
  final int level;//
  final String date;

  BibleGame({this.id, this.type, this.correctQuestionNum, this.totalAnsweredNum, this.level, this.date});

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'correctQuestionNum': correctQuestionNum,
      'totalAnsweredNum': totalAnsweredNum,
      'level': level,
      'date': date,
    };
  }

}