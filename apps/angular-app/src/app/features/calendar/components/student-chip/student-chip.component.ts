import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-student-chip',
  standalone: true,
  template: `
    <span class="student-chip">
      <span class="student-chip__avatar">{{ initials() }}</span>
      <span class="student-chip__name">{{ firstName() }}</span>
    </span>
  `,
  styleUrl: './student-chip.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class StudentChipComponent {
  firstName = input.required<string>();
  lastName = input.required<string>();

  protected initials(): string {
    return `${this.firstName().charAt(0)}${this.lastName().charAt(0)}`.toUpperCase();
  }
}
