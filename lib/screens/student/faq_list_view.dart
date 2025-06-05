// faq_list_view.dart
import 'package:flutter/material.dart';
import '../../database/request_table.dart';
import '../../database/student_table.dart';
import '../../database/models.dart';
import '../../chat_view.dart';

class FAQListView extends StatefulWidget {
  final int userId;

  const FAQListView({Key? key, required this.userId}) : super(key: key);

  @override
  State<FAQListView> createState() => _FAQListScreenState();
}

class _FAQListScreenState extends State<FAQListView> {
  final _requestDBHelper = RequestDBHelper();
  List<Request> _requests = [];
  bool _isLoading = true;
  Student? _student;

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _loadStudentProfile();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _requestDBHelper.getRequestsByStudent(
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

  Future<void> _loadStudentProfile() async {
    try {
      final studentDBHelper = StudentDBHelper();
      final student = await studentDBHelper.getStudentByUserId(widget.userId);
      setState(() {
        _student = student;
      });
    } catch (e) {
      print('Error loading student profile: $e');
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
              ? const Center(child: Text('Bạn chưa có câu hỏi nào'))
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
                          request.status == RequestStatus.approved &&
                                  request.boxChatId != null
                              ? const Icon(Icons.chat, color: Colors.green)
                              : null,
                      onTap:
                          request.status == RequestStatus.approved &&
                                  request.boxChatId != null
                              ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ChatScreen(
                                          userId: widget.userId,
                                          receiverId: request.receiverUserId!,
                                          boxChatId: request.boxChatId!,
                                          role: UserRole.student,
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
