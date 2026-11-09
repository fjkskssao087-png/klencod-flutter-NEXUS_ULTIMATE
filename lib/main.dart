import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const NexusApp());

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NEXUS',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00E5FF),
        scaffoldBackgroundColor: const Color(0xFF09090E),
        fontFamily: GoogleFonts.tajawal().fontFamily,
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}

// ================== نماذج البيانات ==================
class Product {
  final String name;
  final double price;
  final IconData icon;
  final Color color;
  Product(this.name, this.price, this.icon, this.color);
}

// ================== الشاشة الرئيسية (Root) ==================
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isSplashDone = false;
  List<Product> _cart = [];
  String _searchQuery = "";
  
  // محرك الحركة للخلفية
  late AnimationController _bgController;

  final List<Product> products = [
    Product('ساعة ذكية', 299.0, Icons.watch, const Color(0xFF00E5FF)),
    Product('سماعات لاسلكية', 199.0, Icons.headphones, const Color(0xFF9D4EDD)),
    Product('نظارة شمسية', 149.0, Icons.remove_red_eye, const Color(0xFFF093FB)),
    Product('هاتف ذكي', 899.0, Icons.phone_android, const Color(0xFF30D158)),
    Product('حاسوب محمول', 1200.0, Icons.laptop, const Color(0xFFFFB300)),
    Product('كاميرا احترافية', 750.0, Icons.camera_alt, const Color(0xFFFF3B30)),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isSplashDone = true);
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _addToCart(Product p) {
    setState(() => _cart.add(p));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${p.name} إلى السلة!', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: p.color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  double get _cartTotal => _cart.fold(0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    if (!_isSplashDone) return _buildSplash();

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeTab(),
                _buildStoreTab(),
                _buildCartTab(),
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // 1. شاشة الترحيب
  Widget _buildSplash() {
    return Scaffold(
      backgroundColor: const Color(0xFF09090E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOutExpo,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00E5FF), Color(0xFF9D4EDD), Color(0xFFF093FB)],
                      ).createShader(bounds),
                      child: const Text('NEXUS', style: TextStyle(fontSize: 70, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 8)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Color(0xFF00E5FF)),
          ],
        ),
      ),
    );
  }

  // 2. الخلفية المتحركة
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: const Color(0xFF09090E)),
            Positioned(
              top: -100 + (_bgController.value * 100),
              left: -50 + (_bgController.value * 50),
              child: _orb(const Color(0xFF00E5FF), 300),
            ),
            Positioned(
              bottom: -50 + (_bgController.value * 100),
              right: -50 + (_bgController.value * 50),
              child: _orb(const Color(0xFF9D4EDD), 350),
            ),
            Positioned(
              top: 300 - (_bgController.value * 50),
              left: 150 + (_bgController.value * 50),
              child: _orb(const Color(0xFFF093FB), 200),
            ),
          ],
        );
      },
    );
  }

  Widget _orb(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withOpacity(0.3), Colors.transparent]),
      ),
    );
  }

  // 3. شريط التنقل السفلي
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24).withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navItem(0, Icons.home_rounded, 'الرئيسية'),
                _navItem(1, Icons.storefront_rounded, 'المتجر'),
                _navItem(2, Icons.shopping_bag_rounded, 'السلة', badge: _cart.length),
                _navItem(3, Icons.person_rounded, 'حسابي'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, {int badge = 0}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E5FF).withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Icon(icon, color: isSelected ? const Color(0xFF00E5FF) : Colors.white54, size: 26),
                if (badge > 0)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('$badge', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 14)),
            ]
          ],
        ),
      ),
    );
  }

  // 4. الشاشة الرئيسية (Home)
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('مرحباً بك مجدداً', style: TextStyle(fontSize: 18, color: Colors.white54)),
          const Text('عالم الابتكار', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 30),
          
          // شريط بحث تفاعلي
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'ابحث عن منتج...',
                hintStyle: TextStyle(color: Colors.white38),
                prefixIcon: Icon(Icons.search, color: Color(0xFF00E5FF)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _currentIndex = 1; // الانتقال للمتجر عند البحث
                });
              },
            ),
          ),
          const SizedBox(height: 30),

          // بانر إعلاني
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF9D4EDD)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('خصم 50%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('على جميع الإلكترونيات', style: TextStyle(fontSize: 18, color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          const Text('الأكثر مبيعاً', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return GestureDetector(
                  onTap: () => _addToCart(p),
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p.icon, size: 50, color: p.color),
                        const SizedBox(height: 10),
                        Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text('\$${p.price}', style: TextStyle(color: p.color, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // 5. شاشة المتجر (Store) - تفاعلية مع البحث
  Widget _buildStoreTab() {
    // تصفية المنتجات بناء على البحث
    final displayProducts = products.where((p) => p.name.contains(_searchQuery)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('المتجر', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 20),
          
          if (displayProducts.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('لا توجد نتائج', style: TextStyle(color: Colors.white54)))),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: displayProducts.map((p) {
              return GestureDetector(
                onTap: () => _addToCart(p),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 64) / 2, // عرضين في الشاشة
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        decoration: BoxDecoration(color: p.color.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(p.icon, size: 60, color: p.color),
                      ),
                      const SizedBox(height: 16),
                      Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${p.price}', style: TextStyle(color: p.color, fontSize: 20, fontWeight: FontWeight.w900)),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: p.color, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // 6. شاشة السلة (Cart)
  Widget _buildCartTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('سلة المشتريات', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 20),
          
          if (_cart.isEmpty) 
            const Center(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Icon(Icons.remove_shopping_cart, size: 80, color: Colors.white24),
                  SizedBox(height: 20),
                  Text('السلة فارغة', style: TextStyle(fontSize: 20, color: Colors.white54)),
                ],
              ),
            )
          else ...[
            ..._cart.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(p.icon, color: p.color, size: 40),
                  const SizedBox(width: 16),
                  Expanded(child: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                  Text('\$${p.price}', style: TextStyle(color: p.color, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            )),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF00E5FF).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الإجمالي', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('\$${_cartTotal.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _cart.clear());
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إتمام الشراء بنجاح!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D4EDD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('إتمام الشراء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ]
        ],
      ),
    );
  }

  // 7. شاشة الحساب (Profile)
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120, height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF9D4EDD)]),
            ),
            child: const Icon(Icons.person, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text('مستخدم NEXUS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text('user@nexus.com', style: TextStyle(fontSize: 16, color: Colors.white54)),
          const SizedBox(height: 40),
          
          Row(
            children: [
              _statCard('المشتريات', '${_cart.length}'),
              const SizedBox(width: 16),
              _statCard('النقاط', '450'),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الإعدادات', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(Icons.settings, color: Colors.white54),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _statCard(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(val, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF00E5FF))),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}