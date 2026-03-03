import { ChangeDetectionStrategy, Component } from '@angular/core';
import { LucideAngularModule, Calendar } from 'lucide-angular';

@Component({
  selector: 'app-calendar',
  standalone: true,
  imports: [LucideAngularModule],
  templateUrl: './calendar.component.html',
  styleUrl: './calendar.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CalendarComponent {
  protected readonly CalendarIcon = Calendar;
}
