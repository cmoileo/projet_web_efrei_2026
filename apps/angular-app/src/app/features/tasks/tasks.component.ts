import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { AuthService } from '../../core/services/auth.service';
import { VolunteerTaskListComponent } from './pages/volunteer/volunteer-task-list.component';
import { StudentTaskListComponent } from './pages/student/student-task-list.component';

@Component({
  selector: 'app-tasks',
  standalone: true,
  imports: [VolunteerTaskListComponent, StudentTaskListComponent],
  template: `
    @if (role() === 'volunteer') {
      <app-volunteer-task-list />
    } @else {
      <app-student-task-list />
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TasksComponent {
  private readonly authService = inject(AuthService);

  protected readonly role = () => this.authService.currentUser()?.role;
}
