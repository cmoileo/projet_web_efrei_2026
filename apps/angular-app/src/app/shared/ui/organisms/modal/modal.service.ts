/**
 * @service ModalService
 * @description Service wrapper sur `MatDialog` pour ouvrir des modals avec
 * la configuration par défaut de Learn@Home (overlay, animations, backdrop).
 *
 * @example
 * private readonly modal = inject(ModalService);
 *
 * openCreateTask(): void {
 *   const ref = this.modal.open(CreateTaskDialogComponent, {
 *     title: 'Créer une tâche',
 *     size: 'md',
 *     data: { assignedTo: this.currentUserId },
 *   });
 *   ref.afterClosed().subscribe(result => {
 *     if (result) this.taskService.createTask(result).subscribe();
 *   });
 * }
 */
import { inject, Injectable, type Type } from '@angular/core';
import { MatDialog, type MatDialogRef } from '@angular/material/dialog';
import type { ModalConfig, ModalSize } from '../../ui.types';

const MODAL_WIDTHS: Record<ModalSize, string> = {
  sm: '480px',
  md: '640px',
  lg: '800px',
};

@Injectable({ providedIn: 'root' })
export class ModalService {
  private readonly dialog = inject(MatDialog);

  /**
   * Ouvre un composant dans une modal Material Dialog.
   * @param component - Le composant Angular à afficher dans la modal
   * @param config    - Configuration (titre, taille, données à passer)
   */
  open<T, R = unknown>(
    component: Type<T>,
    config: ModalConfig<R> = { title: '' },
  ): MatDialogRef<T> {
    const size = config.size ?? 'md';

    return this.dialog.open(component, {
      width: MODAL_WIDTHS[size],
      maxWidth: '90vw',
      maxHeight: '90vh',
      panelClass: 'lah-dialog-panel',
      backdropClass: 'lah-dialog-backdrop',
      data: config.data,
      ariaLabel: config.title,
      autoFocus: 'first-tabbable',
      restoreFocus: true,
    });
  }

  /** Ferme toutes les modals ouvertes */
  closeAll(): void {
    this.dialog.closeAll();
  }
}
