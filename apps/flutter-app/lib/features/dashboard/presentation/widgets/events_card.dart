import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/molecules/app_card.dart';
import '../../domain/dashboard_models.dart';

class EventsCard extends StatelessWidget {
  const EventsCard({super.key, required this.events});

  final List<EventItem> events;

  String _formatDate(DateTime date) {
    final months = [
      'jan.',
      'fév.',
      'mar.',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sep.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.calendar,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s2),
              Text('Prochains événements', style: AppTypography.subheading),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          if (events.isEmpty)
            Text(
              'Aucun événement à venir',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            )
          else
            ...events.map(
                (event) => _EventRow(event: event, formatDate: _formatDate)),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.formatDate});

  final EventItem event;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Text(event.title, style: AppTypography.bodyMedium),
          ),
          Text(
            formatDate(event.date),
            style: AppTypography.small,
          ),
        ],
      ),
    );
  }
}
