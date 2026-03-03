import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import { DatePipe } from '@angular/common';
import { LucideAngularModule, Calendar } from 'lucide-angular';
import { CardComponent } from '../../../../shared/ui/molecules/card/card.component';
import type { EventItem } from '../../models/dashboard.models';

@Component({
  selector: 'app-events-card',
  standalone: true,
  imports: [CardComponent, LucideAngularModule, DatePipe],
  templateUrl: './events-card.component.html',
  styleUrl: './events-card.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class EventsCardComponent {
  events = input<EventItem[]>([]);

  protected readonly CalendarIcon = Calendar;

  protected readonly hasEvents = computed(() => this.events().length > 0);
}
