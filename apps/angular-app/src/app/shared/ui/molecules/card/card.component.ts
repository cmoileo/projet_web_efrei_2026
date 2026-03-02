/**
 * @component CardComponent
 * @description Conteneur carte avec ombre et survol. Composition via ng-content.
 * Deux variantes : 'elevated' (ombre) et 'flat' (bordure seulement).
 *
 * @example
 * <app-card>
 *   <h3>Titre</h3>
 *   <p>Contenu de la carte</p>
 * </app-card>
 *
 * <app-card variant="flat" [clickable]="true" (cardClick)="onSelect()">
 *   Carte cliquable sans ombre
 * </app-card>
 */
import {
  ChangeDetectionStrategy,
  Component,
  input,
  output,
} from '@angular/core';

export type CardVariant = 'elevated' | 'flat';

@Component({
  selector: 'app-card',
  standalone: true,
  templateUrl: './card.component.html',
  styleUrl: './card.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CardComponent {
  /** Variante visuelle : 'elevated' (défaut) avec ombre, ou 'flat' sans ombre */
  variant = input<CardVariant>('elevated');
  /** Active l'état interactif (cursor pointer, hover effect) */
  clickable = input<boolean>(false);
  /** Padding interne supprimé (utile pour les listes) */
  noPadding = input<boolean>(false);

  /** Émis lors du clic si clickable = true */
  cardClick = output<MouseEvent>();

  protected onClick(event: MouseEvent): void {
    if (this.clickable()) {
      this.cardClick.emit(event);
    }
  }
}
