import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { Router } from '@angular/router';
import { LucideAngularModule, Plus, Users } from 'lucide-angular';
import { AuthService } from '../../core/services/auth.service';
import { DashboardService } from './services/dashboard.service';
import { BtnComponent } from '../../shared/ui/atoms/btn/btn.component';
import { StudentsCardComponent } from './components/students-card/students-card.component';
import { VolunteerCardComponent } from './components/volunteer-card/volunteer-card.component';
import { TaskSummaryCardComponent } from './components/task-summary-card/task-summary-card.component';
import { EventsCardComponent } from './components/events-card/events-card.component';
import { MessagesCardComponent } from './components/messages-card/messages-card.component';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [
    BtnComponent,
    LucideAngularModule,
    StudentsCardComponent,
    VolunteerCardComponent,
    TaskSummaryCardComponent,
    EventsCardComponent,
    MessagesCardComponent,
  ],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DashboardComponent {
  private readonly authService = inject(AuthService);
  private readonly dashboardService = inject(DashboardService);
  private readonly router = inject(Router);

  protected readonly PlusIcon = Plus;
  protected readonly UsersIcon = Users;

  protected readonly currentUser = this.authService.currentUser;

  protected readonly role = computed(() => this.currentUser()?.role);

  protected readonly greeting = computed(() => {
    const user = this.currentUser();
    return user ? `Bonjour, ${user.firstName} 👋` : 'Bonjour 👋';
  });

  protected readonly students = toSignal(this.dashboardService.students$, {
    initialValue: null,
  });

  protected readonly volunteerInfo = toSignal(this.dashboardService.volunteerInfo$, {
    initialValue: null,
  });

  protected readonly taskSummary = toSignal(this.dashboardService.taskSummary$, {
    initialValue: null,
  });

  protected readonly events = toSignal(this.dashboardService.events$, {
    initialValue: [],
  });

  protected readonly unreadMessages = toSignal(this.dashboardService.unreadMessages$, {
    initialValue: null,
  });

  protected navigateToTasks(): void {
    this.router.navigate(['/tasks']);
  }

  protected scrollToStudents(): void {
    document.getElementById('students-section')?.scrollIntoView({ behavior: 'smooth' });
  }
}
