/**
 * @service ToastService
 * @description Service centralisé pour afficher les notifications toast.
 * Wrape MatSnackBar d'Angular Material avec notre ToastComponent personnalisé.
 *
 * @example
 * // Dans un service ou composant
 * private readonly toast = inject(ToastService);
 * this.toast.success('Tâche créée avec succès');
 * this.toast.error('Une erreur est survenue');
 */
import { inject, Injectable } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';
import { ToastComponent } from './toast.component';
import type { ToastData, ToastType } from '../../ui.types';

@Injectable({ providedIn: 'root' })
export class ToastService {
  private readonly snackBar = inject(MatSnackBar);

  /** Durée par défaut des toasts en millisecondes */
  private readonly DEFAULT_DURATION = 4000;

  /**
   * Affiche un toast avec les données fournies.
   */
  show(data: ToastData): void {
    this.snackBar.openFromComponent(ToastComponent, {
      data,
      duration: data.duration ?? this.DEFAULT_DURATION,
      horizontalPosition: 'end',
      verticalPosition: 'bottom',
      panelClass: [`lah-toast--${data.type}`],
    });
  }

  /** Raccourci : toast de succès */
  success(message: string, duration?: number): void {
    this.show({ message, type: 'success', duration });
  }

  /** Raccourci : toast d'erreur */
  error(message: string, duration?: number): void {
    this.show({ message, type: 'error', duration });
  }

  /** Raccourci : toast d'alerte */
  warning(message: string, duration?: number): void {
    this.show({ message, type: 'warning', duration });
  }

  /** Raccourci : toast informatif */
  info(message: string, duration?: number): void {
    this.show({ message, type: 'info', duration });
  }
}
