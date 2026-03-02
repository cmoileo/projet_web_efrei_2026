/**
 * @component TopAppBarComponent
 * @description Barre d'application supérieure (hauteur 64px web, 56px mobile).
 * Affiche le titre de la page, des actions à droite et un avatar utilisateur.
 *
 * @example
 * <app-top-app-bar
 *   pageTitle="Tableau de bord"
 *   [userInitials]="'JD'"
 *   [showSearch]="true"
 *   [notificationCount]="3"
 *   (searchClick)="openSearch()"
 *   (notificationClick)="openNotifications()"
 *   (avatarClick)="openProfile()"
 * />
 */
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
  output,
} from '@angular/core';
import { MatTooltipModule } from '@angular/material/tooltip';
import { LucideAngularModule, Bell, Search, ChevronLeft } from 'lucide-angular';
import { AvatarComponent } from '../../atoms/avatar/avatar.component';

@Component({
  selector: 'app-top-app-bar',
  standalone: true,
  imports: [MatTooltipModule, LucideAngularModule, AvatarComponent],
  templateUrl: './top-app-bar.component.html',
  styleUrl: './top-app-bar.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TopAppBarComponent {
  /** Titre affiché dans la barre */
  pageTitle = input<string>('');
  /** Affiche le bouton de retour */
  showBackButton = input<boolean>(false);
  /** Affiche l'icône de recherche */
  showSearch = input<boolean>(false);
  /** Nombre de notifications non lues (0 = masque le badge) */
  notificationCount = input<number>(0);
  /** URL de la photo de profil */
  userPhotoUrl = input<string | undefined>(undefined);
  /** Initiales de l'utilisateur pour l'avatar */
  userInitials = input<string>('?');

  /** Émis au clic sur le bouton retour */
  backClick = output<void>();
  /** Émis au clic sur la recherche */
  searchClick = output<void>();
  /** Émis au clic sur les notifications */
  notificationClick = output<void>();
  /** Émis au clic sur l'avatar / profil */
  avatarClick = output<void>();

  protected readonly BellIcon = Bell;
  protected readonly SearchIcon = Search;
  protected readonly BackIcon = ChevronLeft;

  protected hasNotifications = computed(() => this.notificationCount() > 0);

  protected notificationLabel = computed(() => {
    const count = this.notificationCount();
    if (count === 0) return 'Notifications';
    return `${count} notification${count > 1 ? 's' : ''} non lue${count > 1 ? 's' : ''}`;
  });

  protected notificationBadge = computed(() => {
    const count = this.notificationCount();
    return count > 99 ? '99+' : count.toString();
  });
}
