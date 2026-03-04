import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { DatePipe } from '@angular/common';
import type { CalendarEvent } from '../../models/event.model';
import { EventTypeBadgeComponent } from '../event-type-badge/event-type-badge.component';

@Component({
  selector: 'app-event-card',
  standalone: true,
  imports: [DatePipe, EventTypeBadgeComponent],
  templateUrl: './event-card.component.html',
  styleUrl: './event-card.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class EventCardComponent {
  event = input.required<CalendarEvent>();
}
