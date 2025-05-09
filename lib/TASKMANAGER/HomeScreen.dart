import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../TASKMANAGER/view/USER/UserListScreen.dart';
import '../TASKMANAGER/view/TASK/TaskListScreen.dart';
import '../TASKMANAGER/service/AuthService.dart';
import 'LoginScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<bool> _checkIfAdmin(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['role'] == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = fb.FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('❌ Không tìm thấy người dùng hiện tại!')),
      );
    }

    return FutureBuilder<bool>(
      future: _checkIfAdmin(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final isAdmin = snapshot.data ?? false;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              elevation: 2,
              title: Row(
                children: const [
                  Icon(Icons.dashboard_customize),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Quản lý công việc & người dùng',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Đăng xuất',
                  onPressed: () => _logout(context),
                ),
              ],
              bottom: const TabBar(
                indicatorColor: Colors.amber,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(icon: Icon(Icons.task), text: 'Công việc'),
                  Tab(icon: Icon(Icons.people), text: 'Người dùng'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                TaskListScreen(isAdmin: isAdmin),
                UserListScreen(isAdmin: isAdmin),
              ],
            ),
          ),
        );
      },
    );
  }
}
