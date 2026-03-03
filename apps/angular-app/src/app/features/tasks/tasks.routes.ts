import type { Routes } from '@angular/router';

export const TASKS_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () =>
      import('./tasks.component').then((m) => m.TasksComponent),
  },
  {
    path: 'new',
    loadComponent: () =>
      import('./pages/volunteer/task-form.component').then((m) => m.TaskFormComponent),
  },
  {
    path: ':id',
    loadComponent: () =>
      import('./pages/task-detail-page.component').then((m) => m.TaskDetailPageComponent),
  },
  {
    path: ':id/edit',
    loadComponent: () =>
      import('./pages/volunteer/task-form.component').then((m) => m.TaskFormComponent),
  },
];
