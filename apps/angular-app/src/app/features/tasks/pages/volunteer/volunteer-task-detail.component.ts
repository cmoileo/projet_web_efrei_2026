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
import { LucideAngularModule, ChevronLeft, Pencil, Trash2 } from 'lucide-angular';
import { AuthService } from '../../../../core/services/auth.service';
import { UserService } from '../../../../core/services/user.service';
import { TaskService } from '../../services/task.service';
import { ToastService } from '../../../../shared/ui/molecules/toast/toast.service';
import { BadgeComponent } from '../../../../shared/ui/atoms/badge/badge.component';
import { BtnComponent } from '../../../../shared/ui/atoms/btn/btn.component';
import type { Task } from '../../models/task.model';
import type { TaskStatus } from '../../../../shared/ui/ui.types';

@Component({
  selector: 'app-volunteer-task-detail',
  standalone: true,
  imports: [DatePipe, LucideAngularModule, BadgeComponent, BtnComponent],
  templateUrl: './volunteer-task-detail.component.html',
  styleUrl: './volunteer-task-detail.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class VolunteerTaskDetailComponent implements OnInit {
  taskId = input.required<string>();

  private readonly taskService = inject(TaskService);
  private readonly userService = inject(UserService);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);
  private readonly toastService = inject(ToastService);

  protected readonly ChevronLeftIcon = ChevronLeft;
  protected readonly PencilIcon = Pencil;
  protected readonly Trash2Icon = Trash2;

  protected readonly task = signal<Task | null>(null);
  protected readonly studentName = signal<string>('—');
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly deleting = signal(false);

  async ngOnInit(): Promise<void> {
    try {
      const task = await this.taskService.getTaskById(this.taskId());
      if (!task) {
        this.error.set('Tâche introuvable.');
        return;
      }
      this.task.set(task);
      try {
        const student = await this.userService.getUser(task.assignedTo);
        if (student) {
          this.studentName.set(`${student.firstName} ${student.lastName}`);
        }
      } catch {
        // non-critical: student name not available
      }
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

  protected navigateBack(): void {
    this.router.navigate(['/tasks']);
  }

  protected navigateToEdit(): void {
    this.router.navigate(['/tasks', this.taskId(), 'edit']);
  }

  protected async onDelete(): Promise<void> {
    const t = this.task();
    if (!t) return;
    if (!window.confirm(`Supprimer la tâche "${t.title}" ?`)) return;
    this.deleting.set(true);
    try {
      await this.taskService.deleteTask(t.id);
      this.toastService.show({ message: 'Tâche supprimée.', type: 'success' });
      this.router.navigate(['/tasks']);
    } catch {
      this.toastService.show({ message: 'Erreur lors de la suppression.', type: 'error' });
      this.deleting.set(false);
    }
  }
}
