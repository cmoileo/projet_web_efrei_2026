import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { DatePipe } from '@angular/common';
import type { Message } from '../../models/message.model';
import type { User } from '../../../../core/models/user.model';

@Component({
  selector: 'app-message-bubble',
  standalone: true,
  imports: [DatePipe],
  templateUrl: './message-bubble.component.html',
  styleUrl: './message-bubble.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MessageBubbleComponent {
  @Input({ required: true }) message!: Message;
  @Input({ required: true }) isOwn!: boolean;
  @Input({ required: true }) showAvatar!: boolean;
  @Input({ required: true }) allMembers!: string[];
  @Input({ required: true }) users!: Map<string, User>;

  protected get senderName(): string {
    const user = this.users.get(this.message.senderId);
    return user ? user.firstName : '…';
  }

  protected get senderInitials(): string {
    const user = this.users.get(this.message.senderId);
    if (!user) return '?';
    return (user.firstName[0] + user.lastName[0]).toUpperCase();
  }

  protected get isReadByAll(): boolean {
    return this.allMembers.every((uid) => this.message.readBy.includes(uid));
  }
}
