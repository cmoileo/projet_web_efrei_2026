/**
 * @component SidebarComponent
 * @description Navigation latérale Web (240px étendue / 64px réduite).
 * Affiche le logo, les items de navigation et le profil utilisateur en bas.
 * La lecture des routes actives et le collapse sont gérés en interne.
 *
 * @example
 * <app-sidebar
 *   [navItems]="navItems"
 *   [userInitials]="'JD'"
 *   [userName]="'Jean Dupont'"
 *   [collapsed]="isMobile"
 *   (itemSelected)="onNavigation($event)"
 * />
 */
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
  output,
  signal,
} from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { MatTooltipModule } from '@angular/material/tooltip';
import { LucideAngularModule, LogOut, Menu, X } from 'lucide-angular';
import { AvatarComponent } from '../../atoms/avatar/avatar.component';
import { DividerComponent } from '../../atoms/divider/divider.component';
import type { NavItem } from '../../ui.types';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [
    RouterLink,
    RouterLinkActive,
    MatTooltipModule,
    LucideAngularModule,
    AvatarComponent,
    DividerComponent,
  ],
  templateUrl: './sidebar.component.html',
  styleUrl: './sidebar.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SidebarComponent {
  /** Liste des éléments de navigation */
  navItems = input<NavItem[]>([]);
  /** URL de la photo de profil (optionnelle) */
  userPhotoUrl = input<string | undefined>(undefined);
  /** Initiales de fallback */
  userInitials = input<string>('?');
  /** Nom complet affiché sous l'avatar */
  userName = input<string>('');
  /** Rôle de l'utilisateur (affiché sous le nom) */
  userRole = input<string>('');
  /** Force l'état réduit (utile sur mobile/tablet) */
  collapsed = input<boolean>(false);

  /** Émis quand un item de nav est cliqué */
  itemSelected = output<NavItem>();
  /** Émis quand l'utilisateur clique sur déconnexion */
  logoutClick = output<void>();

  protected readonly MenuIcon = Menu;
  protected readonly CloseIcon = X;
  protected readonly LogOutIcon = LogOut;

  /** État interne du collapse */
  protected readonly isCollapsed = signal<boolean>(false);

  protected readonly showLabels = computed(
    () => !this.isCollapsed() && !this.collapsed(),
  );

  protected toggleCollapse(): void {
    this.isCollapsed.update((v) => !v);
  }

  protected onItemClick(item: NavItem): void {
    this.itemSelected.emit(item);
  }

  protected onLogout(): void {
    this.logoutClick.emit();
  }
}
