import 'package:flutter/material.dart';
import '../../database/account_table.dart';
import '../database/models.dart';
import 'student_management.dart';
import 'teacher_management.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({Key? key}) : super(key: key);

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final DBHelper _accountHelper = DBHelper();
  List<Account> _accounts = [];

  String _currentSubView =
      'accountList'; // 'accountList', 'studentManagement', 'teacherManagement'

  // Biến lọc loại tài khoản
  String _selectedRoleFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _accountHelper.getAllAccounts();
      setState(() {
        _accounts = accounts;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách tài khoản: $e')),
      );
    }
  }

  Future<void> _deleteAccount(Account account) async {
    try {
      await _accountHelper.softDeleteAccount(account.userId);
      await _loadAccounts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa tài khoản ${account.username}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa tài khoản: $e')));
    }
  }

  void _showDeleteDialog(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: Text(
          'Bạn có chắc muốn xóa tài khoản "${account.username}" không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteAccount(account);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAccountDetail(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thông tin tài khoản: ${account.username}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vai trò: ${_roleToDisplayName(account.role)}'),
            Text('ID: ${account.userId}'),
          ],
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

  void _showCreateAccount() {
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();
    UserRole? _selectedRole = UserRole.student;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tạo tài khoản mới'),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên đăng nhập',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Vai trò',
                      border: OutlineInputBorder(),
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem<UserRole>(
                        value: role,
                        child: Text(_roleToDisplayName(role)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => _selectedRole = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                final username = _usernameController.text.trim();
                final password = _passwordController.text.trim();
                if (username.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập đầy đủ thông tin'),
                    ),
                  );
                  return;
                }
                try {
                  final newAccount = Account(
                    userId: 0, // Hive sẽ tự động tạo ID
                    username: username,
                    password: password,
                    role: _selectedRole!,
                    isDeleted: false,
                  );
                  await _accountHelper.insertAccount(newAccount);
                  Navigator.pop(context);
                  await _loadAccounts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tạo tài khoản $username thành công'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi tạo tài khoản: $e')),
                  );
                }
              },
              child: const Text('Tạo', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 32, color: Colors.blueAccent),
      ),
    );
  }

  // Chuyển enum role sang tên hiển thị tiếng Việt
  String _roleToDisplayName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Sinh viên';
      case UserRole.teacher:
        return 'Giáo viên';
      case UserRole.admin:
        return 'Quản trị viên';
    }
  }

  // Lọc danh sách tài khoản dựa vào _selectedRoleFilter
  List<Account> get _filteredAccounts {
    if (_selectedRoleFilter == 'all') {
      return _accounts;
    } else if (_selectedRoleFilter == 'student') {
      return _accounts.where((acc) => acc.role == UserRole.student).toList();
    } else if (_selectedRoleFilter == 'teacher') {
      return _accounts.where((acc) => acc.role == UserRole.teacher).toList();
    }
    return _accounts;
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (_currentSubView) {
      case 'studentManagement':
        content = StudentManagementView(
          onBack: () {
            setState(() {
              _currentSubView = 'accountList';
            });
            _loadAccounts();
          },
        );
        break;

      case 'teacherManagement':
        content = TeacherManagementView(
          onBack: () {
            setState(() {
              _currentSubView = 'accountList';
            });
            _loadAccounts();
          },
        );
        break;

      case 'accountList':
      default:
        content = Column(
          children: [
            // 3 nút icon phía trên để tạo tài khoản và điều hướng
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconButton(
                    icon: Icons.account_circle,
                    onTap: _showCreateAccount,
                  ),
                  _buildIconButton(
                    icon: Icons.school,
                    onTap: () =>
                        setState(() => _currentSubView = 'studentManagement'),
                  ),
                  _buildIconButton(
                    icon: Icons.person,
                    onTap: () =>
                        setState(() => _currentSubView = 'teacherManagement'),
                  ),
                ],
              ),
            ),

            // Dropdown chọn loại tài khoản
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedRoleFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Lọc theo vai trò',
                    border: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('Tất cả tài khoản'),
                    ),
                    DropdownMenuItem(
                      value: 'student',
                      child: Text('Sinh viên'),
                    ),
                    DropdownMenuItem(
                      value: 'teacher',
                      child: Text('Giáo viên'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRoleFilter = value;
                      });
                    }
                  },
                ),
              ),
            ),

            // Danh sách tài khoản lọc theo loại
            Expanded(
              child: _filteredAccounts.isEmpty
                  ? const Center(
                      child: Text(
                        'Chưa có tài khoản nào',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _filteredAccounts.length,
                      itemBuilder: (context, index) {
                        final account = _filteredAccounts[index];

                        Color roleColor;
                        switch (account.role) {
                          case UserRole.admin:
                            roleColor = Colors.grey;
                            break;
                          case UserRole.teacher:
                            roleColor = Colors.blue;
                            break;
                          case UserRole.student:
                            roleColor = Colors.green;
                            break;
                        }

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: roleColor.withOpacity(0.2),
                              child: Text(
                                account.username.isNotEmpty
                                    ? account.username[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: roleColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            title: Text(
                              account.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              _roleToDisplayName(account.role),
                              style: TextStyle(
                                color: roleColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _showDeleteDialog(account),
                            ),
                            onTap: () => _showAccountDetail(account),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Người dùng'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: content,
    );
  }
}
