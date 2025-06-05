// StudentScreen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'new_question_form.dart';
import 'faq_list_view.dart';
import '../../database/box_chat_table.dart';
import '../../database/student_table.dart';
import '../../database/request_table.dart';
import '../../database/models.dart';
import '../../chat_view.dart';

class StudentScreen extends StatefulWidget {
  final int userId;

  const StudentScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  int _currentIndex = 0;
  Student? _student;
  bool _isLoadingProfile = true;

  final List<_FeatureCardData> _features = [
    _FeatureCardData('Tổng quan', Icons.dashboard),
    _FeatureCardData('Câu hỏi thường gặp', Icons.help_outline),
    _FeatureCardData('Đặt câu hỏi mới', Icons.edit_note),
    _FeatureCardData('Tải biểu mẫu', Icons.file_download),
    _FeatureCardData('Thông tin cá nhân', Icons.person),
    _FeatureCardData('Hộp thoại', Icons.chat),
    _FeatureCardData('Thông báo', Icons.notifications),
    _FeatureCardData('Đăng xuất', Icons.logout),
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final studentDBHelper = StudentDBHelper();
      final student = await studentDBHelper.getStudentByUserId(widget.userId);
      setState(() {
        _student = student;
        _isLoadingProfile = false;
      });
    } catch (e) {
      print('Error loading student profile: $e');
      setState(() => _isLoadingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải thông tin cá nhân')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      print('UserId removed from SharedPreferences');
    } catch (e) {
      print('Error accessing SharedPreferences: $e');
    }

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _navigateToScreen(int index) {
    if (_features[index].title == 'Câu hỏi thường gặp') {
      setState(() {
        _currentIndex = 1;
      });
    } else if (_features[index].title == 'Đặt câu hỏi mới') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewQuestionForm(userId: widget.userId),
        ),
      );
    } else if (_features[index].title == 'Hộp thoại') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ChatListScreen(userId: widget.userId, role: UserRole.student),
        ),
      );
    } else if (_features[index].title == 'Thông tin cá nhân') {
      _showProfileDialog();
    } else if (_features[index].title == 'Đăng xuất') {
      showDialog<bool>(
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
      ).then((confirm) {
        if (confirm == true) {
          _logout();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Chức năng "${_features[index].title}" đang phát triển',
          ),
        ),
      );
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thông tin cá nhân'),
            content:
                _isLoadingProfile
                    ? const Center(child: CircularProgressIndicator())
                    : _student == null
                    ? const Text('Không tìm thấy thông tin sinh viên.')
                    : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mã sinh viên: ${_student!.studentCode}'),
                          const SizedBox(height: 8),
                          Text('Họ tên: ${_student!.fullName}'),
                          const SizedBox(height: 8),
                          Text(
                            'Giới tính: ${_student!.gender.toString().split('.').last}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ngày sinh: ${_student!.dateOfBirth.toString().split(' ')[0]}',
                          ),
                          const SizedBox(height: 8),
                          Text('Nơi sinh: ${_student!.placeOfBirth}'),
                          const SizedBox(height: 8),
                          Text('Lớp: ${_student!.className}'),
                          const SizedBox(height: 8),
                          Text('Năm nhập học: ${_student!.intakeYear}'),
                          const SizedBox(height: 8),
                          Text('Chuyên ngành: ${_student!.major}'),
                        ],
                      ),
                    ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children:
                    _features
                        .asMap()
                        .entries
                        .map(
                          (entry) => _FeatureCard(
                            title: entry.value.title,
                            icon: entry.value.icon,
                            onTap: () => _navigateToScreen(entry.key),
                          ),
                        )
                        .toList(),
              ),
            ),
            FAQListView(userId: widget.userId),
            const PlaceholderTab(
              title: 'Thông tin cá nhân',
            ), // Thêm PlaceholderTab
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2C3E50),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index.clamp(0, 2);
          });
          _navigateToScreen(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'FAQ'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}

class _FeatureCardData {
  final String title;
  final IconData icon;

  const _FeatureCardData(this.title, this.icon);
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: const Color(0xFF2C3E50)),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderTab extends StatelessWidget {
  final String title;

  const PlaceholderTab({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Tính năng đang được phát triển...'),
          ],
        ),
      ),
    );
  }
}

class ChatListScreen extends StatefulWidget {
  final int userId;
  final UserRole role;

  const ChatListScreen({Key? key, required this.userId, required this.role})
    : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatboxDBHelper = ChatboxDBHelper();
  List<BoxChat> _boxChats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBoxChats();
  }

  Future<void> _loadBoxChats() async {
    setState(() => _isLoading = true);
    try {
      final boxChats = await _chatboxDBHelper.getBoxChatsByUser(widget.userId);
      setState(() {
        _boxChats = boxChats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading box chats: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải danh sách hộp thoại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách hộp thoại'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _boxChats.isEmpty
              ? const Center(child: Text('Không có hộp thoại nào'))
              : ListView.builder(
                itemCount: _boxChats.length,
                itemBuilder: (context, index) {
                  final boxChat = _boxChats[index];
                  return ListTile(
                    title: Text('Hộp thoại #${boxChat.boxChatId}'),
                    subtitle: Text('Yêu cầu ID: ${boxChat.requestId}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatScreen(
                                userId: widget.userId,
                                receiverId:
                                    boxChat.senderUserId == widget.userId
                                        ? boxChat.receiverUserId
                                        : boxChat.senderUserId,
                                boxChatId: boxChat.boxChatId,
                                role: widget.role,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
