import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import { LucideAngularModule, User } from 'lucide-angular';
import { CardComponent } from '../../../../shared/ui/molecules/card/card.component';
import { AvatarComponent } from '../../../../shared/ui/atoms/avatar/avatar.component';
import type { VolunteerInfo } from '../../models/dashboard.models';

@Component({
  selector: 'app-volunteer-card',
  standalone: true,
  imports: [CardComponent, AvatarComponent, LucideAngularModule],
  templateUrl: './volunteer-card.component.html',
  styleUrl: './volunteer-card.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class VolunteerCardComponent {
  volunteerInfo = input<VolunteerInfo | null>(null);

  protected readonly UserIcon = User;

  protected readonly isLoading = computed(() => this.volunteerInfo() === null);

  protected readonly initials = computed(() => {
    const v = this.volunteerInfo();
    if (!v) return '';
    return `${v.firstName[0]}${v.lastName[0]}`.toUpperCase();
  });

  protected readonly fullName = computed(() => {
    const v = this.volunteerInfo();
    if (!v) return '';
    return `${v.firstName} ${v.lastName}`;
  });
}
