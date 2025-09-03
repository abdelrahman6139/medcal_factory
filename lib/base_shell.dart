import 'package:flutter/material.dart';
import 'package:pharma_app/features/cart/screens/cart_screen.dart';
import 'features/product/presentation/screens/shop_screen.dart';
import 'features/home/screens/home_page.dart';
import 'widgets/base_layout.dart';

class BaseShell extends StatefulWidget {
  /// تقدر تمرّرهم يدويًا لو استخدمت BaseShell(...) مباشرة
  final int? initialIndex; // 0=Home, 1=Orders, 2=Shop, 3=About, 4=Cart
  final int? shopInitialTab; // 0 All, 1 New, 2 On Sale, 3 Low Stock, 4 Popular

  const BaseShell({super.key, this.initialIndex, this.shopInitialTab});

  @override
  State<BaseShell> createState() => _BaseShellState();
}

class _BaseShellState extends State<BaseShell> {
  int _selectedIndex = 0;
  int _shopInitialTab = 0;
  bool _restoredFromRoute = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restoredFromRoute) return;

    // 1) قيم جايه من الـ constructor (لو استدعيتها مباشرة)
    _selectedIndex = widget.initialIndex ?? _selectedIndex;
    _shopInitialTab = widget.shopInitialTab ?? _shopInitialTab;

    // 2) قيم جايه من Navigator.pushReplacementNamed(..., arguments: {...})
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _selectedIndex = (args['index'] as int?) ?? _selectedIndex;
      _shopInitialTab = (args['shopTab'] as int?) ?? _shopInitialTab;
    }

    // أمان للسليم
    _selectedIndex = _selectedIndex.clamp(0, 4);
    _shopInitialTab = _shopInitialTab.clamp(0, 4);

    _restoredFromRoute = true;
  }

  void _onNavTap(int index) => setState(() => _selectedIndex = index);

  List<Widget> get _pages => [
    BaseLayout(
      selectedIndex: _selectedIndex,
      onNavTap: _onNavTap,
      child: const HomePage(),
    ),
    BaseLayout(
      selectedIndex: _selectedIndex,
      onNavTap: _onNavTap,
      child: const _PlaceholderPage(title: "Orders"),
    ),
    BaseLayout(
      selectedIndex: _selectedIndex,
      onNavTap: _onNavTap,
      child: ShopScreen(initialTab: _shopInitialTab), // 👈 مهم
    ),
    BaseLayout(
      selectedIndex: _selectedIndex,
      onNavTap: _onNavTap,
      child: const _PlaceholderPage(title: "About"),
    ),
    BaseLayout(
      selectedIndex: _selectedIndex,
      onNavTap: _onNavTap,
      child: const CartScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _pages[_selectedIndex];
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("$title Page Coming Soon...")),
    );
  }
}
