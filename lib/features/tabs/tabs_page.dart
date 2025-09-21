import 'package:flutter/material.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});
  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _HomeScreen(),
      const _QuestionsScreen(),
      const _ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(child: pages[_index]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 카메라 화면 이동
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.photo_camera, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// 🔻 하단바
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 64,
      notchMargin: 8,
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabItem(
            label: '질문',
            icon: Icons.forum_outlined,
            selectedIcon: Icons.forum,
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          const SizedBox(width: 56), // 카메라 공간
          _TabItem(
            label: '마이',
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black : Colors.black54;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? selectedIcon : icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// 🔻 홈 화면
class _HomeScreen extends StatefulWidget {
  const _HomeScreen();
  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  final _pageCtl = PageController(viewportFraction: 0.86);
  int _page = 0;

  final _slides = const [
    '지금 채용 중인\n공고를 골라보세요',
    'AI 면접으로\n연습을 시작해요',
    '지원 현황과\n피드백을 확인해요',
    '프로필을 채우면\n추천 정확도가 올라가요',
  ];

  @override
  void dispose() {
    _pageCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 앱바 느낌
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/logo.png', width: 20, height: 20),
              ),
              const SizedBox(width: 8),
              const Text('앱이름'),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageCtl,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _SlideCard(text: _slides[i]),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            final active = i == _page;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? Colors.black87 : Colors.black26,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SlideCard extends StatelessWidget {
  const _SlideCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE9E9EC),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

// 🔻 나머지 탭
class _QuestionsScreen extends StatelessWidget {
  const _QuestionsScreen();
  @override
  Widget build(BuildContext context) => const Center(child: Text('질문 탭 콘텐츠'));
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();
  @override
  Widget build(BuildContext context) => const Center(child: Text('마이 탭 콘텐츠'));
}
