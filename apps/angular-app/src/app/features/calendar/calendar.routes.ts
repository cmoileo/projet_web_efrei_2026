import type { Routes } from '@angular/router';

export const CALENDAR_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () =>
      import('./pages/calendar-page.component').then((m) => m.CalendarPageComponent),
  },
  {
    path: 'new',
    loadComponent: () =>
      import('./pages/event-form-page.component').then((m) => m.EventFormPageComponent),
  },
  {
    path: ':id',
    loadComponent: () =>
      import('./pages/event-detail-page.component').then((m) => m.EventDetailPageComponent),
  },
  {
    path: ':id/edit',
    loadComponent: () =>
      import('./pages/event-form-page.component').then((m) => m.EventFormPageComponent),
  },
];
