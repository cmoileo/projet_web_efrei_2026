import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { LucideAngularModule, ChevronLeft } from 'lucide-angular';
import { AuthService } from '../../../core/services/auth.service';
import { UserService } from '../../../core/services/user.service';
import { TaskService } from '../../tasks/services/task.service';
import { EventService } from '../services/event.service';
import { ToastService } from '../../../shared/ui/molecules/toast/toast.service';
import { BtnComponent } from '../../../shared/ui/atoms/btn/btn.component';
import { FormFieldComponent } from '../../../shared/ui/molecules/form-field/form-field.component';
import { EventTypeBadgeComponent } from '../components/event-type-badge/event-type-badge.component';
import { StudentChipComponent } from '../components/student-chip/student-chip.component';
import { EVENT_TYPE_OPTIONS } from '../models/event.model';
import type { CalendarEvent, EventType } from '../models/event.model';
import type { Task } from '../../tasks/models/task.model';
import type { User } from '../../../core/models/user.model';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';

@Component({
  selector: 'app-event-form-page',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatDatepickerModule,
    MatInputModule,
    MatFormFieldModule,
    LucideAngularModule,
    BtnComponent,
    FormFieldComponent,
    EventTypeBadgeComponent,
    StudentChipComponent,
  ],
  templateUrl: './event-form-page.component.html',
  styleUrl: './event-form-page.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class EventFormPageComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly eventService = inject(EventService);
  private readonly taskService = inject(TaskService);
  private readonly userService = inject(UserService);
  private readonly authService = inject(AuthService);
  private readonly toastService = inject(ToastService);

  protected readonly ChevronLeftIcon = ChevronLeft;
  protected readonly typeOptions = EVENT_TYPE_OPTIONS;

  protected readonly editId = signal<string | null>(null);
  protected readonly existingEvent = signal<CalendarEvent | null>(null);
  protected readonly students = signal<User[]>([]);
  protected readonly tasks = signal<Task[]>([]);
  protected readonly loading = signal(true);
  protected readonly submitting = signal(false);

  protected readonly form = this.fb.nonNullable.group({
    title: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(100)]],
    description: ['', Validators.maxLength(500)],
    type: ['cours' as EventType, Validators.required],
    date: ['' as string, Validators.required],
    studentIds: [[] as string[], [Validators.required, Validators.minLength(1)]],
    linkedTaskId: ['' as string],
  });

  async ngOnInit(): Promise<void> {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) this.editId.set(id);

    try {
      const uid = this.authService.currentUser()!.uid;
      const [students, tasks, event] = await Promise.all([
        this.userService.getStudentsForVolunteer(uid),
        this.taskService.getTasksByVolunteer(uid),
        id ? this.eventService.getEventById(id) : Promise.resolve(null),
      ]);
      this.students.set(students);
      this.tasks.set(tasks);
      if (event) {
        this.existingEvent.set(event);
        this.patchForm(event);
      }
    } catch {
      this.toastService.show({ message: 'Erreur lors du chargement.', type: 'error' });
    } finally {
      this.loading.set(false);
    }
  }

  private patchForm(event: CalendarEvent): void {
    const dateStr = this.toDatetimeLocal(event.date);
    this.form.patchValue({
      title: event.title,
      description: event.description,
      type: event.type,
      date: dateStr,
      studentIds: event.studentIds,
      linkedTaskId: event.linkedTaskId ?? '',
    });
  }

  private toDatetimeLocal(date: Date): string {
    const pad = (n: number) => n.toString().padStart(2, '0');
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
  }

  protected isStudentSelected(uid: string): boolean {
    return this.form.controls.studentIds.value.includes(uid);
  }

  protected toggleStudent(uid: string): void {
    const current = this.form.controls.studentIds.value;
    const updated = current.includes(uid)
      ? current.filter((id) => id !== uid)
      : [...current, uid];
    this.form.controls.studentIds.setValue(updated);
    this.form.controls.studentIds.markAsTouched();
  }

  protected getStudentById(uid: string): User | undefined {
    return this.students().find((s) => s.uid === uid);
  }

  protected getTitleError(): string {
    const ctrl = this.form.controls.title;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return 'Le titre est obligatoire.';
    if (ctrl.hasError('minlength')) return 'Le titre doit contenir au moins 3 caractères.';
    if (ctrl.hasError('maxlength')) return 'Le titre ne peut pas dépasser 100 caractères.';
    return '';
  }

  protected getDateError(): string {
    const ctrl = this.form.controls.date;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return 'La date est obligatoire.';
    return '';
  }

  protected getStudentIdsError(): string {
    const ctrl = this.form.controls.studentIds;
    if (!ctrl.touched) return '';
    if (ctrl.value.length === 0) return 'Sélectionnez au moins un élève.';
    return '';
  }

  protected navigateBack(): void {
    const id = this.editId();
    if (id) {
      this.router.navigate(['/calendar', id]);
    } else {
      this.router.navigate(['/calendar']);
    }
  }

  protected async onSubmit(): Promise<void> {
    this.form.markAllAsTouched();
    if (this.form.invalid || this.form.controls.studentIds.value.length === 0) return;

    this.submitting.set(true);
    const value = this.form.getRawValue();
    const eventDate = new Date(value.date);
    const id = this.editId();
    const uid = this.authService.currentUser()!.uid;

    try {
      if (id) {
        await this.eventService.updateEvent(
          id,
          {
            title: value.title,
            description: value.description,
            type: value.type,
            date: eventDate,
            studentIds: value.studentIds,
            linkedTaskId: value.linkedTaskId || null,
          },
          this.existingEvent()?.linkedTaskId,
        );
        this.toastService.show({ message: 'Événement modifié.', type: 'success' });
      } else {
        await this.eventService.createEvent({
          title: value.title,
          description: value.description,
          type: value.type,
          date: eventDate,
          volunteerId: uid,
          studentIds: value.studentIds,
          linkedTaskId: value.linkedTaskId || null,
        });
        this.toastService.show({ message: 'Événement créé.', type: 'success' });
      }
      this.router.navigate(['/calendar']);
    } catch {
      this.toastService.show({ message: "Erreur lors de l'enregistrement.", type: 'error' });
      this.submitting.set(false);
    }
  }
}
