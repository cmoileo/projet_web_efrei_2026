import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import { LucideAngularModule, Users } from 'lucide-angular';
import { CardComponent } from '../../../../shared/ui/molecules/card/card.component';
import { AvatarComponent } from '../../../../shared/ui/atoms/avatar/avatar.component';
import type { StudentInfo } from '../../models/dashboard.models';

@Component({
  selector: 'app-students-card',
  standalone: true,
  imports: [CardComponent, AvatarComponent, LucideAngularModule],
  templateUrl: './students-card.component.html',
  styleUrl: './students-card.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class StudentsCardComponent {
  students = input<StudentInfo[]>([]);

  protected readonly UsersIcon = Users;

  protected readonly hasStudents = computed(() => this.students().length > 0);

  protected getInitials(student: StudentInfo): string {
    return `${student.firstName[0]}${student.lastName[0]}`.toUpperCase();
  }
}
