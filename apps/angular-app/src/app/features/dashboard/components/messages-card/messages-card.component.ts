import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import { LucideAngularModule, MessageCircle } from 'lucide-angular';
import { CardComponent } from '../../../../shared/ui/molecules/card/card.component';

@Component({
  selector: 'app-messages-card',
  standalone: true,
  imports: [CardComponent, LucideAngularModule],
  templateUrl: './messages-card.component.html',
  styleUrl: './messages-card.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MessagesCardComponent {
  unreadCount = input<number>(0);

  protected readonly MessageCircleIcon = MessageCircle;

  protected readonly hasMessages = computed(() => this.unreadCount() > 0);
}
