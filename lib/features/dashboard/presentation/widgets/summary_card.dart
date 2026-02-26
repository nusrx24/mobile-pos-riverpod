import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/gradient_card.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.colors,
    this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final List<Color> colors;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      colors: colors,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }
}

class SummaryCardFromAmount extends StatelessWidget {
  const SummaryCardFromAmount({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.colors,
    this.subtitle,
  });

  final String title;
  final double amount;
  final IconData icon;
  final List<Color> colors;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: title,
      value: AppFormatters.currency(amount),
      icon: icon,
      colors: colors,
      subtitle: subtitle,
    );
  }
}
