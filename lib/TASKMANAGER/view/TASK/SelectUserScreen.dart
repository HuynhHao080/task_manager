import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectUserScreen extends StatefulWidget {
  final List<String> assignedUserIds;

  const SelectUserScreen({Key? key, required this.assignedUserIds}) : super(key: key);

  @override
  State<SelectUserScreen> createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  late Set<String> selectedUserIds;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedUserIds = {...widget.assignedUserIds};
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredUsers = _users.where((user) {
        final name = user['name']?.toLowerCase() ?? '';
        final email = user['email']?.toLowerCase() ?? '';
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  Future<void> _loadUsers() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'user')
        .get();

    final users = snap.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['username'] ?? data['email'] ?? 'Không rõ',
        'email': data['email'] ?? '',
      };
    }).toList();

    setState(() {
      _users = users;
      _filteredUsers = users;
    });
  }

  void _confirmSelection() {
    Navigator.pop(context, selectedUserIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn người nhận'),
        actions: [
          IconButton(
            onPressed: _confirmSelection,
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Xác nhận lựa chọn',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '🔍 Tìm người dùng theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? const Center(child: Text('Không có người dùng nào phù hợp.'))
                : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: _filteredUsers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                final isSelected = selectedUserIds.contains(user['id']);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: CheckboxListTile(
                    value: isSelected,
                    title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(user['email'], style: const TextStyle(fontSize: 13)),
                    secondary: const Icon(Icons.person_outline),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedUserIds.add(user['id']);
                        } else {
                          selectedUserIds.remove(user['id']);
                        }
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
