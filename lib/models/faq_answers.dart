import 'dart:convert';
import 'package:uuid/uuid.dart';

List<Answer> answersFromJson(String str) =>
    List<Answer>.from(json.decode(str).map((x) => Answer.fromJson(x)));

// String answersToJson(List<Answers> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Answer {
  String qstGuid;
  String ansGuid;
  String qstType;
  String qstText;
  bool qstCanPass;
  bool qstMultiAnswer;
  int awsVarLineNumber;
  String awsText;
  String awsComment;

  Answer({
    required this.qstGuid,
    required this.ansGuid,
    required this.qstType,
    required this.qstText,
    required this.qstCanPass,
    required this.qstMultiAnswer,
    required this.awsVarLineNumber,
    required this.awsText,
    required this.awsComment,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
    qstGuid: json["qstGuid"],
    ansGuid: Uuid().v4(),
    qstType: json["qstType"],
    qstText: json["qstText"],
    qstCanPass: json["qstCanPass"],
    qstMultiAnswer: json["qstMultiAnswer"],
    awsVarLineNumber: 0,
    awsText: '',
    awsComment: '',
  );

  // Map<String, dynamic> toJson() => {
  //   "qstGuid": qstGuid,
  //   "qstType": qstType,
  //   "qstText": qstText,
  //   "qstCanPass": qstCanPass,
  //   "qstMultiAnswer": qstMultiAnswer,
  //
  // };
}
