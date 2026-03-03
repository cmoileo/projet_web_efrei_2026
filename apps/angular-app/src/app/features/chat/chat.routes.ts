import type { Routes } from '@angular/router';

export const CHAT_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./chat.component').then((m) => m.ChatComponent),
  },
  {
    path: ':id',
    loadComponent: () =>
      import('./pages/conversation-detail/conversation-detail.component').then(
        (m) => m.ConversationDetailComponent,
      ),
  },
];
