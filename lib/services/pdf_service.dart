import 'dart:convert';
import 'dart:typed_data';
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
            _buildFullHeader(lesson),
            pw.SizedBox(height: 20),
            _buildSectionTitle('I. LAYUNIN'),
            _buildObjectiveRow('Content Standards', lesson.contentStandard),
            _buildObjectiveRow('Performance Standards', lesson.performanceStandard),
            _buildObjectiveRow('MELC', lesson.melc),
            pw.SizedBox(height: 10),
            _buildSectionTitle('II. PAKSANG ARALIN'),
            _buildInfoRow('Paksa', lesson.topic),
            _buildInfoRow('Sanggunian', lesson.references),
            _buildInfoRow('Kagamitan', lesson.materials),
            _buildInfoRow('Pagpapahalaga', lesson.values),
            pw.SizedBox(height: 10),
            _buildSectionTitle('III. PAMAMARAAN'),
            _buildProcedureTable(lesson),
            pw.SizedBox(height: 10),
            _buildSectionTitle('IV. PAGTATAYA'),
            pw.Text(lesson.assessment),
            pw.SizedBox(height: 10),
            _buildSectionTitle('V. TAKDANG ARALIN'),
            pw.Text(lesson.remarks), // Using remarks as takdang aralin for now
            if (lesson.images.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildSectionTitle('VISUAL AIDS / ATTACHMENTS'),
              pw.Wrap(
                spacing: 10,
                runSpacing: 10,
                children: lesson.images.map((img) {
                  final bytes = base64Decode(img.split(',').last);
                  return pw.Image(pw.MemoryImage(bytes), width: 200);
                }).toList(),
              ),
            ],
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text('Generated via Lesson Plan App | by kuya ian', style: pw.TextStyle(fontSize: 8)),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'LessonPlan_${lesson.topic}.pdf',
    );
  }

  static pw.Widget _buildFullHeader(LessonPlan lesson) {
    return pw.Column(
      children: [
        pw.Center(child: pw.Text('REPUBLIC OF THE PHILIPPINES', style: pw.TextStyle(fontSize: 10))),
        pw.Center(child: pw.Text(lesson.region.toUpperCase(), style: pw.TextStyle(fontSize: 10))),
        pw.Center(child: pw.Text(lesson.department.toUpperCase(), style: pw.TextStyle(fontSize: 10))),
        pw.Center(child: pw.Text(lesson.school.toUpperCase(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 15),
        pw.Center(
          child: pw.Text(
            '${lesson.lessonType == 'detailed' ? 'MASUSING' : 'SEMI-DETAILED'} BANGHAY ARALIN SA ${lesson.subject.toUpperCase()}-${lesson.gradeLevel.toUpperCase()}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Petsa: ${lesson.date != null ? DateFormat('MMMM dd, yyyy').format(lesson.date!) : '________'}'),
            pw.Text('Oras: ________'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
    );
  }

  static pw.Widget _buildObjectiveRow(String label, String value) {
    if (value.isEmpty) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 20, bottom: 2),
      child: pw.Text('$label: $value', style: pw.TextStyle(fontSize: 11)),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 20, bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 80, child: pw.Text('$label: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11))),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 11))),
        ],
      ),
    );
  }

  static pw.Widget _buildProcedureTable(LessonPlan lesson) {
    bool isDetailed = lesson.lessonType == 'detailed';
    
    if (!isDetailed) {
      return pw.Column(
        children: lesson.procedures.map((p) => pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20, bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${p.stepId}. ${p.stepTitle}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.Padding(padding: const pw.EdgeInsets.only(left: 10), child: pw.Text(p.teacherActivity, style: pw.TextStyle(fontSize: 11))),
            ],
          ),
        )).toList(),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Gawain ng Guro', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Gawain ng Mag-aaral', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
          ],
        ),
        ...lesson.procedures.map((p) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(p.stepTitle, style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
                  pw.Text(p.teacherActivity, style: pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(p.learnerResponse, style: pw.TextStyle(fontSize: 10)),
            ),
          ],
        )),
      ],
    );
  }
}
