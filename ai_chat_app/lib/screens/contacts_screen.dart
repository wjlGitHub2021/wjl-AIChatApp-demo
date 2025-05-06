import 'package:flutter/material.dart';
import 'friend_request_screen.dart';
import 'blacklist_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // 模拟联系人数据
  final List<Map<String, dynamic>> _contacts = [
    {
      'name': '池平',
      'avatar': 'assets/images/avatar1.png',
      'description': '一个山川河脉人，这样的介绍足够你了解我吗？',
      'isOfficial': true,
    },
    {
      'name': '张三',
      'avatar': null,
      'description': '在线',
      'isOfficial': false,
    },
    {
      'name': '李四',
      'avatar': null,
      'description': '忙碌中',
      'isOfficial': false,
    },
    {
      'name': '王五',
      'avatar': null,
      'description': '离线',
      'isOfficial': false,
    },
    {
      'name': '赵六',
      'avatar': null,
      'description': '在线',
      'isOfficial': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通讯录'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddFriendDialog(context),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          children: [
            // 功能项
            _buildFunctionItem(
              icon: Icons.person_add,
              title: '好友申请',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FriendRequestScreen()),
              ),
            ),
            _buildFunctionItem(
              icon: Icons.block,
              title: '黑名单',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlacklistScreen()),
              ),
            ),
            
            // 官方客服
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                '官方客服',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _buildContactItem(_contacts[0], isOfficial: true),
            
            // 通讯录列表
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                '通讯录列表',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ...List.generate(
              _contacts.length - 1,
              (index) => _buildContactItem(_contacts[index + 1]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF06C755).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF06C755),
        ),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildContactItem(Map<String, dynamic> contact, {bool isOfficial = false}) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: isOfficial 
            ? const Color(0xFF06C755).withOpacity(0.1)
            : Colors.grey[300],
        backgroundImage: contact['avatar'] != null 
            ? AssetImage(contact['avatar']) 
            : null,
        child: contact['avatar'] == null
            ? Text(
                contact['name'][0],
                style: TextStyle(
                  color: isOfficial ? const Color(0xFF06C755) : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(contact['name']),
      subtitle: Text(
        contact['description'],
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      onTap: () {
        // 点击联系人的操作
      },
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加好友'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: '请输入用户ID或昵称',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // 搜索好友的逻辑
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('搜索功能尚未实现')),
              );
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }
}
