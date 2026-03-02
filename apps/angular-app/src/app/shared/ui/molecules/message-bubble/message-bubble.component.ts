/**
 * @component MessageBubbleComponent
 * @description Bulle de message pour l'interface de chat.
 * Alignée à droite pour l'utilisateur courant, à gauche pour les autres.
 *
 * @example
 * <app-message-bubble
 *   side="me"
 *   message="Bonjour ! Comment puis-je vous aider ?"
 *   [sentAt]="message.sentAt"
 * />
 */
import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import { DatePipe } from '@angular/common';
import type { MessageSide } from '../../ui.types';

@Component({
  selector: 'app-message-bubble',
  standalone: true,
  imports: [DatePipe],
  templateUrl: './message-bubble.component.html',
  styleUrl: './message-bubble.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MessageBubbleComponent {
  /** 'me' = aligné à droite (l'utilisateur courant), 'other' = à gauche */
  side = input.required<MessageSide>();
  /** Contenu textuel du message */
  message = input.required<string>();
  /** Date d'envoi (Date ou timestamp ISO) */
  sentAt = input<Date | string | null>(null);
  /** Nom de l'expéditeur (affiché pour side='other') */
  senderName = input<string | undefined>(undefined);

  protected isMe = computed(() => this.side() === 'me');
}
