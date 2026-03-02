/// Molecule : MessageBubble — Learn@Home
///
/// Bulle de message pour l'interface chat. Deux modes : envoyé (moi) ou reçu (autre).
/// Conforme à la charte UI : alignement, couleurs, rayons asymétriques.
///
/// ## Paramètres
/// - [message]   : texte du message (obligatoire)
/// - [timestamp] : heure d'envoi formatée (obligatoire)
/// - [isMe]      : true = message envoyé par l'utilisateur courant
/// - [senderName]: nom de l'expéditeur (affiché uniquement si !isMe)
///
/// ## Exemple
/// ```dart
/// MessageBubble(
///   message: 'Bonjour, comment puis-je vous aider ?',
///   timestamp: '14h32',
///   isMe: false,
///   senderName: 'Marie (tutrice)',
/// )
///
/// MessageBubble(
///   message: 'J\'ai du mal avec les fractions',
///   timestamp: '14h33',
///   isMe: true,
/// )
/// ```
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Bulle de message pour le chat Learn@Home.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.senderName,
  });

  final String message;
  final String timestamp;
  final bool isMe;
  final String? senderName;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isMe
          ? 'Vous avez envoyé : $message à $timestamp'
          : '${senderName ?? 'Correspondant'} a envoyé : $message à $timestamp',
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.70,
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // ─── Nom de l'expéditeur (message reçu uniquement) ──────
              if (!isMe && senderName != null) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.s3,
                    bottom: AppSpacing.s1,
                  ),
                  child: Text(senderName!, style: AppTypography.small),
                ),
              ],

              // ─── Bulle ────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s4,
                  vertical: AppSpacing.s3,
                ),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : AppColors.background,
                  borderRadius: _borderRadius,
                ),
                child: Text(
                  message,
                  style: AppTypography.body.copyWith(
                    color: isMe ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),

              // ─── Heure ────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(
                  top: AppSpacing.s1,
                  left: isMe ? 0 : AppSpacing.s3,
                  right: isMe ? AppSpacing.s3 : 0,
                ),
                child: Text(timestamp, style: AppTypography.tiny),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rayons asymétriques conformes à la charte :
  /// Moi → radius-lg partout sauf bas-droite = radius-sm
  /// Autre → radius-lg partout sauf bas-gauche = radius-sm
  BorderRadius get _borderRadius => isMe
      ? const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(AppRadius.lg),
          bottomRight: Radius.circular(AppRadius.sm),
        )
      : const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(AppRadius.sm),
          bottomRight: Radius.circular(AppRadius.lg),
        );
}
