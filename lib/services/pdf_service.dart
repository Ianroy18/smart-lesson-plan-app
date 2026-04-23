import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/lesson_plan.dart';

class PdfService {
  static Future<void> generateAndPrint(LessonPlan lesson) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(lesson),
            pw.SizedBox(height: 20),
            _buildSectionTitle('I. OBJECTIVES'),
            _buildObjectiveRow('Content Standards', lesson.contentStandard),
            _buildObjectiveRow('Performance Standards', lesson.performanceStandard),
            _buildObjectiveRow('Learning Competencies (MELC)', lesson.melc),
            pw.SizedBox(height: 10),
            _buildSectionTitle('II. CONTENT'),
            pw.Text(lesson.topic, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _buildSectionTitle('III. LEARNING RESOURCES'),
            _buildResourceRow('Teacher\'s Guide', lesson.teachersGuide),
            _buildResourceRow('Learner\'s Materials', lesson.learnersMaterials),
            _buildResourceRow('Other Materials', lesson.otherMaterials),
            pw.SizedBox(height: 10),
            _buildSectionTitle('IV. PROCEDURES'),
            _buildProcedureTable(lesson),
            pw.SizedBox(height: 10),
            _buildSectionTitle('V. REMARKS'),
            pw.Text(lesson.remarks),
            pw.SizedBox(height: 10),
            _buildSectionTitle('VI. REFLECTION'),
            pw.Text('What worked well: ${lesson.reflectionWhatWorked}'),
            pw.Text('Needs improvement: ${lesson.reflectionNeedsImprovement}'),
            pw.Text('Mastery count: ${lesson.learnersMastery}'),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'LessonPlan_${lesson.topic}.pdf',
    );
  }

  static pw.Widget _buildHeader(LessonPlan lesson) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(child: pw.Text('DETAILED LESSON PLAN (DLP)', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(child: _headerField('School', lesson.school)),
            pw.Expanded(child: _headerField('Grade Level', lesson.gradeLevel)),
          ],
        ),
        pw.Row(
          children: [
            pw.Expanded(child: _headerField('Teacher', lesson.teacherName)),
            pw.Expanded(child: _headerField('Learning Area', lesson.subject)),
          ],
        ),
        pw.Row(
          children: [
            pw.Expanded(child: _headerField('Date/Time', lesson.date != null ? DateFormat('yyyy-MM-dd').format(lesson.date!) : 'N/A')),
            pw.Expanded(child: _headerField('Quarter', lesson.quarter)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _headerField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: '$label: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      color: PdfColors.grey300,
      padding: const pw.EdgeInsets.all(4),
      margin: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _buildObjectiveRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text(value),
        ],
      ),
    );
  }

  static pw.Widget _buildResourceRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 100, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Expanded(child: pw.Text(value)),
      ],
    );
  }

  static pw.Widget _buildProcedureTable(LessonPlan lesson) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Steps', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Teacher Activity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Learner Activity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ],
        ),
        ...lesson.procedures.map((step) => pw.TableRow(
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(step.stepId)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(step.teacherActivity)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(step.learnerResponse)),
              ],
            )),
      ],
    );
  }
}
