/**
 * @component DividerComponent
 * @description Séparateur horizontal simple. Utilise MatDivider de Material.
 *
 * @example
 * <app-divider />
 * <app-divider [vertical]="true" />
 */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { MatDividerModule } from '@angular/material/divider';

@Component({
  selector: 'app-divider',
  standalone: true,
  imports: [MatDividerModule],
  template: `<mat-divider [vertical]="vertical()" />`,
  styleUrl: './divider.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DividerComponent {
  /** Divider vertical si true */
  vertical = input<boolean>(false);
}
