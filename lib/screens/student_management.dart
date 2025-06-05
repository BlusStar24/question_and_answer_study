import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/models.dart';
import '../../database/student_table.dart';

class StudentManagementView extends StatefulWidget {
  final VoidCallback? onBack;

  const StudentManagementView({Key? key, this.onBack}) : super(key: key);

  @override
  State<StudentManagementView> createState() => _StudentManagementViewState();
}

class _StudentManagementViewState extends State<StudentManagementView> {
  final StudentDBHelper _dbHelper = StudentDBHelper();

  List<Student> _students = [];
  Student? _selectedStudent;

  final _nameController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _classNameController = TextEditingController();
  final _majorController = TextEditingController();
  Gender _gender = Gender.male;
  DateTime? _dob;
  File? _imageFile;
  int _intakeYear = DateTime.now().year;
  bool _isNew = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final list = await _dbHelper.getAllStudents();
      setState(() {
        _students = list;
        if (!_isNew && list.isNotEmpty) _selectStudent(list[0]);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách học sinh: $e')),
      );
    }
  }

  void _selectStudent(Student s) {
    _selectedStudent = s;
    _nameController.text = s.fullName;
    _placeOfBirthController.text = s.placeOfBirth;
    _classNameController.text = s.className;
    _majorController.text = s.major;
    _gender = s.gender;
    _dob = s.dateOfBirth;
    _intakeYear = s.intakeYear;
    _imageFile =
        (s.profileImage.isNotEmpty && !Uri.parse(s.profileImage).isAbsolute)
        ? File(s.profileImage)
        : null;
    _isNew = false;
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 18),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _newStudent() {
    _selectedStudent = null;
    _nameController.clear();
    _placeOfBirthController.clear();
    _classNameController.clear();
    _majorController.clear();
    _gender = Gender.male;
    _dob = null;
    _imageFile = null;
    _intakeYear = DateTime.now().year;
    _isNew = true;
    setState(() {});
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final placeOfBirth = _placeOfBirthController.text.trim();
    final className = _classNameController.text.trim();
    final major = _majorController.text.trim();

    if (name.isEmpty ||
        placeOfBirth.isEmpty ||
        className.isEmpty ||
        major.isEmpty ||
        _dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng điền đầy đủ họ tên, nơi sinh, lớp, chuyên ngành và ngày sinh',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isNew) {
        final newStudent = Student(
          userId: 0,
          studentCode: '',
          fullName: name,
          gender: _gender,
          dateOfBirth: _dob!,
          placeOfBirth: placeOfBirth,
          className: className,
          intakeYear: _intakeYear,
          major: major,
          profileImage: _imageFile?.path ?? '',
          isDeleted: false,
        );

        final created = await _dbHelper.insertStudent(newStudent);
        if (created != null) {
          await _loadStudents();
          _selectStudent(created);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thêm học sinh thành công: ${created.studentCode}'),
            ),
          );
        }
      } else {
        if (_selectedStudent == null) return;
        final updated = Student(
          userId: _selectedStudent!.userId,
          studentCode: _selectedStudent!.studentCode,
          fullName: name,
          gender: _gender,
          dateOfBirth: _dob!,
          placeOfBirth: placeOfBirth,
          className: className,
          intakeYear: _intakeYear,
          major: major,
          profileImage: _imageFile?.path ?? _selectedStudent!.profileImage,
          isDeleted: false,
        );
        final result = await _dbHelper.updateStudent(updated);
        if (result > 0) {
          await _loadStudents();
          _selectStudent(updated);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thông tin học sinh thành công'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thông tin học sinh thất bại'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu học sinh: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<Gender>(
      value: _gender,
      decoration: const InputDecoration(labelText: 'Giới tính'),
      items: Gender.values
          .map(
            (g) => DropdownMenuItem(
              value: g,
              child: Text(g.toString().split('.').last.toUpperCase()),
            ),
          )
          .toList(),
      onChanged: (g) {
        if (g != null) setState(() => _gender = g);
      },
    );
  }

  Widget _buildDobPicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Ngày sinh',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dob == null
                  ? 'Chưa chọn'
                  : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
        isEmpty: _dob == null,
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Ảnh đại diện',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_imageFile == null ? 'Chưa chọn ảnh' : 'Đã chọn ảnh'),
            const Icon(Icons.image),
          ],
        ),
      ),
    );
  }

  Widget _buildIntakeYearPicker() {
    final currentYear = DateTime.now().year;
    final minYear = 2000;
    final years = List.generate(
      currentYear - minYear + 1,
      (index) => currentYear - index,
    );

    if (!years.contains(_intakeYear)) {
      _intakeYear = currentYear;
    }

    return DropdownButtonFormField<int>(
      value: _intakeYear,
      decoration: const InputDecoration(labelText: 'Năm nhập học'),
      items: years
          .map(
            (year) =>
                DropdownMenuItem(value: year, child: Text(year.toString())),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _intakeYear = value);
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _save,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.blue.shade800,
      ),
      child: _isSaving
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Lưu',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeOfBirthController.dispose();
    _classNameController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _selectedStudent == null && !_isNew;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị Học sinh'),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newStudent,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
              ),
              const SizedBox(height: 12),
              _buildGenderDropdown(),
              const SizedBox(height: 12),
              _buildDobPicker(),
              const SizedBox(height: 12),
              TextField(
                controller: _placeOfBirthController,
                decoration: const InputDecoration(labelText: 'Nơi sinh'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _classNameController,
                decoration: const InputDecoration(labelText: 'Lớp'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _majorController,
                decoration: const InputDecoration(labelText: 'Chuyên ngành'),
              ),
              const SizedBox(height: 12),
              _buildIntakeYearPicker(),
              const SizedBox(height: 12),
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }
}
