/**
 * @component LahBtnComponent
 * @description Bouton principal de l'application. 4 variantes × 3 tailles.
 * Utilise le composant mat-button de Angular Material 3 pour le ripple et l'accessibilité.
 *
 * @example
 * <app-btn variant="primary" size="md" (btnClick)="onSave()">Enregistrer</app-btn>
 * <app-btn variant="danger" [loading]="isDeleting$|async">Supprimer</app-btn>
 * <app-btn variant="secondary" [icon]="PlusIcon">Ajouter</app-btn>
 */
import {
  ChangeDetectionStrategy,
  Component,
  input,
  output,
} from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { LucideAngularModule, type LucideIconData } from 'lucide-angular';
import type { ButtonSize, ButtonVariant } from '../../ui.types';

@Component({
  selector: 'app-btn',
  standalone: true,
  imports: [MatButtonModule, MatProgressSpinnerModule, LucideAngularModule],
  templateUrl: './btn.component.html',
  styleUrl: './btn.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BtnComponent {
  /** Variante visuelle : 'primary' | 'secondary' | 'ghost' | 'danger' */
  variant = input<ButtonVariant>('primary');
  /** Taille : 'sm' | 'md' | 'lg' */
  size = input<ButtonSize>('md');
  /** Affiche un spinner et désactive le bouton */
  loading = input<boolean>(false);
  /** Désactive le bouton */
  disabled = input<boolean>(false);
  /** Icône Lucide optionnelle à gauche du label */
  icon = input<LucideIconData | undefined>(undefined);
  /** Type HTML du bouton */
  type = input<'button' | 'submit' | 'reset'>('button');

  /** Émis lors du clic (non émis si loading ou disabled) */
  btnClick = output<MouseEvent>();

  protected get isDisabled(): boolean {
    return this.disabled() || this.loading();
  }

  protected get iconSize(): number {
    const sizes: Record<ButtonSize, number> = { sm: 14, md: 16, lg: 18 };
    return sizes[this.size()];
  }

  protected onClick(event: MouseEvent): void {
    if (!this.isDisabled) {
      this.btnClick.emit(event);
    }
  }
}
