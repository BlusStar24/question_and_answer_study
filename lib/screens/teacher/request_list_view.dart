// request_list_view.dart
import 'package:flutter/material.dart';
import '../../database/request_table.dart';
import '../../database/teacher_table.dart';
import '../../database/models.dart';
import '../../chat_view.dart';

class RequestListView extends StatefulWidget {
  final int userId; // Đổi từ teacherId sang userId

  const RequestListView({Key? key, required this.userId}) : super(key: key);

  @override
  State<RequestListView> createState() => _RequestListViewState();
}

class _RequestListViewState extends State<RequestListView> {
  final _requestDBHelper = RequestDBHelper();
  List<Request> _requests = [];
  bool _isLoading = true;
  Teacher? _teacher;

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _loadTeacherProfile();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _requestDBHelper.getRequestsByTeacher(
        widget.userId,
      );
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading requests: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải danh sách câu hỏi')),
      );
    }
  }

  Future<void> _loadTeacherProfile() async {
    try {
      final teacherDBHelper = TeacherDBHelper();
      final teacher = await teacherDBHelper.getTeacherByUserId(widget.userId);
      setState(() {
        _teacher = teacher;
      });
    } catch (e) {
      print('Error loading teacher profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách câu hỏi'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _requests.isEmpty
              ? const Center(
                child: Text('Không có câu hỏi nào được gửi đến bạn'),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final request = _requests[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(request.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Danh mục: ${request.questionType}'),
                          Text(
                            'Trạng thái: ${request.status.toString().split('.').last}',
                          ),
                        ],
                      ),
                      trailing:
                          request.boxChatId != null
                              ? const Icon(Icons.chat, color: Colors.green)
                              : null,
                      onTap:
                          request.boxChatId != null
                              ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ChatScreen(
                                          userId: widget.userId,
                                          receiverId: request.studentUserId,
                                          boxChatId: request.boxChatId!,
                                          role: UserRole.teacher,
                                        ),
                                  ),
                                );
                              }
                              : null,
                    ),
                  );
                },
              ),
    );
  }
}
