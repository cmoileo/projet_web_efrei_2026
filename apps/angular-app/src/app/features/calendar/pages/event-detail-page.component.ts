import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { DatePipe } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { LucideAngularModule, ChevronLeft, Pencil, Trash2 } from 'lucide-angular';
import { AuthService } from '../../../core/services/auth.service';
import { EventService } from '../services/event.service';
import { TaskService } from '../../tasks/services/task.service';
import { UserService } from '../../../core/services/user.service';
import { ToastService } from '../../../shared/ui/molecules/toast/toast.service';
import { BtnComponent } from '../../../shared/ui/atoms/btn/btn.component';
import { EventTypeBadgeComponent } from '../components/event-type-badge/event-type-badge.component';
import { StudentChipComponent } from '../components/student-chip/student-chip.component';
import type { CalendarEvent } from '../models/event.model';
import type { Task } from '../../tasks/models/task.model';
import type { User } from '../../../core/models/user.model';

@Component({
  selector: 'app-event-detail-page',
  standalone: true,
  imports: [
    DatePipe,
    LucideAngularModule,
    BtnComponent,
    EventTypeBadgeComponent,
    StudentChipComponent,
  ],
  templateUrl: './event-detail-page.component.html',
  styleUrl: './event-detail-page.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class EventDetailPageComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly eventService = inject(EventService);
  private readonly taskService = inject(TaskService);
  private readonly userService = inject(UserService);
  private readonly authService = inject(AuthService);
  private readonly toastService = inject(ToastService);

  protected readonly ChevronLeftIcon = ChevronLeft;
  protected readonly PencilIcon = Pencil;
  protected readonly Trash2Icon = Trash2;
  protected readonly role = () => this.authService.currentUser()?.role;

  protected readonly event = signal<CalendarEvent | null>(null);
  protected readonly students = signal<User[]>([]);
  protected readonly linkedTask = signal<Task | null>(null);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly deleting = signal(false);

  async ngOnInit(): Promise<void> {
    const id = this.route.snapshot.paramMap.get('id');
    if (!id) {
      this.error.set('Identifiant manquant.');
      this.loading.set(false);
      return;
    }

    try {
      const event = await this.eventService.getEventById(id);
      if (!event) {
        this.error.set('Événement introuvable.');
        return;
      }
      this.event.set(event);

      const studentPromises = event.studentIds.map((uid) =>
        this.userService.getUser(uid).catch(() => null),
      );
      const studentResults = await Promise.all(studentPromises);
      this.students.set(studentResults.filter((s): s is User => s !== null));

      if (event.linkedTaskId) {
        const task = await this.taskService.getTaskById(event.linkedTaskId).catch(() => null);
        if (task) this.linkedTask.set(task);
      }
    } catch {
      this.error.set("Impossible de charger l'événement.");
    } finally {
      this.loading.set(false);
    }
  }

  protected navigateBack(): void {
    this.router.navigate(['/calendar']);
  }

  protected navigateToEdit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    this.router.navigate(['/calendar', id, 'edit']);
  }

  protected async onDelete(): Promise<void> {
    const e = this.event();
    if (!e) return;
    if (!window.confirm(`Supprimer l'événement "${e.title}" ?`)) return;
    this.deleting.set(true);
    try {
      await this.eventService.deleteEvent(e.id);
      this.toastService.show({ message: 'Événement supprimé.', type: 'success' });
      this.router.navigate(['/calendar']);
    } catch {
      this.toastService.show({ message: 'Erreur lors de la suppression.', type: 'error' });
      this.deleting.set(false);
    }
  }
}
