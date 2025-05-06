import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedCategoryIndex = 0;
  int _userPoints = 1000; // 模拟用户点数

  final List<String> _categories = [
    '全部',
    '头像',
    '背景音乐',
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('商城'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // 点数显示
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_userPoints',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategorySelector(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildPointsPackages(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(_selectedCategoryIndex == 0 ? '热门商品' :
                                    _selectedCategoryIndex == 1 ? '官方头像' : '背景音乐'),
                  const SizedBox(height: 16),
                  _selectedCategoryIndex == 0 ? _buildAllItems() :
                  _selectedCategoryIndex == 1 ? _buildAvatarItems() : _buildMusicItems(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 构建点数包
  Widget _buildPointsPackages() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '点数充值',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildPointsPackage(100, 6, isDarkMode),
            const SizedBox(width: 12),
            _buildPointsPackage(500, 30, isDarkMode),
            const SizedBox(width: 12),
            _buildPointsPackage(1000, 50, isDarkMode),
          ],
        ),
      ],
    );
  }

  // 构建单个点数包
  Widget _buildPointsPackage(int points, double price, bool isDarkMode) {
    return Expanded(
      child: InkWell(
        onTap: () => _showPurchaseDialog(points, price),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF06C755).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$points',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '¥$price',
                style: TextStyle(
                  color: const Color(0xFF06C755),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('查看全部'),
        ),
      ],
    );
  }

  // 构建热销商品
  Widget _buildHotItems() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // 组合所有商品并按销量排序
    final List<Map<String, dynamic>> allItems = [];

    // 添加头像商品
    final avatarItems = [
      {
        'name': '官方头像包1',
        'description': '包含5个精美头像',
        'icon': Icons.face,
        'color': Colors.blue,
        'points': 50,
        'sales': 1280,
        'rating': 4.8,
        'type': '头像',
      },
      {
        'name': '官方头像包2',
        'description': '包含5个动态头像',
        'icon': Icons.face_retouching_natural,
        'color': Colors.purple,
        'points': 80,
        'sales': 960,
        'rating': 4.7,
        'type': '头像',
      },
      {
        'name': '定制头像',
        'description': '根据您的喜好定制',
        'icon': Icons.face_retouching_natural,
        'color': Colors.orange,
        'points': 120,
        'sales': 560,
        'rating': 4.9,
        'type': '头像',
      },
      {
        'name': '动物头像包',
        'description': '可爱的动物头像',
        'icon': Icons.pets,
        'color': Colors.green,
        'points': 60,
        'sales': 820,
        'rating': 4.6,
        'type': '头像',
      },
    ];

    // 添加音乐商品
    final musicItems = [
      {
        'name': '轻松爵士',
        'description': '舒适的爵士乐背景音乐',
        'icon': Icons.music_note,
        'color': Colors.indigo,
        'points': 30,
        'sales': 980,
        'rating': 4.5,
        'duration': '3:45',
        'type': '音乐',
      },
      {
        'name': '自然声音',
        'description': '大自然的放松音效',
        'icon': Icons.nature,
        'color': Colors.green,
        'points': 25,
        'sales': 1250,
        'rating': 4.7,
        'duration': '5:20',
        'type': '音乐',
      },
      {
        'name': '电子节拍',
        'description': '现代电子音乐',
        'icon': Icons.equalizer,
        'color': Colors.deepPurple,
        'points': 35,
        'sales': 760,
        'rating': 4.4,
        'duration': '4:10',
        'type': '音乐',
      },
      {
        'name': '钢琴曲集',
        'description': '优美的钢琴独奏',
        'icon': Icons.piano,
        'color': Colors.brown,
        'points': 40,
        'sales': 890,
        'rating': 4.8,
        'duration': '6:30',
        'type': '音乐',
      },
    ];

    allItems.addAll(avatarItems);
    allItems.addAll(musicItems);

    // 按销量排序
    allItems.sort((a, b) => (b['sales'] as int).compareTo(a['sales'] as int));

    // 只取前4个
    final hotItems = allItems.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.red, size: 20),
            const SizedBox(width: 4),
            const Text(
              '热销商品',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: hotItems.length,
          itemBuilder: (context, index) {
            final item = hotItems[index];
            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () => _showItemDetailPanel(item),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      // 图标
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(isDarkMode ? 0.3 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            item['icon'] as IconData,
                            size: 24,
                            color: item['color'] as Color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.shopping_bag, size: 10, color: Colors.grey[600]),
                                const SizedBox(width: 2),
                                Text(
                                  '${item['sales']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 10),
                                const SizedBox(width: 2),
                                Text(
                                  '${item['points']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Color(0xFF06C755),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 构建所有商品
  Widget _buildAllItems() {
    return Column(
      children: [
        _buildHotItems(),
        const SizedBox(height: 24),
        _buildSectionTitle('官方头像'),
        const SizedBox(height: 12),
        _buildAvatarItems(),
        const SizedBox(height: 24),
        _buildSectionTitle('背景音乐'),
        const SizedBox(height: 12),
        _buildMusicItems(),
      ],
    );
  }

  // 构建头像项目
  Widget _buildAvatarItems({bool showAll = false}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final avatarItems = [
      {
        'name': '官方头像包1',
        'description': '包含5个精美头像',
        'icon': Icons.face,
        'color': Colors.blue,
        'points': 50,
        'sales': 1280,
        'rating': 4.8,
      },
      {
        'name': '官方头像包2',
        'description': '包含5个动态头像',
        'icon': Icons.face_retouching_natural,
        'color': Colors.purple,
        'points': 80,
        'sales': 960,
        'rating': 4.7,
      },
      {
        'name': '定制头像',
        'description': '根据您的喜好定制',
        'icon': Icons.face_retouching_natural,
        'color': Colors.orange,
        'points': 120,
        'sales': 560,
        'rating': 4.9,
      },
      {
        'name': '动物头像包',
        'description': '可爱的动物头像',
        'icon': Icons.pets,
        'color': Colors.green,
        'points': 60,
        'sales': 820,
        'rating': 4.6,
      },
    ];

    final displayItems = showAll ? avatarItems.take(2).toList() : avatarItems;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final item = displayItems[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () => _showItemDetailPanel(item),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头像图标
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(isDarkMode ? 0.3 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        item['icon'] as IconData,
                        size: 30,
                        color: item['color'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 名称
                  Text(
                    item['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // 描述
                  Text(
                    item['description'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // 价格
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${item['points']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF06C755),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建背景音乐项目
  Widget _buildMusicItems({bool showAll = false}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final musicItems = [
      {
        'name': '轻松爵士',
        'description': '舒适的爵士乐背景音乐',
        'icon': Icons.music_note,
        'color': Colors.indigo,
        'points': 30,
        'sales': 980,
        'rating': 4.5,
        'duration': '3:45',
      },
      {
        'name': '自然声音',
        'description': '大自然的放松音效',
        'icon': Icons.nature,
        'color': Colors.green,
        'points': 25,
        'sales': 1250,
        'rating': 4.7,
        'duration': '5:20',
      },
      {
        'name': '电子节拍',
        'description': '现代电子音乐',
        'icon': Icons.equalizer,
        'color': Colors.deepPurple,
        'points': 35,
        'sales': 760,
        'rating': 4.4,
        'duration': '4:10',
      },
      {
        'name': '钢琴曲集',
        'description': '优美的钢琴独奏',
        'icon': Icons.piano,
        'color': Colors.brown,
        'points': 40,
        'sales': 890,
        'rating': 4.8,
        'duration': '6:30',
      },
    ];

    final displayItems = showAll ? musicItems.take(2).toList() : musicItems;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final item = displayItems[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () => _showItemDetailPanel(item),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 音乐图标
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(isDarkMode ? 0.3 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        item['icon'] as IconData,
                        size: 30,
                        color: item['color'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 名称
                  Text(
                    item['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // 描述
                  Text(
                    item['description'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // 价格
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${item['points']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF06C755),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 显示购买点数对话框
  void _showPurchaseDialog(int points, double price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('购买点数'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('您确定要购买 $points 点数吗？'),
            const SizedBox(height: 8),
            Text(
              '价格: ¥$price',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF06C755),
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
              setState(() {
                _userPoints += points;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('成功购买 $points 点数！'),
                  backgroundColor: const Color(0xFF06C755),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06C755),
            ),
            child: const Text('购买'),
          ),
        ],
      ),
    );
  }

  // 显示商品详情面板
  void _showItemDetailPanel(Map<String, dynamic> item) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final itemName = item['name'] as String;
    final pointsCost = item['points'] as int;
    final sales = item['sales'] as int;
    final rating = item['rating'] as double;
    final itemType = item['type'] as String;

    // 创建评论数据
    final comments = [
      {'user': '用户1', 'comment': '非常好用，很喜欢！', 'rating': 5.0, 'time': '2天前'},
      {'user': '用户2', 'comment': '质量不错，值得购买。', 'rating': 4.5, 'time': '1周前'},
      {'user': '用户3', 'comment': '一般般，还可以接受。', 'rating': 3.5, 'time': '2周前'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  // 背景虚化效果
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),

                  // 内容
                  Column(
                    children: [
                      // 顶部拖动条
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // 标题栏
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            Text(
                              '商品详情',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),

                      // 商品内容
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // 商品头部
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 图标
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: (item['color'] as Color).withOpacity(isDarkMode ? 0.3 : 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      item['icon'] as IconData,
                                      size: 40,
                                      color: item['color'] as Color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // 信息
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        itemName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['description'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // 评分和销量
                                      Row(
                                        children: [
                                          // 评分
                                          Row(
                                            children: [
                                              const Icon(Icons.star, color: Colors.amber, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                rating.toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 16),
                                          // 销量
                                          Row(
                                            children: [
                                              Icon(Icons.shopping_bag, size: 16, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Text(
                                                '销量: $sales',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // 价格信息
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '价格',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$pointsCost',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF06C755),
                                        ),
                                      ),
                                      const Text(' 点数', style: TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 商品详情
                            const Text(
                              '商品详情',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailItem('商品类型', itemType),
                                  const Divider(),
                                  _buildDetailItem('上架时间', '2023-05-15'),
                                  const Divider(),
                                  if (itemType == '音乐') ...[
                                    _buildDetailItem('时长', item['duration'] as String),
                                    const Divider(),
                                  ],
                                  _buildDetailItem('适用范围', '所有聊天场景'),
                                  const Divider(),
                                  _buildDetailItem('使用方式', itemType == '头像' ? '在个人设置中更换头像' : '在聊天设置中选择背景音乐'),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 用户评价
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '用户评价',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '共${comments.length}条',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...comments.map((comment) => _buildCommentItem(comment)),
                          ],
                        ),
                      ),

                      // 底部购买按钮
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.black : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // 当前点数
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '当前点数',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$_userPoints',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: _userPoints >= pointsCost ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // 购买按钮
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _userPoints >= pointsCost ? () {
                                  setState(() {
                                    _userPoints -= pointsCost;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('成功购买 $itemName！'),
                                      backgroundColor: const Color(0xFF06C755),
                                    ),
                                  );
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF06C755),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  '立即购买',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // 构建详情项
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 构建评论项
  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息和评分
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comment['user'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (index) => Icon(
                      index < (comment['rating'] as double) ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 评论内容
          Text(
            comment['comment'] as String,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          // 评论时间
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              comment['time'] as String,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
