import 'package:flutter/material.dart';
import '../../../models/lesson_plan.dart';

class ProcedureSection extends StatefulWidget {
  final LessonPlan lesson;

  const ProcedureSection({super.key, required this.lesson});

  @override
  State<ProcedureSection> createState() => _ProcedureSectionState();
}

class _ProcedureSectionState extends State<ProcedureSection> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'V. PROCEDURES (Teacher vs. Learner)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        if (!isMobile && widget.lesson.lessonType == 'detailed') _buildTableHeader(),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.lesson.procedures.length,
          itemBuilder: (context, index) {
            final step = widget.lesson.procedures[index];
            return isMobile
                ? _buildMobileStepCard(step)
                : (widget.lesson.lessonType == 'detailed' 
                    ? _buildDesktopStepRow(step)
                    : _buildSemiDetailedStepRow(step));
          },
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          SizedBox(width: 40, child: Text('Step', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Teacher Activity', style: TextStyle(fontWeight: FontWeight.bold))),
          VerticalDivider(),
          Expanded(child: Text('Learner\'s Response', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildDesktopStepRow(ProcedureStep step) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.all(8),
            child: Text(step.stepId, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.stepTitle, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
                  TextFormField(
                    initialValue: step.teacherActivity,
                    maxLines: null,
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter teacher activity...'),
                    onChanged: (val) => step.teacherActivity = val,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 1, height: 100, child: VerticalDivider()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: step.learnerResponse,
                maxLines: null,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter learner response...'),
                onChanged: (val) => step.learnerResponse = val,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemiDetailedStepRow(ProcedureStep step) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${step.stepId}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(step.stepTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: step.teacherActivity,
              maxLines: null,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter procedure details...'),
              onChanged: (val) => step.teacherActivity = val,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileStepCard(ProcedureStep step) {
    bool isDetailed = widget.lesson.lessonType == 'detailed';
    Color stepColor = _getStepColor(step.stepId);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: stepColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: stepColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: stepColor,
                  child: Text(step.stepId, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(step.stepTitle, style: TextStyle(fontWeight: FontWeight.bold, color: stepColor))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isDetailed ? 'TEACHER ACTIVITY' : 'PROCEDURE', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.blueGrey)),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: step.teacherActivity,
                  maxLines: null,
                  onChanged: (val) => step.teacherActivity = val,
                  decoration: InputDecoration(
                    hintText: isDetailed ? 'What will the teacher do?' : 'Enter procedure...',
                    fillColor: Colors.blue.withOpacity(0.02),
                  ),
                ),
                if (isDetailed) ...[
                  const SizedBox(height: 16),
                  const Text('LEARNER RESPONSE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.blueGrey)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: step.learnerResponse,
                    maxLines: null,
                    onChanged: (val) => step.learnerResponse = val,
                    decoration: InputDecoration(
                      hintText: 'What will the learners do?',
                      fillColor: Colors.green.withOpacity(0.02),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStepColor(String stepId) {
    switch (stepId) {
      case 'A': return Colors.blue;
      case 'B': return Colors.indigo;
      case 'C': return Colors.deepPurple;
      case 'D': return Colors.purple;
      case 'E': return Colors.pink;
      case 'F': return Colors.red;
      case 'G': return Colors.orange;
      case 'H': return Colors.amber;
      case 'I': return Colors.teal;
      case 'J': return Colors.green;
      default: return Colors.blueGrey;
    }
  }
}
