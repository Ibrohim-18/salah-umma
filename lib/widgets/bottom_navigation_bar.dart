import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Signature floating navigation bar with smooth active-pill transitions.
class BottomNavigationBarWidget extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final double scale;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.scale,
  });

  @override
  State<BottomNavigationBarWidget> createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {

  final List<_NavItem> _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home', AppTheme.accentGold),
    _NavItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Stats', Color(0xFF10B981)),
    _NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, 'TASBIH', Color(0xFFF59E0B)),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'MY', Color(0xFF8B5CF6)),
  ];

  @override
  Widget build(BuildContext context) {
    final navHeight = 76.0 * widget.scale;
    final radius = 30.0 * widget.scale;

    return Padding(
      padding: EdgeInsets.fromLTRB(16 * widget.scale, 0, 16 * widget.scale, 12 * widget.scale),
      child: Container(
        height: navHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGold.withAlpha(26),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.black.withAlpha(76),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(22),
                    Colors.white.withAlpha(8),
                  ],
                ),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: Colors.white.withAlpha(26),
                  width: 1.2,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: _items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = widget.currentIndex == index;
                      return Expanded(
                        child: _buildNavItem(item, isSelected, index),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool isSelected, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24 * widget.scale),
        splashColor: item.color.withAlpha(28),
        highlightColor: Colors.transparent,
      onTap: () => widget.onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 10 * widget.scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                scale: isSelected ? 1.08 : 1.0,
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: isSelected ? item.color : Colors.white.withAlpha(120),
                  size: (isSelected ? 24 : 22) * widget.scale,
                ),
              ),
              SizedBox(height: 5 * widget.scale),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: 10 * widget.scale,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                  color: isSelected ? Colors.white : Colors.white.withAlpha(85),
                ),
                child: Text(item.label, maxLines: 1, overflow: TextOverflow.fade),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  _NavItem(this.icon, this.activeIcon, this.label, this.color);
}
