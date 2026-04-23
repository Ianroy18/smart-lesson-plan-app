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

  // I. Header
  String school;
  String teacherName;
  String subject;
  String gradeLevel;
  DateTime? date;
  String quarter;

  // II. Objectives
  String contentStandard;
  String performanceStandard;
  String melc; // Most Essential Learning Competency

  // III. Content
  String topic;

  // IV. Learning Resources
  String teachersGuide;
  String learnersMaterials;
  String otherMaterials;

  // V. Procedures
  List<ProcedureStep> procedures;

  // VI. Assessment
  String assessment;

  // VII. Remarks
  String remarks;

  // VII. Reflection
  String reflectionWhatWorked;
  String reflectionNeedsImprovement;
  int learnersMastery;

  LessonPlan({
    this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.school = '',
    this.teacherName = '',
    this.subject = '',
    this.gradeLevel = '',
    this.date,
    this.quarter = '1',
    this.contentStandard = '',
    this.performanceStandard = '',
    this.melc = '',
    this.topic = '',
    this.teachersGuide = '',
    this.learnersMaterials = '',
    this.otherMaterials = '',
    List<ProcedureStep>? procedures,
    this.assessment = '',
    this.remarks = '',
    this.reflectionWhatWorked = '',
    this.reflectionNeedsImprovement = '',
    this.learnersMastery = 0,
  }) : procedures = procedures ?? _defaultProcedures();

  static List<ProcedureStep> _defaultProcedures() {
    return [
      ProcedureStep(stepId: 'A', stepTitle: 'Reviewing previous lesson or presenting the new lesson'),
      ProcedureStep(stepId: 'B', stepTitle: 'Establishing a purpose for the lesson'),
      ProcedureStep(stepId: 'C', stepTitle: 'Presenting examples/instances of the new lesson'),
      ProcedureStep(stepId: 'D', stepTitle: 'Discussing new concepts and practicing new skills #1'),
      ProcedureStep(stepId: 'E', stepTitle: 'Discussing new concepts and practicing new skills #2'),
      ProcedureStep(stepId: 'F', stepTitle: 'Developing mastery (Leads to Formative Assessment 3)'),
      ProcedureStep(stepId: 'G', stepTitle: 'Finding practical applications of concepts and skills in daily living'),
      ProcedureStep(stepId: 'H', stepTitle: 'Making generalizations and abstractions about the lesson'),
      ProcedureStep(stepId: 'I', stepTitle: 'Evaluating learning'),
      ProcedureStep(stepId: 'J', stepTitle: 'Additional activities for application or remediation'),
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'school': school,
      'teacherName': teacherName,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'date': date?.toIso8601String(),
      'quarter': quarter,
      'contentStandard': contentStandard,
      'performanceStandard': performanceStandard,
      'melc': melc,
      'topic': topic,
      'teachersGuide': teachersGuide,
      'learnersMaterials': learnersMaterials,
      'otherMaterials': otherMaterials,
      'procedures': jsonEncode(procedures.map((e) => e.toMap()).toList()),
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

    return LessonPlan(
      id: map['id']?.toString(),
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      school: map['school'] ?? '',
      teacherName: map['teacherName'] ?? '',
      subject: map['subject'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      quarter: map['quarter'] ?? '1',
      contentStandard: map['contentStandard'] ?? '',
      performanceStandard: map['performanceStandard'] ?? '',
      melc: map['melc'] ?? '',
      topic: map['topic'] ?? '',
      teachersGuide: map['teachersGuide'] ?? '',
      learnersMaterials: map['learnersMaterials'] ?? '',
      otherMaterials: map['otherMaterials'] ?? '',
      procedures: proceduresList,
      assessment: map['assessment'] ?? '',
      remarks: map['remarks'] ?? '',
      reflectionWhatWorked: map['reflectionWhatWorked'] ?? '',
      reflectionNeedsImprovement: map['reflectionNeedsImprovement'] ?? '',
      learnersMastery: map['learnersMastery'] ?? 0,
    );
  }
}
