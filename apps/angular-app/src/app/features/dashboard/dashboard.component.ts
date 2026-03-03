import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  template: `<div class="dashboard"><p>Dashboard</p></div>`,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DashboardComponent {}
