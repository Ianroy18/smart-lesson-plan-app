import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/lesson_plan.dart';
import '../../providers/lesson_provider.dart';
import '../../services/pdf_service.dart';
import 'widgets/procedure_section.dart';

class LessonEditorScreen extends StatefulWidget {
  final LessonPlan? lesson;

  const LessonEditorScreen({super.key, this.lesson});

  @override
  State<LessonEditorScreen> createState() => _LessonEditorScreenState();
}

class _LessonEditorScreenState extends State<LessonEditorScreen> {
  late LessonPlan _currentLesson;
  int _currentStep = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.lesson != null) {
      _currentLesson = widget.lesson!;
    } else {
      _currentLesson = LessonPlan(
        userId: 'test_user_123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  void _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          if (file.bytes != null) {
            final base64String = base64Encode(file.bytes!);
            _currentLesson.images.add('data:image/png;base64,$base64String');
          }
        }
      });
    }
  }

  void _saveLesson() async {
    setState(() => _isSaving = true);
    final provider = context.read<LessonProvider>();
    if (widget.lesson == null) {
      await provider.addLesson(_currentLesson);
    } else {
      await provider.updateLesson(_currentLesson);
    }
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson plan saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson == null ? 'New Lesson Plan' : 'Edit Lesson Plan'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(LucideIcons.save),
              onPressed: _saveLesson,
            ),
          IconButton(
            icon: const Icon(LucideIcons.fileText),
            onPressed: () => PdfService.generateAndPrint(_currentLesson),
          ),
        ],
      ),
      body: Stepper(
        type: MediaQuery.of(context).size.width < 700 ? StepperType.vertical : StepperType.horizontal,
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < 5) {
            setState(() => _currentStep += 1);
          } else {
            _saveLesson();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 5 ? 'Finish & Save' : 'Next Section'),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Header'),
            label: const Icon(LucideIcons.layout),
            isActive: _currentStep >= 0,
            content: _buildHeaderSection(),
          ),
          Step(
            title: const Text('Objectives'),
            label: const Icon(LucideIcons.target),
            isActive: _currentStep >= 1,
            content: _buildObjectivesSection(),
          ),
          Step(
            title: const Text('Subject Matter'),
            label: const Icon(LucideIcons.bookOpen),
            isActive: _currentStep >= 2,
            content: _buildContentSection(),
          ),
          Step(
            title: const Text('Visual Aids'),
            label: const Icon(LucideIcons.image),
            isActive: _currentStep >= 3,
            content: _buildImageSection(),
          ),
          Step(
            title: const Text('Procedures'),
            label: const Icon(LucideIcons.listChecks),
            isActive: _currentStep >= 4,
            content: ProcedureSection(lesson: _currentLesson),
          ),
          Step(
            title: const Text('Assessment'),
            label: const Icon(LucideIcons.clipboardCheck),
            isActive: _currentStep >= 5,
            content: _buildAssessmentSection(),
          ),
          Step(
            title: const Text('Reflection'),
            label: const Icon(LucideIcons.messageSquare),
            isActive: _currentStep >= 6,
            content: _buildReflectionSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'detailed', label: Text('Detailed'), icon: Icon(LucideIcons.layers)),
            ButtonSegment(value: 'semi-detailed', label: Text('Semi-Detailed'), icon: Icon(LucideIcons.layoutList)),
          ],
          selected: {_currentLesson.lessonType},
          onSelectionChanged: (val) => setState(() => _currentLesson.lessonType = val.first),
        ),
        const SizedBox(height: 16),
        _buildTextField('Region', (val) => _currentLesson.region = val, initial: _currentLesson.region),
        _buildTextField('Department', (val) => _currentLesson.department = val, initial: _currentLesson.department),
        _buildTextField('School Name', (val) => _currentLesson.school = val, initial: _currentLesson.school),
        _buildTextField('Teacher Name', (val) => _currentLesson.teacherName = val, initial: _currentLesson.teacherName),
        Row(
          children: [
            Expanded(child: _buildTextField('Subject', (val) => _currentLesson.subject = val, initial: _currentLesson.subject)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Grade Level', (val) => _currentLesson.gradeLevel = val, initial: _currentLesson.gradeLevel)),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Date'),
                subtitle: Text(_currentLesson.date != null ? DateFormat('yyyy-MM-dd').format(_currentLesson.date!) : 'Select Date'),
                trailing: const Icon(LucideIcons.calendar),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _currentLesson.date ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _currentLesson.date = picked);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _currentLesson.quarter,
                decoration: const InputDecoration(labelText: 'Quarter'),
                items: ['1', '2', '3', '4'].map((q) => DropdownMenuItem(value: q, child: Text('Quarter $q'))).toList(),
                onChanged: (val) => setState(() => _currentLesson.quarter = val!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildObjectivesSection() {
    return Column(
      children: [
        _buildTextField('Content Standard', (val) => _currentLesson.contentStandard = val, initial: _currentLesson.contentStandard, maxLines: 3),
        _buildTextField('Performance Standard', (val) => _currentLesson.performanceStandard = val, initial: _currentLesson.performanceStandard, maxLines: 3),
        _buildTextField('MELC (Competency Code)', (val) => _currentLesson.melc = val, initial: _currentLesson.melc),
      ],
    );
  }

  Widget _buildContentSection() {
    return Column(
      children: [
        _buildTextField('Topic / Lesson Title', (val) => _currentLesson.topic = val, initial: _currentLesson.topic),
        const SizedBox(height: 16),
        const Text('Paksang Aralin (Subject Matter)', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildTextField('Sanggunian (References)', (val) => _currentLesson.references = val, initial: _currentLesson.references, maxLines: 2),
        _buildTextField('Kagamitan (Materials)', (val) => _currentLesson.materials = val, initial: _currentLesson.materials, maxLines: 2),
        _buildTextField('Pagpapahalaga (Values)', (val) => _currentLesson.values = val, initial: _currentLesson.values, maxLines: 2),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        const Text('Upload Visual Aids / Images', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_currentLesson.images.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _currentLesson.images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(_currentLesson.images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: IconButton(
                        icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                        onPressed: () => setState(() => _currentLesson.images.removeAt(index)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(LucideIcons.upload),
          label: const Text('Add Images'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        ),
      ],
    );
  }

  Widget _buildAssessmentSection() {
    return Column(
      children: [
        _buildTextField('Assessment / Evaluation Activities', (val) => _currentLesson.assessment = val, initial: _currentLesson.assessment, maxLines: 5),
        _buildTextField('Remarks', (val) => _currentLesson.remarks = val, initial: _currentLesson.remarks, maxLines: 3),
      ],
    );
  }

  Widget _buildReflectionSection() {
    return Column(
      children: [
        _buildTextField('What worked well?', (val) => _currentLesson.reflectionWhatWorked = val, initial: _currentLesson.reflectionWhatWorked, maxLines: 3),
        _buildTextField('What needs improvement?', (val) => _currentLesson.reflectionNeedsImprovement = val, initial: _currentLesson.reflectionNeedsImprovement, maxLines: 3),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Text('Number of learners who achieved mastery:')),
            SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: _currentLesson.learnersMastery.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) => _currentLesson.learnersMastery = int.tryParse(val) ?? 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, {String initial = '', int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initial,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
