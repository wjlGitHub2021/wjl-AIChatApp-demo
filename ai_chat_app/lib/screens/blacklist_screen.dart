import 'package:flutter/material.dart';

class BlacklistScreen extends StatefulWidget {
  const BlacklistScreen({super.key});

  @override
  State<BlacklistScreen> createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends State<BlacklistScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // 模拟黑名单数据
  final List<Map<String, dynamic>> _blacklist = [
    {'name': '张三', 'avatar': null, 'blockTime': '2023-05-15'},
    {'name': '李四', 'avatar': null, 'blockTime': '2023-06-20'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
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
        title: const Text('黑名单'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child:
            _blacklist.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _blacklist.length,
                  itemBuilder: (context, index) {
                    return _buildBlacklistItem(_blacklist[index]);
                  },
                ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '黑名单为空',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '您可以将不想联系的人添加到黑名单',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildBlacklistItem(Map<String, dynamic> user) {
    return Dismissible(
      key: Key(user['name']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _blacklist.remove(user);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user['name']} 已从黑名单中移除'),
            action: SnackBarAction(
              label: '撤销',
              onPressed: () {
                setState(() {
                  _blacklist.add(user);
                });
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                user['avatar'] != null ? AssetImage(user['avatar']) : null,
            child:
                user['avatar'] == null
                    ? Text(
                      user['name'][0],
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
          title: Text(user['name']),
          subtitle: Text(
            '拉黑时间: ${user['blockTime']}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: TextButton(
            onPressed: () {
              setState(() {
                _blacklist.remove(user);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user['name']} 已从黑名单中移除')),
              );
            },
            child: const Text('移除'),
          ),
        ),
      ),
    );
  }
}
