/**
 * @component ToastComponent
 * @description Notification toast avec icône contextuelle et bouton fermer.
 * Utilisé via ToastService.show() — ne pas instancier directement.
 *
 * @example
 * // Via le service :
 * this.toastService.success('Sauvegarde réussie !');
 */
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
} from '@angular/core';
import { MAT_SNACK_BAR_DATA, MatSnackBarRef } from '@angular/material/snack-bar';
import { LucideAngularModule, CheckCircle, XCircle, AlertTriangle, Info, X } from 'lucide-angular';
import type { ToastData, ToastType } from '../../ui.types';

/** Configuration d'icône par type de toast */
const TOAST_ICON_MAP = {
  success: CheckCircle,
  error: XCircle,
  warning: AlertTriangle,
  info: Info,
} as const;

@Component({
  selector: 'app-toast',
  standalone: true,
  imports: [LucideAngularModule],
  templateUrl: './toast.component.html',
  styleUrl: './toast.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ToastComponent {
  protected readonly data = inject<ToastData>(MAT_SNACK_BAR_DATA);
  private readonly snackBarRef = inject(MatSnackBarRef<ToastComponent>);

  protected readonly CloseIcon = X;

  protected readonly icon = computed(() => TOAST_ICON_MAP[this.data.type]);

  protected close(): void {
    this.snackBarRef.dismiss();
  }
}
