import 'package:flutter/material.dart';
import '../database/models.dart';
import '../chat_view.dart';
import '../../database/request_table.dart';
import '../../database/box_chat_table.dart';
import '../../database/teacher_table.dart';

class RequestManagementView extends StatefulWidget {
  const RequestManagementView({Key? key}) : super(key: key);

  @override
  State<RequestManagementView> createState() => _RequestManagementViewState();
}

class _RequestManagementViewState extends State<RequestManagementView> {
  final RequestDBHelper _requestDBHelper = RequestDBHelper();
  final ChatboxDBHelper _chatboxDBHelper = ChatboxDBHelper();
  List<Request> _pendingRequests = [];
  List<Teacher> _teachers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final requests = await _requestDBHelper.getRequestsByStatus('pending');
      final teachers = await TeacherDBHelper().getAllTeachers();

      print('Có ${teachers.length} giáo viên để phân công');
      for (var t in teachers) {
        print('GV: ${t.fullName} (${t.userId})');
      }

      setState(() {
        _pendingRequests = requests;
        _teachers = teachers;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
    }
  }

  Future<void> _approveRequest(Request request, int? selectedTeacherId) async {
    if (selectedTeacherId == null && request.receiverUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn giảng viên để phân công')),
      );
      return;
    }

    try {
      final teacherId = selectedTeacherId ?? request.receiverUserId!;
      await _requestDBHelper.approveRequest(request.requestId, teacherId);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã duyệt request và tạo hộp thoại')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi duyệt request: $e')));
    }
  }

  Future<void> _rejectRequest(Request request) async {
    try {
      final result = await _requestDBHelper.updateRequestStatus(
        request.requestId,
        RequestStatus.rejected,
      );
      if (result > 0) {
        await _loadData();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã từ chối request')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy request để từ chối')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi từ chối request: $e')));
    }
  }

  Future<void> _deleteBoxChat(int boxChatId) async {
    try {
      await _chatboxDBHelper.deleteBoxChat(boxChatId);
      await _loadData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa hộp thoại')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa hộp thoại: $e')));
    }
  }

  void _showRequestDetails(BuildContext context, Request request) {
    int? selectedTeacherId = request.receiverUserId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Chi tiết Request #${request.requestId}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sinh viên ID: ${request.studentUserId}'),
                const SizedBox(height: 8),
                Text('Danh mục: ${request.questionType}'),
                const SizedBox(height: 8),
                Text('Tiêu đề: ${request.title}'),
                const SizedBox(height: 8),
                Text('Nội dung: ${request.content}'),
                const SizedBox(height: 8),
                if (request.attachedFilePath != null)
                  Text(
                    'Tệp đính kèm: ${request.attachedFilePath!.split('/').last}',
                  ),
                const SizedBox(height: 8),
                if (request.receiverUserId != null)
                  Text(
                    'Giảng viên: ${_teachers.firstWhere(
                      (t) => t.userId == request.receiverUserId,
                      orElse: () => Teacher(userId: request.receiverUserId!, teacherCode: 'N/A', fullName: 'Không tìm thấy', gender: Gender.male, dateOfBirth: DateTime.now(), profileImage: '', isDeleted: false),
                    ).fullName}',
                  ),
                if (request.receiverUserId == null &&
                    request.status == RequestStatus.pending)
                  DropdownButtonFormField<int>(
                    value: selectedTeacherId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Phân công giảng viên',
                    ),
                    items: _teachers.isEmpty
                        ? [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text('Không có giảng viên'),
                            ),
                          ]
                        : _teachers.map((teacher) {
                            return DropdownMenuItem<int>(
                              value: teacher.userId,
                              child: Text(teacher.fullName),
                            );
                          }).toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedTeacherId = val),
                    hint: const Text('Chọn giảng viên'),
                  ),
                if (request.status == RequestStatus.approved &&
                    request.boxChatId != null)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                userId: 0,
                                receiverId: request.studentUserId,
                                boxChatId: request.boxChatId!,
                                role: UserRole.admin,
                              ),
                            ),
                          );
                        },
                        child: const Text('Xem Hộp Thoại'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xóa Hộp Thoại'),
                              content: const Text(
                                'Bạn có chắc muốn xóa hộp thoại này?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ).then((confirm) {
                            if (confirm == true) {
                              _deleteBoxChat(request.boxChatId!);
                            }
                          });
                        },
                        child: const Text(
                          'Xóa Hộp Thoại',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            if (request.status == RequestStatus.pending)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            if (request.status == RequestStatus.pending)
              TextButton(
                onPressed: () {
                  _rejectRequest(request);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Từ chối',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (request.status == RequestStatus.pending)
              TextButton(
                onPressed: () {
                  if (selectedTeacherId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn giảng viên')),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  _approveRequest(request, selectedTeacherId);
                },
                child: const Text(
                  'Duyệt',
                  style: TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Request'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: _pendingRequests.isEmpty
          ? const Center(child: Text('Không có request chờ xử lý'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingRequests.length,
              itemBuilder: (context, index) {
                final request = _pendingRequests[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(request.title),
                    subtitle: Text('Danh mục: ${request.questionType}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showRequestDetails(context, request),
                  ),
                );
              },
            ),
    );
  }
}
