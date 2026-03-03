import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';
import { LucideAngularModule, ChevronLeft } from 'lucide-angular';
import { AuthService } from '../../../../core/services/auth.service';
import { UserService } from '../../../../core/services/user.service';
import { TaskService } from '../../services/task.service';
import { ToastService } from '../../../../shared/ui/molecules/toast/toast.service';
import { BtnComponent } from '../../../../shared/ui/atoms/btn/btn.component';
import { FormFieldComponent } from '../../../../shared/ui/molecules/form-field/form-field.component';
import type { Task, TaskFirestoreStatus } from '../../models/task.model';
import type { User } from '../../../../core/models/user.model';
import { TASK_STATUS_OPTIONS } from '../../models/task.model';

@Component({
  selector: 'app-task-form',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatDatepickerModule,
    MatInputModule,
    MatSelectModule,
    MatFormFieldModule,
    LucideAngularModule,
    BtnComponent,
    FormFieldComponent,
  ],
  templateUrl: './task-form.component.html',
  styleUrl: './task-form.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TaskFormComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly taskService = inject(TaskService);
  private readonly userService = inject(UserService);
  private readonly authService = inject(AuthService);
  private readonly toastService = inject(ToastService);

  protected readonly ChevronLeftIcon = ChevronLeft;
  protected readonly statusOptions = TASK_STATUS_OPTIONS;

  protected readonly editId = signal<string | null>(null);
  protected readonly students = signal<User[]>([]);
  protected readonly loading = signal(true);
  protected readonly submitting = signal(false);

  protected readonly form = this.fb.nonNullable.group({
    title: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(100)]],
    description: ['', [Validators.required, Validators.maxLength(500)]],
    dueDate: [null as Date | null, Validators.required],
    assignedTo: ['', Validators.required],
    status: ['todo' as TaskFirestoreStatus, Validators.required],
  });

  async ngOnInit(): Promise<void> {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) this.editId.set(id);

    try {
      const uid = this.authService.currentUser()!.uid;
      const [students, task] = await Promise.all([
        this.userService.getStudentsForVolunteer(uid),
        id ? this.taskService.getTaskById(id) : Promise.resolve(null),
      ]);
      this.students.set(students);
      if (task) this.patchForm(task);
    } catch {
      this.toastService.show({ message: 'Erreur lors du chargement.', type: 'error' });
    } finally {
      this.loading.set(false);
    }
  }

  private patchForm(task: Task): void {
    this.form.patchValue({
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      assignedTo: task.assignedTo,
      status: task.status,
    });
  }

  protected getTitleError(): string {
    const ctrl = this.form.controls.title;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return 'Le titre est obligatoire.';
    if (ctrl.hasError('minlength')) return 'Le titre doit contenir au moins 3 caractères.';
    if (ctrl.hasError('maxlength')) return 'Le titre ne peut pas dépasser 100 caractères.';
    return '';
  }

  protected getDescriptionError(): string {
    const ctrl = this.form.controls.description;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return 'La description est obligatoire.';
    if (ctrl.hasError('maxlength')) return 'La description ne peut pas dépasser 500 caractères.';
    return '';
  }

  protected getDueDateError(): string {
    const ctrl = this.form.controls.dueDate;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return "La date d'échéance est obligatoire.";
    return '';
  }

  protected getAssignedToError(): string {
    const ctrl = this.form.controls.assignedTo;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return "Veuillez sélectionner un élève.";
    return '';
  }

  protected navigateBack(): void {
    const id = this.editId();
    if (id) {
      this.router.navigate(['/tasks', id]);
    } else {
      this.router.navigate(['/tasks']);
    }
  }

  protected async onSubmit(): Promise<void> {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;

    this.submitting.set(true);
    const value = this.form.getRawValue();
    const id = this.editId();

    try {
      if (id) {
        await this.taskService.updateTask(id, {
          title: value.title,
          description: value.description,
          dueDate: value.dueDate!,
          assignedTo: value.assignedTo,
          status: value.status,
        });
        this.toastService.show({ message: 'Tâche mise à jour.', type: 'success' });
        this.router.navigate(['/tasks', id]);
      } else {
        const uid = this.authService.currentUser()!.uid;
        await this.taskService.createTask({
          title: value.title,
          description: value.description,
          dueDate: value.dueDate!,
          assignedTo: value.assignedTo,
          createdBy: uid,
        });
        this.toastService.show({ message: 'Tâche créée.', type: 'success' });
        this.router.navigate(['/tasks']);
      }
    } catch {
      this.toastService.show({ message: "Erreur lors de l'enregistrement.", type: 'error' });
      this.submitting.set(false);
    }
  }
}
