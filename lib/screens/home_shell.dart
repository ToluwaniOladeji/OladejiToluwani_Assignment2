import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'shared/profile_screen.dart';
import 'shared/report_list_screen.dart';
import 'staff/staff_dashboard_screen.dart';
import 'student/home_screen.dart';
import 'student/submit_report_screen.dart';

/// Navigation shell. Students get a docked "report" button in the centre of
/// the bar; staff get a plain three-tab bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.isStaff});
  final bool isStaff;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) =>
      widget.isStaff ? _staff(context) : _student(context);

  // ---------------------------------------------------------------- staff
  Widget _staff(BuildContext context) {
    final pages = <Widget>[
      const StaffDashboardScreen(),
      const ReportListScreen(
          title: 'All reports', subtitle: 'Review and update incidents'),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Reports'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- student
  Widget _student(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onSeeAll: () => _go(1), onSeeMine: () => _go(2)),
      const ReportListScreen(
          title: 'Campus reports', subtitle: 'What students have flagged'),
      const ReportListScreen(
          title: 'My reports',
          subtitle: 'Follow your reports until they are fixed',
          onlyMine: true),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        tooltip: 'Report an issue',
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SubmitReportScreen())),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 68,
        padding: EdgeInsets.zero,
        child: Row(children: [
          _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home',
              _index == 0, () => _go(0)),
          _NavItem(Icons.public_outlined, Icons.public, 'Campus',
              _index == 1, () => _go(1)),
          const SizedBox(width: 64),
          _NavItem(Icons.inventory_2_outlined, Icons.inventory_2, 'Mine',
              _index == 2, () => _go(2)),
          _NavItem(Icons.person_outline, Icons.person, 'Profile',
              _index == 3, () => _go(3)),
        ]),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(this.icon, this.activeIcon, this.label, this.selected, this.onTap);
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}