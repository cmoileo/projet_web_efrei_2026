import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { toSignal } from '@angular/core/rxjs-interop';
import { map } from 'rxjs';
import { AuthService } from '../../../core/services/auth.service';
import { VolunteerTaskDetailComponent } from '../pages/volunteer/volunteer-task-detail.component';
import { StudentTaskDetailComponent } from '../pages/student/student-task-detail.component';

@Component({
  selector: 'app-task-detail-page',
  standalone: true,
  imports: [VolunteerTaskDetailComponent, StudentTaskDetailComponent],
  template: `
    @if (role() === 'volunteer') {
      <app-volunteer-task-detail [taskId]="taskId()" />
    } @else {
      <app-student-task-detail [taskId]="taskId()" />
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TaskDetailPageComponent {
  private readonly route = inject(ActivatedRoute);
  private readonly authService = inject(AuthService);

  protected readonly taskId = toSignal(
    this.route.paramMap.pipe(map((p) => p.get('id') ?? '')),
    { initialValue: '' },
  );

  protected readonly role = () => this.authService.currentUser()?.role;
}
