/**
 * @component BadgeComponent
 * @description Badge de statut pour les tâches. Affiche le label et la couleur
 * correspondant au statut passé en entrée.
 *
 * @example
 * <app-badge status="in_progress" />
 * <app-badge status="done" />
 */
import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import { TASK_STATUS_LABELS, type TaskStatus } from '../../ui.types';

@Component({
  selector: 'app-badge',
  standalone: true,
  templateUrl: './badge.component.html',
  styleUrl: './badge.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BadgeComponent {
  /** Statut à afficher : 'todo' | 'in_progress' | 'done' | 'late' */
  status = input.required<TaskStatus>();

  /** Libellé francisé correspondant au statut */
  protected label = computed(() => TASK_STATUS_LABELS[this.status()]);
}
