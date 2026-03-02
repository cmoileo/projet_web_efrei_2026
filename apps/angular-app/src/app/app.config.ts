import { ApplicationConfig, provideBrowserGlobalErrorListeners } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { LUCIDE_ICONS, LucideIconProvider } from 'lucide-angular';
import {
  LayoutDashboard,
  CheckSquare,
  Calendar,
  MessageCircle,
  Settings,
  Bell,
  Search,
  X,
  CheckCircle,
  XCircle,
  AlertTriangle,
  Info,
  Trash2,
  Pencil,
  ChevronLeft,
  ChevronRight,
  LogOut,
  User,
  Plus,
  Menu,
  ChevronDown,
} from 'lucide-angular';

import { routes } from './app.routes';

/**
 * Configuration principale de l'application.
 * - provideAnimationsAsync : animations Angular Material
 * - LUCIDE_ICONS : registre centralisé des icônes Lucide utilisées
 */
export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),
    provideAnimationsAsync(),
    {
      provide: LUCIDE_ICONS,
      multi: true,
      useValue: new LucideIconProvider({
        LayoutDashboard,
        CheckSquare,
        Calendar,
        MessageCircle,
        Settings,
        Bell,
        Search,
        X,
        CheckCircle,
        XCircle,
        AlertTriangle,
        Info,
        Trash2,
        Pencil,
        ChevronLeft,
        ChevronRight,
        LogOut,
        User,
        Plus,
        Menu,
        ChevronDown,
      }),
    },
  ],
};
