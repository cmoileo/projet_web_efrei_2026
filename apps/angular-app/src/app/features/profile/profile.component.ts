import { ChangeDetectionStrategy, Component } from '@angular/core';
import { LucideAngularModule, User } from 'lucide-angular';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [LucideAngularModule],
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ProfileComponent {
  protected readonly UserIcon = User;
}
