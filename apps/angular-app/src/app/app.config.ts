import { ApplicationConfig, LOCALE_ID, provideBrowserGlobalErrorListeners } from '@angular/core';
import { registerLocaleData } from '@angular/common';
import localeFr from '@angular/common/locales/fr';
import { provideRouter } from '@angular/router';

registerLocaleData(localeFr);
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { provideNativeDateAdapter } from '@angular/material/core';
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
  Mail,
  Lock,
  Eye,
  EyeOff,
  AtSign,
  KeyRound,
  ArrowLeft,
  AlertCircle,
} from 'lucide-angular';
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

import { routes } from './app.routes';
import { environment } from '../environments/environment';
import { FIREBASE_AUTH, FIREBASE_FIRESTORE } from './core/tokens/firebase.tokens';

const _firebaseApp = initializeApp(environment.firebase);

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),
    provideAnimationsAsync(),
    provideNativeDateAdapter(),
    { provide: LOCALE_ID, useValue: 'fr-FR' },
    { provide: FIREBASE_AUTH, useValue: getAuth(_firebaseApp) },
    { provide: FIREBASE_FIRESTORE, useValue: getFirestore(_firebaseApp) },
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
        Mail,
        Lock,
        Eye,
        EyeOff,
        AtSign,
        KeyRound,
        ArrowLeft,
        AlertCircle,
      }),
    },
  ],
};
