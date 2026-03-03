import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { DatePipe } from '@angular/common';
import { LucideAngularModule, Users } from 'lucide-angular';
import type { Conversation } from '../../models/conversation.model';

@Component({
  selector: 'app-conversation-tile',
  standalone: true,
  imports: [DatePipe, LucideAngularModule],
  templateUrl: './conversation-tile.component.html',
  styleUrl: './conversation-tile.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ConversationTileComponent {
  @Input({ required: true }) conversation!: Conversation;
  @Input({ required: true }) displayName!: string;

  protected readonly UsersIcon = Users;

  protected get initials(): string {
    const words = this.displayName.trim().split(/\s+/);
    if (words.length >= 2) return (words[0][0] + words[1][0]).toUpperCase();
    return this.displayName.slice(0, 2).toUpperCase();
  }
}
