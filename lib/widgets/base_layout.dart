import 'package:flutter/material.dart';
import 'package:pharma_app/features/auth/presentation/screens/profile_page.dart';
import '../constants/colors.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final int? selectedIndex;
  final Function(int)? onNavTap;
  final PreferredSizeWidget? customAppBar;
  final bool showBottomNav;

  const BaseLayout({
    super.key,
    required this.child,
    this.selectedIndex,
    this.onNavTap,
    this.customAppBar,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    // لو الكيبورد ظاهر، قلّل الـ bottom padding
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final double bottomPad = keyboardOpen ? 16 : (showBottomNav ? 80 : 16);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar:
          customAppBar ??
          AppBar(
            backgroundColor: AppColors.oceanDark,
            elevation: 0,
            automaticallyImplyLeading: false,
            foregroundColor: Colors.white, // يطبّق على أيقونات الأكشن
            title: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              child: Row(
                children: const [
                  SizedBox(width: 12),
                  Icon(Icons.person_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Azza Mohamed',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {
                  // TODO: notifications page
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Sign Out',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, bottomPad),
          // كل Screen تعمل السّكرول بنفسها (ListView / CustomScrollView)
          child: child,
        ),
      ),

      bottomNavigationBar:
          showBottomNav && selectedIndex != null && onNavTap != null
              ? BottomNavigationBar(
                currentIndex: selectedIndex!,
                onTap: onNavTap!,
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.primary, // غامق ثابت
                selectedItemColor: Colors.white, // المختار أبيض
                // لو SDK بيدعم withValues استخدمه، وإلا سيب withOpacity
                unselectedItemColor:
                // Colors.white.withValues(alpha: 0.6), // بديل جديد (لو متاح)
                Colors.white.withOpacity(0.6),
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.storefront),
                    label: 'Shop',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.info_outline),
                    label: 'About',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart),
                    label: 'Cart',
                  ),
                ],
              )
              : null,
    );
  }
}
