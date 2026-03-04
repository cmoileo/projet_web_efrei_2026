import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { Router } from '@angular/router';
import { FullCalendarModule } from '@fullcalendar/angular';
import type { CalendarOptions, EventClickArg } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';
import frLocale from '@fullcalendar/core/locales/fr';
import { LucideAngularModule, Plus } from 'lucide-angular';
import { AuthService } from '../../../core/services/auth.service';
import { EventService } from '../services/event.service';
import { BtnComponent } from '../../../shared/ui/atoms/btn/btn.component';
import { EVENT_TYPE_COLORS } from '../models/event.model';
import type { CalendarEvent } from '../models/event.model';

@Component({
  selector: 'app-calendar-page',
  standalone: true,
  imports: [FullCalendarModule, LucideAngularModule, BtnComponent],
  templateUrl: './calendar-page.component.html',
  styleUrl: './calendar-page.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CalendarPageComponent implements OnInit {
  private readonly eventService = inject(EventService);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  protected readonly PlusIcon = Plus;
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly events = signal<CalendarEvent[]>([]);
  protected readonly role = () => this.authService.currentUser()?.role;

  protected readonly calendarOptions = signal<CalendarOptions>({
    plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin],
    initialView: 'dayGridMonth',
    locale: frLocale,
    headerToolbar: {
      left: 'prev,next today',
      center: 'title',
      right: 'dayGridMonth,timeGridWeek,timeGridDay',
    },
    events: [],
    eventClick: (info: EventClickArg) => {
      this.router.navigate(['/calendar', info.event.id]);
    },
    height: 'auto',
  });

  async ngOnInit(): Promise<void> {
    try {
      const user = this.authService.currentUser()!;
      const events = user.role === 'volunteer'
        ? await this.eventService.getEventsByVolunteer(user.uid)
        : await this.eventService.getEventsByStudent(user.uid);
      this.events.set(events);
      this.calendarOptions.update((opts) => ({
        ...opts,
        events: events.map((e) => ({
          id: e.id,
          title: e.title,
          start: e.date.toISOString(),
          backgroundColor: EVENT_TYPE_COLORS[e.type],
          borderColor: EVENT_TYPE_COLORS[e.type],
        })),
      }));
    } catch {
      this.error.set('Impossible de charger les événements.');
    } finally {
      this.loading.set(false);
    }
  }

  protected navigateToNew(): void {
    this.router.navigate(['/calendar/new']);
  }
}
