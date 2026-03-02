/**
 * @component AvatarComponent
 * @description Avatar utilisateur circulaire. Affiche la photo si disponible,
 * sinon les initiales sur fond --color-primary-light.
 *
 * @example
 * <app-avatar [photoUrl]="user.photoUrl" [initials]="'JD'" [size]="40" [alt]="'Jean Dupont'" />
 * <app-avatar initials="MC" [size]="32" />
 */
import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import type { AvatarSize } from '../../ui.types';

@Component({
  selector: 'app-avatar',
  standalone: true,
  templateUrl: './avatar.component.html',
  styleUrl: './avatar.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AvatarComponent {
  /** URL de la photo de profil (optionnelle) */
  photoUrl = input<string | null | undefined>(undefined);
  /**
   * Initiales de fallback (max 2 caractères).
   * Utilisées quand photoUrl est absent ou en erreur.
   */
  initials = input<string>('?');
  /** Taille en pixels : 24 | 32 | 40 | 48 */
  size = input<AvatarSize>(40);
  /** Texte alternatif accessible pour l'image */
  alt = input<string>('Avatar utilisateur');

  protected hasPhoto = computed(() => !!this.photoUrl());

  protected sizeStyle = computed(() => ({
    width: `${this.size()}px`,
    height: `${this.size()}px`,
    'font-size': `${Math.round(this.size() * 0.36)}px`,
  }));

  protected onImageError(event: Event): void {
    const img = event.target as HTMLImageElement;
    img.style.display = 'none';
  }
}
