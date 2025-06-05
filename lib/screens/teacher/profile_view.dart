import 'dart:io';
import 'package:flutter/material.dart';
import '../../database/models.dart';
import '../../database/teacher_table.dart';

class TeacherProfileView extends StatefulWidget {
  final int userId;
  final VoidCallback? onLogout;

  const TeacherProfileView({Key? key, required this.userId, this.onLogout})
    : super(key: key);

  @override
  State<TeacherProfileView> createState() => _TeacherProfileViewState();
}

class _TeacherProfileViewState extends State<TeacherProfileView> {
  final TeacherDBHelper _dbHelper = TeacherDBHelper();
  Teacher? _teacher;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeacher();
  }

  Future<void> _loadTeacher() async {
    setState(() => _isLoading = true);
    try {
      final teacher = await _dbHelper.getTeacherByUserId(widget.userId);
      setState(() {
        _teacher = teacher;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tải thông tin giáo viên: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không thể tải thông tin giáo viên')),
      );
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProfileImage() {
    final imageProvider =
        _teacher != null && _teacher!.profileImage.isNotEmpty
            ? (Uri.tryParse(_teacher!.profileImage)?.isAbsolute ?? false)
                ? NetworkImage(_teacher!.profileImage)
                : FileImage(File(_teacher!.profileImage)) as ImageProvider
            : null;

    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade100,
        backgroundImage: imageProvider,
        child:
            imageProvider == null
                ? const Icon(Icons.person, size: 60, color: Color(0xFF0D47A1))
                : null,
      ),
    );
  }

  Widget _buildInfoField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        initialValue: value ?? '',
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF90A4AE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 14,
          ),
        ),
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return _buildInfoField(
      'Giới tính',
      _teacher != null
          ? _teacher!.gender.toString().split('.').last.toUpperCase()
          : '',
    );
  }

  Widget _buildDateOfBirthField() {
    return _buildInfoField(
      'Ngày sinh',
      _teacher != null && _teacher!.dateOfBirth != null
          ? '${_teacher!.dateOfBirth.day.toString().padLeft(2, '0')}/'
              '${_teacher!.dateOfBirth.month.toString().padLeft(2, '0')}/'
              '${_teacher!.dateOfBirth.year}'
          : '',
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận đăng xuất'),
            content: const Text('Bạn có chắc muốn đăng xuất không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      if (widget.onLogout != null) {
        widget.onLogout!();
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Hồ sơ giảng viên',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0D47A1)),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF0D47A1)),
                ),
              )
              : _teacher == null
              ? const Center(
                child: Text(
                  'Không tìm thấy thông tin giáo viên',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileImage(),
                    const SizedBox(height: 30),
                    _buildInfoField('Mã giáo viên', _teacher!.teacherCode),
                    const SizedBox(height: 12),
                    _buildInfoField('Họ và tên', _teacher!.fullName),
                    const SizedBox(height: 12),
                    _buildGenderField(),
                    const SizedBox(height: 12),
                    _buildDateOfBirthField(),
                    const SizedBox(height: 44),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _handleLogout, // Sử dụng hàm xác nhận
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Đăng xuất',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
