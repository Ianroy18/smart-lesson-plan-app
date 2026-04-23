import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../providers/lesson_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  bool _isEditing = false;
  String _email = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('teacher_name') ?? 'Juan Dela Cruz';
      _schoolController.text = prefs.getString('school_name') ?? 'Not specified';
      _email = prefs.getString('user_email') ?? 'teacher@deped.gov.ph';
    });
  }

  void _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teacher_name', _nameController.text);
    await prefs.setString('school_name', _schoolController.text);
    
    setState(() => _isEditing = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonCount = context.watch<LessonProvider>().lessons.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Teacher Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? LucideIcons.check : LucideIcons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildStatCards(lessonCount),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 40, top: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(LucideIcons.user, size: 50, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 16),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                ),
              ),
            )
          else
            Text(
              _nameController.text,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          Text(
            _email,
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(int count) {
    return Row(
      children: [
        Expanded(
          child: _statCard('Lesson Plans', count.toString(), LucideIcons.fileText, Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard('Account Type', 'Teacher', LucideIcons.shieldCheck, Colors.green),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Professional Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_isEditing)
          TextField(
            controller: _schoolController,
            decoration: const InputDecoration(labelText: 'School Name', prefixIcon: Icon(LucideIcons.school)),
          )
        else
          _infoTile(LucideIcons.school, 'School Name', _schoolController.text),
        _infoTile(LucideIcons.graduationCap, 'Position', 'Teacher I / II / III'),
        _infoTile(LucideIcons.mapPin, 'Division', 'DepEd Regional Office'),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(LucideIcons.chevronRight, size: 16),
    );
  }
}
