import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/admin_screen.dart';
import 'screens/../screens/student/student_screen.dart';
import 'screens/../screens/teacher/teacher_screen.dart';
import 'database/account_table.dart';
import 'database/message_table.dart';
import 'database/box_chat_table.dart';
import 'database/request_table.dart';
import 'database/models.dart';
import 'database/teacher_table.dart';
import 'database/student_table.dart';

Future<void> initializeHive() async {
  // Xóa dữ liệu Hive cũ (dùng tạm thời trong phát triển, xóa sau khi xong)
  try {
    await Hive.deleteFromDisk();
    print('Deleted Hive data successfully');
  } catch (e) {
    print('Error deleting Hive data: $e');
  }

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Đăng ký các adapter với kiểm tra rõ ràng
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserRoleAdapter());
    print('Registering UserRoleAdapter');
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(GenderAdapter());
    print('Registering GenderAdapter');
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(RequestStatusAdapter());
    print('Registering RequestStatusAdapter');
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(AccountAdapter());
    print('Registering AccountAdapter');
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(StudentAdapter());
    print('Registering StudentAdapter');
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(TeacherAdapter());
    print('Registering TeacherAdapter');
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(RequestAdapter());
    print('Registering RequestAdapter');
  }
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(BoxChatAdapter());
    print('Registering BoxChatAdapter');
  }
  if (!Hive.isAdapterRegistered(8)) {
    Hive.registerAdapter(MessageAdapter());
    print('Registering MessageAdapter');
  }
  if (!Hive.isAdapterRegistered(9)) {
    Hive.registerAdapter(ReportAdapter());
    print('Registering ReportAdapter');
  }
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(BannedWordAdapter());
    print('Registering BannedWordAdapter');
  }

  // Mở các box
  await Hive.openBox<Account>('accounts');
  await Hive.openBox<Message>('messages');
  await Hive.openBox<BoxChat>('boxChats');
  await Hive.openBox<Request>('requests');
  await Hive.openBox<BannedWord>('bannedWords');
  await Hive.openBox<Teacher>('teachers');
  await Hive.openBox<Student>('students');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.deleteFromDisk(); // Dùng tạm thời trong phát triển, xóa sau khi xong
  await initializeHive();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C3E50),
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey.shade100,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/admin': (context) => const AdminScreen(),
        '/student': (context) => StudentScreen(
          userId: ModalRoute.of(context)!.settings.arguments as int,
        ),
        '/teacher': (context) => TeacherScreen(
          userId: ModalRoute.of(context)!.settings.arguments as int,
        ),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final prefs = snapshot.data!;
        final userId = prefs.getInt('userId');
        final roleString = prefs.getString('userRole');

        final role = roleString != null
            ? UserRole.values.firstWhere(
                (e) => e.toString() == roleString,
                orElse: () => UserRole.student,
              )
            : null;

        if (userId == null || role == null) {
          return const LoginScreen();
        }

        // Kiểm tra tài khoản trong Hive
        return FutureBuilder<Account?>(
          future: DBHelper().getAccountById(userId),
          builder: (context, accountSnapshot) {
            if (accountSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final account = accountSnapshot.data;
            if (account == null || account.isDeleted || account.role != role) {
              // Tài khoản không hợp lệ, điều hướng về LoginScreen
              prefs.remove('userId');
              prefs.remove('userRole');
              return const LoginScreen();
            }

            // Kiểm tra vai trò và điều hướng đến màn hình phù hợp
            if (role == UserRole.admin) {
              return const AdminScreen();
            } else if (role == UserRole.student) {
              // Kiểm tra thông tin sinh viên
              return FutureBuilder<Student?>(
                future: StudentDBHelper().getStudentByUserId(userId),
                builder: (context, studentSnapshot) {
                  if (studentSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final student = studentSnapshot.data;
                  if (student == null || student.isDeleted) {
                    prefs.remove('userId');
                    prefs.remove('userRole');
                    return const LoginScreen();
                  }

                  return StudentScreen(userId: userId);
                },
              );
            } else if (role == UserRole.teacher) {
              // Kiểm tra thông tin giảng viên
              return FutureBuilder<Teacher?>(
                future: TeacherDBHelper().getTeacherByUserId(userId),
                builder: (context, teacherSnapshot) {
                  if (teacherSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final teacher = teacherSnapshot.data;
                  if (teacher == null || teacher.isDeleted) {
                    prefs.remove('userId');
                    prefs.remove('userRole');
                    return const LoginScreen();
                  }

                  return TeacherScreen(userId: userId);
                },
              );
            } else {
              // Vai trò không hợp lệ
              prefs.remove('userId');
              prefs.remove('userRole');
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Kiểm tra tài khoản admin cố định
      if (username == 'admin@gmail.com' && password == '123456') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', 0); // ID cố định cho admin
        await prefs.setString('userRole', UserRole.admin.toString());
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        // Xử lý các tài khoản khác từ cơ sở dữ liệu
        final dbHelper = DBHelper();
        final account = await dbHelper.getAccountByUsername(username);

        if (account != null && account.password == password) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', account.userId);
          await prefs.setString('userRole', account.role.toString());

          // Điều hướng đến màn hình tương ứng dựa trên vai trò
          if (account.role == UserRole.admin) {
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (account.role == UserRole.student) {
            Navigator.pushReplacementNamed(
              context,
              '/student',
              arguments: account.userId,
            );
          } else if (account.role == UserRole.teacher) {
            Navigator.pushReplacementNamed(
              context,
              '/teacher',
              arguments: account.userId,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sai tên đăng nhập hoặc mật khẩu')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi đăng nhập: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Chào mừng đến với ứng dụng quản lý trường học',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue.shade800,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Đăng nhập',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
