import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { MatDialogModule } from '@angular/material/dialog';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { LucideAngularModule, Check, Plus } from 'lucide-angular';

import {
  AvatarComponent,
  BadgeComponent,
  BtnComponent,
  DividerComponent,
  InputComponent,
  CardComponent,
  FormFieldComponent,
  MessageBubbleComponent,
  TaskItemComponent,
  ToastService,
  ModalService,
  SidebarComponent,
  TopAppBarComponent,
  type NavItem,
  type TaskItem,
} from './shared/ui/index';

import { ShowcaseModalComponent } from './showcase-modal.component';

const DEMO_NAV_ITEMS: NavItem[] = [
  { label: 'Tableau de bord', route: '/', icon: 'layout-dashboard' },
  { label: 'Mes tâches', route: '/tasks', icon: 'check-square', badge: 3 },
  { label: 'Calendrier', route: '/calendar', icon: 'calendar' },
  { label: 'Messages', route: '/chat', icon: 'message-circle', badge: 12 },
  { label: 'Paramètres', route: '/settings', icon: 'settings' },
];

const DEMO_TASKS: TaskItem[] = [
  {
    id: '1',
    title: 'Préparer le cours de mathématiques',
    status: 'todo',
    assignedTo: 'Marie Curie',
    dueDate: '2026-03-10',
  },
  {
    id: '2',
    title: 'Réviser les conjugaisons',
    status: 'in_progress',
    assignedTo: 'Jean Dupont',
    dueDate: '2026-03-05',
  },
  {
    id: '3',
    title: 'Exercices de physique — Chapitre 4',
    status: 'done',
    assignedTo: 'Alice Martin',
  },
  {
    id: '4',
    title: 'Rendre le devoir de français',
    status: 'late',
    assignedTo: 'Bob Durand',
    dueDate: '2026-02-28',
  },
];

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatSnackBarModule,
    LucideAngularModule,
    AvatarComponent,
    BadgeComponent,
    BtnComponent,
    DividerComponent,
    InputComponent,
    CardComponent,
    FormFieldComponent,
    MessageBubbleComponent,
    TaskItemComponent,
    SidebarComponent,
    TopAppBarComponent,
  ],
  templateUrl: './app.html',
  styleUrl: './app.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class App {
  private readonly toastService = inject(ToastService);
  private readonly modalService = inject(ModalService);
  private readonly fb = inject(FormBuilder);

  protected readonly navItems = DEMO_NAV_ITEMS;
  protected readonly demoTasks = signal<TaskItem[]>(DEMO_TASKS);

  protected readonly CheckIcon = Check;
  protected readonly PlusIcon = Plus;

  protected readonly demoForm = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
  });

  protected get emailError(): string {
    const ctrl = this.demoForm.get('email');
    if (!ctrl?.touched) return '';
    if (ctrl.errors?.['required']) return 'Ce champ est requis';
    if (ctrl.errors?.['email']) return 'Adresse email invalide';
    return '';
  }

  protected get passwordError(): string {
    const ctrl = this.demoForm.get('password');
    if (!ctrl?.touched) return '';
    if (ctrl.errors?.['required']) return 'Ce champ est requis';
    if (ctrl.errors?.['minlength']) return 'Minimum 8 caractères';
    return '';
  }

  protected showToast(type: 'success' | 'error' | 'warning' | 'info'): void {
    const messages: Record<string, string> = {
      success: 'Tâche créée avec succès !',
      error: 'Une erreur est survenue.',
      warning: 'Modification non sauvegardée.',
      info: '3 nouveaux messages reçus.',
    };
    this.toastService.show({ message: messages[type], type });
  }

  protected openModal(): void {
    this.modalService.open(ShowcaseModalComponent, {
      title: 'Exemple de modal',
      size: 'md',
    });
  }

  protected onTaskStatusChange(event: { id: string; status: string }): void {
    this.demoTasks.update((tasks) =>
      tasks.map((t) =>
        t.id === event.id
          ? { ...t, status: event.status as TaskItem['status'] }
          : t
      )
    );
  }
}
