import 'dart:convert';

class ProcedureStep {
  final String stepId; // A, B, C... J
  final String stepTitle;
  String teacherActivity;
  String learnerResponse;

  ProcedureStep({
    required this.stepId,
    required this.stepTitle,
    this.teacherActivity = '',
    this.learnerResponse = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'stepId': stepId,
      'stepTitle': stepTitle,
      'teacherActivity': teacherActivity,
      'learnerResponse': learnerResponse,
    };
  }

  factory ProcedureStep.fromMap(Map<String, dynamic> map) {
    return ProcedureStep(
      stepId: map['stepId'] ?? '',
      stepTitle: map['stepTitle'] ?? '',
      teacherActivity: map['teacherActivity'] ?? '',
      learnerResponse: map['learnerResponse'] ?? '',
    );
  }
}

class LessonPlan {
  String? id;
  String userId;
  DateTime createdAt;
  DateTime updatedAt;

  // I. Header (Enhanced)
  String region;
  String department;
  String school;
  String teacherName;
  String subject;
  String gradeLevel;
  DateTime? date;
  String quarter;

  // Type: 'detailed' (script-style) or 'semi-detailed' (outline-style)
  String lessonType;

  // II. Objectives
  String contentStandard;
  String performanceStandard;
  String melc;

  // III. Paksang Aralin (Topic/Subject Matter)
  String topic;
  String references;
  String materials;
  String values;

  // IV. Procedures
  List<ProcedureStep> procedures;
  
  // V. Images/Visual Aids (Base64 list)
  List<String> images;

  // VI. Assessment
  String assessment;

  // VII. Remarks & Reflection
  String remarks;
  String reflectionWhatWorked;
  String reflectionNeedsImprovement;
  int learnersMastery;

  LessonPlan({
    this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.region = 'BANGSAMORO AUTONOMOUS REGION IN MUSLIM MINDANAO',
    this.department = 'DEPARTMENT OF EDUCATION',
    this.school = '',
    this.teacherName = '',
    this.subject = '',
    this.gradeLevel = '',
    this.date,
    this.quarter = '1',
    this.lessonType = 'detailed',
    this.contentStandard = '',
    this.performanceStandard = '',
    this.melc = '',
    this.topic = '',
    this.references = '',
    this.materials = '',
    this.values = '',
    List<ProcedureStep>? procedures,
    this.images = const [],
    this.assessment = '',
    this.remarks = '',
    this.reflectionWhatWorked = '',
    this.reflectionNeedsImprovement = '',
    this.learnersMastery = 0,
  }) : procedures = procedures ?? _defaultProcedures();

  static List<ProcedureStep> _defaultProcedures() {
    return [
      ProcedureStep(stepId: 'A', stepTitle: 'Reviewing previous lesson / Panimulang Gawain'),
      ProcedureStep(stepId: 'B', stepTitle: 'Establishing a purpose / Paghahabi ng Layunin'),
      ProcedureStep(stepId: 'C', stepTitle: 'Presenting examples / Paglalahad'),
      ProcedureStep(stepId: 'D', stepTitle: 'Discussion / Pagtatalakay'),
      ProcedureStep(stepId: 'E', stepTitle: 'Developing mastery / Paglilinang ng Kabihasaan'),
      ProcedureStep(stepId: 'F', stepTitle: 'Practical applications / Paglalapat'),
      ProcedureStep(stepId: 'G', stepTitle: 'Generalizations / Paglalahat'),
      ProcedureStep(stepId: 'H', stepTitle: 'Evaluating learning / Pagtataya'),
      ProcedureStep(stepId: 'I', stepTitle: 'Additional activities / Takdang Aralin'),
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'region': region,
      'department': department,
      'school': school,
      'teacherName': teacherName,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'date': date?.toIso8601String(),
      'quarter': quarter,
      'lessonType': lessonType,
      'contentStandard': contentStandard,
      'performanceStandard': performanceStandard,
      'melc': melc,
      'topic': topic,
      'references': references,
      'materials': materials,
      'values': values,
      'procedures': jsonEncode(procedures.map((e) => e.toMap()).toList()),
      'images': jsonEncode(images),
      'assessment': assessment,
      'remarks': remarks,
      'reflectionWhatWorked': reflectionWhatWorked,
      'reflectionNeedsImprovement': reflectionNeedsImprovement,
      'learnersMastery': learnersMastery,
    };
  }

  factory LessonPlan.fromMap(Map<String, dynamic> map) {
    var proceduresList = <ProcedureStep>[];
    if (map['procedures'] != null) {
      var decoded = jsonDecode(map['procedures']);
      proceduresList = (decoded as List).map((e) => ProcedureStep.fromMap(e)).toList();
    } else {
      proceduresList = _defaultProcedures();
    }

    var imagesList = <String>[];
    if (map['images'] != null) {
      imagesList = List<String>.from(jsonDecode(map['images']));
    }

    return LessonPlan(
      id: map['id']?.toString(),
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      region: map['region'] ?? '',
      department: map['department'] ?? '',
      school: map['school'] ?? '',
      teacherName: map['teacherName'] ?? '',
      subject: map['subject'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      quarter: map['quarter'] ?? '1',
      lessonType: map['lessonType'] ?? 'detailed',
      contentStandard: map['contentStandard'] ?? '',
      performanceStandard: map['performanceStandard'] ?? '',
      melc: map['melc'] ?? '',
      topic: map['topic'] ?? '',
      references: map['references'] ?? '',
      materials: map['materials'] ?? '',
      values: map['values'] ?? '',
      procedures: proceduresList,
      images: imagesList,
      assessment: map['assessment'] ?? '',
      remarks: map['remarks'] ?? '',
      reflectionWhatWorked: map['reflectionWhatWorked'] ?? '',
      reflectionNeedsImprovement: map['reflectionNeedsImprovement'] ?? '',
      learnersMastery: map['learnersMastery'] ?? 0,
    );
  }
}
