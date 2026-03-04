import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import type { EventType } from '../../models/event.model';

@Component({
  selector: 'app-event-type-badge',
  standalone: true,
  template: `<span class="event-type-badge" [attr.data-type]="type()">{{ label() }}</span>`,
  styleUrl: './event-type-badge.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class EventTypeBadgeComponent {
  type = input.required<EventType>();

  protected label(): string {
    const labels: Record<EventType, string> = {
      cours: 'Cours',
      reunion: 'Réunion',
      deadline: 'Deadline',
    };
    return labels[this.type()];
  }
}
