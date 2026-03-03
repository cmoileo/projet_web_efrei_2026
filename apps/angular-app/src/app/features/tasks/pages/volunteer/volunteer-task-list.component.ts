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
import { LucideAngularModule, Plus, Trash2, Pencil } from 'lucide-angular';
import { AuthService } from '../../../../core/services/auth.service';
import { UserService } from '../../../../core/services/user.service';
import { TaskService } from '../../services/task.service';
import { ToastService } from '../../../../shared/ui/molecules/toast/toast.service';
import { BadgeComponent } from '../../../../shared/ui/atoms/badge/badge.component';
import { BtnComponent } from '../../../../shared/ui/atoms/btn/btn.component';
import type { Task, TaskFirestoreStatus } from '../../models/task.model';
import type { User } from '../../../../core/models/user.model';
import type { TaskStatus } from '../../../../shared/ui/ui.types';

type StatusFilterValue = TaskFirestoreStatus | 'all';

@Component({
  selector: 'app-volunteer-task-list',
  standalone: true,
  imports: [DatePipe, LucideAngularModule, BadgeComponent, BtnComponent],
  templateUrl: './volunteer-task-list.component.html',
  styleUrl: './volunteer-task-list.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class VolunteerTaskListComponent implements OnInit {
  private readonly taskService = inject(TaskService);
  private readonly userService = inject(UserService);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);
  private readonly toastService = inject(ToastService);

  protected readonly PlusIcon = Plus;
  protected readonly Trash2Icon = Trash2;
  protected readonly PencilIcon = Pencil;

  protected readonly tasks = signal<Task[]>([]);
  protected readonly students = signal<User[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly deletingId = signal<string | null>(null);

  protected readonly statusFilter = signal<StatusFilterValue>('all');
  protected readonly studentFilter = signal<string>('all');

  protected readonly filteredTasks = computed(() => {
    let list = this.tasks();
    const status = this.statusFilter();
    const student = this.studentFilter();
    if (status !== 'all') list = list.filter((t) => t.status === status);
    if (student !== 'all') list = list.filter((t) => t.assignedTo === student);
    return list;
  });

  protected readonly hasActiveFilter = computed(
    () => this.statusFilter() !== 'all' || this.studentFilter() !== 'all',
  );

  protected readonly statusOptions: { value: StatusFilterValue; label: string }[] = [
    { value: 'all', label: 'Tous les statuts' },
    { value: 'todo', label: 'À faire' },
    { value: 'in_progress', label: 'En cours' },
    { value: 'done', label: 'Terminée' },
  ];

  async ngOnInit(): Promise<void> {
    try {
      const uid = this.authService.currentUser()!.uid;
      const [tasks, students] = await Promise.all([
        this.taskService.getTasksByVolunteer(uid),
        this.userService.getStudentsForVolunteer(uid),
      ]);
      this.tasks.set(tasks);
      this.students.set(students);
    } catch {
      this.error.set('Impossible de charger les tâches.');
    } finally {
      this.loading.set(false);
    }
  }

  protected studentName(uid: string): string {
    const s = this.students().find((u) => u.uid === uid);
    return s ? `${s.firstName} ${s.lastName}` : '—';
  }

  protected effectiveStatus(task: Task): TaskStatus {
    if (task.status === 'done') return 'done';
    if (task.dueDate < new Date()) return 'late';
    return task.status;
  }

  protected onStatusChange(value: string): void {
    this.statusFilter.set(value as StatusFilterValue);
  }

  protected onStudentChange(value: string): void {
    this.studentFilter.set(value);
  }

  protected navigateToDetail(id: string): void {
    this.router.navigate(['/tasks', id]);
  }

  protected navigateToNew(): void {
    this.router.navigate(['/tasks/new']);
  }

  protected navigateToEdit(id: string, event: MouseEvent): void {
    event.stopPropagation();
    this.router.navigate(['/tasks', id, 'edit']);
  }

  protected async onDeleteTask(task: Task, event: MouseEvent): Promise<void> {
    event.stopPropagation();
    if (!window.confirm(`Supprimer la tâche "${task.title}" ?`)) return;
    this.deletingId.set(task.id);
    try {
      await this.taskService.deleteTask(task.id);
      this.tasks.update((list) => list.filter((t) => t.id !== task.id));
      this.toastService.show({ message: 'Tâche supprimée.', type: 'success' });
    } catch {
      this.toastService.show({ message: 'Erreur lors de la suppression.', type: 'error' });
    } finally {
      this.deletingId.set(null);
    }
  }
}
