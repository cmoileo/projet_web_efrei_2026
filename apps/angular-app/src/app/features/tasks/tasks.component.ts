import { ChangeDetectionStrategy, Component } from '@angular/core';
import { LucideAngularModule, CheckSquare } from 'lucide-angular';

@Component({
  selector: 'app-tasks',
  standalone: true,
  imports: [LucideAngularModule],
  templateUrl: './tasks.component.html',
  styleUrl: './tasks.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TasksComponent {
  protected readonly CheckSquareIcon = CheckSquare;
}
