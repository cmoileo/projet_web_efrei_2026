import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import { LucideAngularModule, CheckSquare } from 'lucide-angular';
import { CardComponent } from '../../../../shared/ui/molecules/card/card.component';
import type { TaskSummary } from '../../models/dashboard.models';

@Component({
  selector: 'app-task-summary-card',
  standalone: true,
  imports: [CardComponent, LucideAngularModule],
  templateUrl: './task-summary-card.component.html',
  styleUrl: './task-summary-card.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TaskSummaryCardComponent {
  summary = input<TaskSummary | null>(null);

  protected readonly CheckSquareIcon = CheckSquare;

  protected readonly hasTasks = computed(() => (this.summary()?.total ?? 0) > 0);
}
