import {
  ChangeDetectionStrategy,
  Component,
  inject,
  input,
  OnInit,
  signal,
} from '@angular/core';
import { DatePipe } from '@angular/common';
import { Router } from '@angular/router';
import { LucideAngularModule, ChevronLeft } from 'lucide-angular';
import { AuthService } from '../../../../core/services/auth.service';
import { TaskService } from '../../services/task.service';
import { ToastService } from '../../../../shared/ui/molecules/toast/toast.service';
import { BadgeComponent } from '../../../../shared/ui/atoms/badge/badge.component';
import { BtnComponent } from '../../../../shared/ui/atoms/btn/btn.component';
import type { Task, TaskFirestoreStatus } from '../../models/task.model';
import type { TaskStatus } from '../../../../shared/ui/ui.types';

@Component({
  selector: 'app-student-task-detail',
  standalone: true,
  imports: [DatePipe, LucideAngularModule, BadgeComponent, BtnComponent],
  templateUrl: './student-task-detail.component.html',
  styleUrl: './student-task-detail.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class StudentTaskDetailComponent implements OnInit {
  taskId = input.required<string>();

  private readonly taskService = inject(TaskService);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);
  private readonly toastService = inject(ToastService);

  protected readonly ChevronLeftIcon = ChevronLeft;

  protected readonly task = signal<Task | null>(null);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly updating = signal(false);

  async ngOnInit(): Promise<void> {
    try {
      const task = await this.taskService.getTaskById(this.taskId());
      if (!task) {
        this.error.set('Tâche introuvable.');
        return;
      }
      this.task.set(task);
    } catch {
      this.error.set('Impossible de charger la tâche.');
    } finally {
      this.loading.set(false);
    }
  }

  protected effectiveStatus(task: Task): TaskStatus {
    if (task.status === 'done') return 'done';
    if (task.dueDate < new Date()) return 'late';
    return task.status;
  }

  protected nextStatus(task: Task): TaskFirestoreStatus | null {
    if (task.status === 'todo') return 'in_progress';
    if (task.status === 'in_progress') return 'done';
    return null;
  }

  protected nextStatusLabel(task: Task): string {
    if (task.status === 'todo') return 'Marquer En cours';
    if (task.status === 'in_progress') return 'Marquer Terminée';
    return '';
  }

  protected navigateBack(): void {
    this.router.navigate(['/tasks']);
  }

  protected async onUpdateStatus(): Promise<void> {
    const task = this.task();
    if (!task) return;
    const next = this.nextStatus(task);
    if (!next) return;

    this.updating.set(true);
    try {
      await this.taskService.updateTaskStatus(task.id, next);
      this.task.set({ ...task, status: next, updatedAt: new Date() });
      this.toastService.show({ message: 'Statut mis à jour.', type: 'success' });
    } catch {
      this.toastService.show({ message: 'Erreur lors de la mise à jour.', type: 'error' });
    } finally {
      this.updating.set(false);
    }
  }
}
