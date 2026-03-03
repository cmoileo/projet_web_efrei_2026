import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { DatePipe } from '@angular/common';
import { Router } from '@angular/router';
import { AuthService } from '../../../../core/services/auth.service';
import { TaskService } from '../../services/task.service';
import { BadgeComponent } from '../../../../shared/ui/atoms/badge/badge.component';
import type { Task, TaskFirestoreStatus } from '../../models/task.model';
import type { TaskStatus } from '../../../../shared/ui/ui.types';

type StatusFilterValue = TaskFirestoreStatus | 'all';

@Component({
  selector: 'app-student-task-list',
  standalone: true,
  imports: [DatePipe, BadgeComponent],
  templateUrl: './student-task-list.component.html',
  styleUrl: './student-task-list.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class StudentTaskListComponent implements OnInit {
  private readonly taskService = inject(TaskService);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  protected readonly tasks = signal<Task[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);

  protected readonly statusFilter = signal<StatusFilterValue>('all');

  protected readonly filteredTasks = computed(() => {
    const status = this.statusFilter();
    if (status === 'all') return this.tasks();
    return this.tasks().filter((t) => t.status === status);
  });

  protected readonly statusOptions: { value: StatusFilterValue; label: string }[] = [
    { value: 'all', label: 'Tous les statuts' },
    { value: 'todo', label: 'À faire' },
    { value: 'in_progress', label: 'En cours' },
    { value: 'done', label: 'Terminée' },
  ];

  async ngOnInit(): Promise<void> {
    try {
      const uid = this.authService.currentUser()!.uid;
      const tasks = await this.taskService.getTasksByStudent(uid);
      this.tasks.set(tasks);
    } catch {
      this.error.set('Impossible de charger les tâches.');
    } finally {
      this.loading.set(false);
    }
  }

  protected effectiveStatus(task: Task): TaskStatus {
    if (task.status === 'done') return 'done';
    if (task.dueDate < new Date()) return 'late';
    return task.status;
  }

  protected onStatusChange(value: string): void {
    this.statusFilter.set(value as StatusFilterValue);
  }

  protected navigateToDetail(id: string): void {
    this.router.navigate(['/tasks', id]);
  }
}
