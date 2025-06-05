import 'package:flutter/material.dart';
import '../../database/models.dart';
import '../../database/account_table.dart';
import '../../database/request_table.dart';

class NewQuestionForm extends StatefulWidget {
  final int userId;

  const NewQuestionForm({Key? key, required this.userId}) : super(key: key);

  @override
  State<NewQuestionForm> createState() => _NewQuestionFormState();
}

class _NewQuestionFormState extends State<NewQuestionForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _categories = ['Học tập', 'Học phí', 'Thủ tục hành chính'];
  String? _selectedCategory;
  bool _selectTeacher = false;
  int? _selectedTeacherId;
  List<Teacher> _teachers = [];
  final _dbHelper = DBHelper();
  final _requestDBHelper = RequestDBHelper();

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final teachers = await _dbHelper.getTeachers();
    setState(() {
      _teachers = teachers;
    });
  }

  Future<void> _submitQuestion() async {
    if (_selectedCategory == null ||
        _titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        (_selectTeacher && _selectedTeacherId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    try {
      final newRequest = Request(
        requestId: 0, // Sẽ được tự động tạo bởi database
        studentUserId: widget.userId,
        questionType: _selectedCategory!,
        title: _titleController.text,
        content: _contentController.text,
        attachedFilePath: null, // Bỏ phần đính kèm file
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
        receiverUserId: _selectedTeacherId,
      );

      await _requestDBHelper.insertRequest(newRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi câu hỏi thành công, chờ admin xử lý'),
        ),
      );

      setState(() {
        _selectedCategory = null;
        _titleController.clear();
        _contentController.clear();
        _selectTeacher = false;
        _selectedTeacherId = null;
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error submitting question: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi khi gửi câu hỏi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Câu Hỏi Mới'),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loại câu hỏi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tiêu đề',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nội dung',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Chọn giáo viên để hỏi'),
              value: _selectTeacher,
              onChanged: (val) => setState(() => _selectTeacher = val!),
            ),
            if (_selectTeacher)
              DropdownButtonFormField<int>(
                value: _selectedTeacherId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Chọn giáo viên',
                ),
                items: _teachers.map((teacher) {
                  return DropdownMenuItem<int>(
                    value: teacher.userId,
                    child: Text(teacher.fullName),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedTeacherId = val),
              ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _submitQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Gửi Câu Hỏi',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
