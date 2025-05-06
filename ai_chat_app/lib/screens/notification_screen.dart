import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
        title: const Text('通知'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('官方通告'),
            _buildNotificationItem(
              title: '欢迎使用AI聊天助手',
              content: '感谢您使用我们的应用，我们将为您提供最优质的AI聊天体验。',
              time: '今天',
              isOfficial: true,
            ),
            _buildNotificationItem(
              title: '新功能上线：多模型支持',
              content: '现在您可以在聊天中选择不同的AI模型，体验不同的对话风格。',
              time: '昨天',
              isOfficial: true,
            ),
            _buildNotificationItem(
              title: '系统维护通知',
              content: '我们将于本周六凌晨2:00-4:00进行系统维护，期间服务可能会有短暂中断。',
              time: '3天前',
              isOfficial: true,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('活动通知'),
            _buildNotificationItem(
              title: '新用户福利',
              content: '新用户注册即送500点数，可用于AI对话。',
              time: '1周前',
              isOfficial: false,
            ),
            _buildNotificationItem(
              title: '限时优惠',
              content: '充值点数享受8折优惠，活动截止到本月底。',
              time: '2周前',
              isOfficial: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String content,
    required String time,
    required bool isOfficial,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOfficial 
                        ? const Color(0xFF06C755).withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isOfficial ? '官方' : '活动',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOfficial ? const Color(0xFF06C755) : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
