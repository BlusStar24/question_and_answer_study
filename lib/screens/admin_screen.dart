import 'package:flutter/material.dart';
import 'user_management_view.dart';
import 'request_management_view.dart';
import 'custom_bottom_navigation.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;

  final List<TabInfo> _tabs = const [
    TabInfo('Tổng quan', Icons.dashboard),
    TabInfo('Người dùng', Icons.people),
    TabInfo('Yêu cầu', Icons.assignment),
    TabInfo('Thông tin', Icons.person),
  ];

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _navigateToRequestManagement() {
    setState(() => _currentIndex = 2); // Chuyển đến tab Yêu cầu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 228, 156, 192),
              Colors.deepPurple.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text(
                      _tabs[_currentIndex].title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.exit_to_app,
                        color: Color.fromARGB(255, 193, 231, 215),
                      ),
                      onPressed: () {
                        // Navigate back to AdminScreen (self) to reset view
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      SingleChildScrollView(
                        child: OverviewTab(
                          onNavigateToUserManagement: () {
                            setState(() => _currentIndex = 1);
                          },
                          onNavigateToRequestManagement:
                              _navigateToRequestManagement,
                        ),
                      ),
                      const UserManagementView(),
                      const RequestManagementView(),
                      const PlaceholderTab(title: 'Quản trị viên'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        tabs: _tabs,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class OverviewTab extends StatelessWidget {
  final VoidCallback onNavigateToUserManagement;
  final VoidCallback onNavigateToRequestManagement;

  const OverviewTab({
    Key? key,
    required this.onNavigateToUserManagement,
    required this.onNavigateToRequestManagement,
  }) : super(key: key);

  final List<_FunctionItem> _functions = const [
    _FunctionItem(
      'Quản lý người dùng',
      Icons.people,
      'Quản lý tài khoản và quyền hạn',
    ),
    _FunctionItem(
      'Quản lý yêu cầu',
      Icons.assignment,
      'Xem và xử lý các yêu cầu',
    ),
    _FunctionItem('Báo cáo', Icons.report, 'Thống kê và báo cáo hệ thống'),
    _FunctionItem('Từ cấm', Icons.block, 'Quản lý từ khóa bị cấm'),
    _FunctionItem(
      'Thông báo hệ thống',
      Icons.notifications,
      'Quản lý thông báo gửi đến người dùng',
    ),
    _FunctionItem('Quản trị viên', Icons.person, 'Quản lý tài khoản quản trị'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _functions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final item = _functions[index];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            elevation: 8,
            shadowColor: Colors.deepPurple.withOpacity(0.25),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                if (item.title == 'Quản lý người dùng') {
                  onNavigateToUserManagement();
                } else if (item.title == 'Quản lý yêu cầu') {
                  onNavigateToRequestManagement();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Chức năng "${item.title}" đang phát triển',
                      ),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 48,
                      color: Colors.deepPurple.shade600,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.deepPurple.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.deepPurple.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FunctionItem {
  final String title;
  final IconData icon;
  final String subtitle;

  const _FunctionItem(this.title, this.icon, this.subtitle);
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
