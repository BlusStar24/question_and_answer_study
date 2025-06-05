import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/models.dart';
import '../database/message_table.dart';
import '../database/box_chat_table.dart';
import '../database/request_table.dart';

class ChatScreen extends StatefulWidget {
  final int userId;
  final int receiverId;
  final int boxChatId;
  final UserRole role;

  const ChatScreen({
    Key? key,
    required this.userId,
    required this.receiverId,
    required this.boxChatId,
    this.role = UserRole.student,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final MessageDBHelper _dbHelper = MessageDBHelper();
  final ChatboxDBHelper _chatboxDBHelper = ChatboxDBHelper();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _loadMessages();
  }

  Future<void> _checkAccess() async {
    if (widget.role != UserRole.admin) {
      final boxChats = await _chatboxDBHelper.getBoxChatsByUser(widget.userId);
      if (!boxChats.any((box) => box.boxChatId == widget.boxChatId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn không có quyền truy cập hộp thoại này'),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final messages = await _dbHelper.getMessagesByBoxChat(widget.boxChatId);
      setState(() {
        _messages.addAll(messages);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể tải tin nhắn')));
    }
  }

  // Trong ChatScreen, sửa _sendMessage
  Future<void> _sendMessage() async {
    if (widget.role != UserRole.admin) {
      final content = _controller.text.trim();
      if (content.isEmpty) return;

      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('userId');
        if (userId == null || userId != widget.userId) {
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }

        final bannedWords = await RequestDBHelper().getBannedWords();
        if (bannedWords.any(
          (word) => content.toLowerCase().contains(word.word.toLowerCase()),
        )) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tin nhắn chứa ngôn ngữ không phù hợp. Vui lòng chỉnh sửa.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final message = Message(
          messageId: 0,
          boxChatId: widget.boxChatId,
          senderUserId: widget.userId,
          content: content,
          sentAt: DateTime.now(),
          isFile: false,
          isDeleted: false,
        );

        // Chèn tin nhắn và lấy messageId
        final newMessageId = await _dbHelper.insertMessage(message);
        if (newMessageId == 0) {
          throw Exception('Failed to insert message');
        }

        // Tạo Message mới với messageId thực tế
        final newMessage = Message(
          messageId: newMessageId,
          boxChatId: message.boxChatId,
          senderUserId: message.senderUserId,
          content: message.content,
          sentAt: message.sentAt,
          isFile: message.isFile,
          isDeleted: message.isDeleted,
        );

        setState(() {
          _messages.add(newMessage); // Thêm Message với messageId thực tế
          _controller.clear();
        });
      } catch (e) {
        print('Error sending message: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không thể gửi tin nhắn')));
      }
    }
  }

  Future<void> _closeAndDeleteBoxChat() async {
    try {
      await _chatboxDBHelper.deleteBoxChat(widget.boxChatId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Box chat đã được đóng và xóa')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error closing and deleting box chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể đóng và xóa box chat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hộp thoại'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        actions: [
          if (widget.role == UserRole.admin)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa Hộp Thoại'),
                    content: const Text('Bạn có chắc muốn xóa hộp thoại này?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
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
                    _closeAndDeleteBoxChat();
                  }
                });
              },
              tooltip: 'Xóa Hộp Thoại',
            ),
          if (widget.role != UserRole.admin)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Đóng và Xóa Hộp Thoại'),
                    content: const Text(
                      'Bạn hài lòng với câu trả lời và muốn đóng hộp thoại này không?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Đóng và Xóa',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ).then((confirm) {
                  if (confirm == true) {
                    _closeAndDeleteBoxChat();
                  }
                });
              },
              tooltip: 'Đóng và Xóa',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(child: Text('Chưa có tin nhắn'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isSentByUser =
                          message.senderUserId == widget.userId;
                      return Align(
                        alignment: isSentByUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSentByUser
                                ? const Color(0xFF2C3E50)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.content,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSentByUser
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                '${message.sentAt.hour}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (widget.role != UserRole.admin)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF2C3E50)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
