/**
 * @component ModalComponent
 * @description Conteneur visuel de modal/dialog. À utiliser comme template
 * interne d'un composant ouvert via `MatDialog` ou `ModalService`.
 *
 * Slots (content projection) :
 * - Défaut        → corps de la modal
 * - [actions]     → boutons dans le footer (alignés à droite)
 * - [headerExtra] → contenu additionnel dans le header
 *
 * @example
 * // Dans un composant dialog :
 * @Component({
 *   template: `
 *     <app-modal [title]="'Créer une tâche'" (closeModal)="dialogRef.close()">
 *       <app-form-field label="Titre">
 *         <input matInput [formControl]="titleControl" />
 *       </app-form-field>
 *       <ng-container actions>
 *         <app-btn variant="ghost" (btnClick)="cancel()">Annuler</app-btn>
 *         <app-btn variant="primary" (btnClick)="submit()">Créer</app-btn>
 *       </ng-container>
 *     </app-modal>
 *   `
 * })
 * class CreateTaskDialog { ... }
 */
import {
  ChangeDetectionStrategy,
  Component,
  input,
  output,
} from '@angular/core';
import { LucideAngularModule, X } from 'lucide-angular';
import type { ModalSize } from '../../ui.types';

@Component({
  selector: 'app-modal',
  standalone: true,
  imports: [LucideAngularModule],
  templateUrl: './modal.component.html',
  styleUrl: './modal.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ModalComponent {
  /** Titre affiché dans le header */
  title = input<string>('');
  /** Taille de la modal : 'sm' (480px) | 'md' (640px) | 'lg' (800px) */
  size = input<ModalSize>('md');
  /** Cache le bouton fermeture si false */
  showClose = input<boolean>(true);

  /** Émis quand l'utilisateur clique sur fermer */
  closeModal = output<void>();

  protected readonly CloseIcon = X;
}
