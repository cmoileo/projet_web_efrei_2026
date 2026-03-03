import { Injectable, signal } from '@angular/core';
import { VOLUNTEER_DASHBOARD_MOCK } from '../data/dashboard.mock';
import type { DashboardData } from '../models/dashboard.models';

@Injectable({ providedIn: 'root' })
export class DashboardService {
  private readonly _data = signal<DashboardData>(VOLUNTEER_DASHBOARD_MOCK);
  readonly data = this._data.asReadonly();
}
