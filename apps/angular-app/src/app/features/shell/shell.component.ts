import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
} from '@angular/core';
import { Router, RouterOutlet, NavigationEnd } from '@angular/router';
import { toSignal } from '@angular/core/rxjs-interop';
import { filter, map } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';
import { DashboardService } from '../dashboard/services/dashboard.service';
import { SidebarComponent } from '../../shared/ui/organisms/sidebar/sidebar.component';
import { TopAppBarComponent } from '../../shared/ui/organisms/top-app-bar/top-app-bar.component';
import type { NavItem } from '../../shared/ui/ui.types';

const NAV_ITEMS: NavItem[] = [
  { label: 'Dashboard', route: '/dashboard', icon: 'layout-dashboard' },
  { label: 'Tâches', route: '/tasks', icon: 'check-square' },
  { label: 'Calendrier', route: '/calendar', icon: 'calendar' },
  { label: 'Chat', route: '/chat', icon: 'message-circle' },
  { label: 'Profil', route: '/profile', icon: 'user' },
];

@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [RouterOutlet, SidebarComponent, TopAppBarComponent],
  templateUrl: './shell.component.html',
  styleUrl: './shell.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ShellComponent {
  private readonly authService = inject(AuthService);
  private readonly dashboardService = inject(DashboardService);
  private readonly router = inject(Router);

  private readonly currentUrl = toSignal(
    this.router.events.pipe(
      filter((e): e is NavigationEnd => e instanceof NavigationEnd),
      map((e) => e.urlAfterRedirects),
    ),
    { initialValue: this.router.url },
  );

  protected readonly pageTitle = computed(() => {
    const url = this.currentUrl();
    const item = NAV_ITEMS.find((i) => url.startsWith(i.route));
    return item?.label ?? 'Learn@Home';
  });

  protected readonly navItems = computed<NavItem[]>(() => {
    const unread = this.dashboardService.data().unreadMessages;
    return NAV_ITEMS.map((item) =>
      item.route === '/chat' ? { ...item, badge: unread > 0 ? unread : undefined } : item,
    );
  });

  protected readonly currentUser = this.authService.currentUser;

  protected readonly userInitials = computed(() => {
    const user = this.currentUser();
    if (!user) return '?';
    return `${user.firstName[0]}${user.lastName[0]}`.toUpperCase();
  });

  protected readonly userName = computed(() => {
    const user = this.currentUser();
    if (!user) return '';
    return `${user.firstName} ${user.lastName}`;
  });

  protected readonly userRole = computed(() => {
    const user = this.currentUser();
    if (user?.role === 'volunteer') return 'Bénévole';
    if (user?.role === 'student') return 'Élève';
    return '';
  });

  protected async onLogout(): Promise<void> {
    await this.authService.logout();
    await this.router.navigate(['/auth/login']);
  }
}
