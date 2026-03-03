import type { DashboardData } from '../models/dashboard.models';

export const VOLUNTEER_DASHBOARD_MOCK: DashboardData = {
  students: [
    { id: 'stu-1', firstName: 'Lucas', lastName: 'Bernard', taskCount: 3 },
    { id: 'stu-2', firstName: 'Emma', lastName: 'Leroy', taskCount: 1 },
    { id: 'stu-3', firstName: 'Nathan', lastName: 'Petit', taskCount: 2 },
  ],
  taskSummary: {
    total: 6,
    completed: 2,
    inProgress: 4,
  },
  events: [
    { id: 'evt-1', title: 'Séance de maths', date: new Date(2026, 2, 5, 17, 0) },
    { id: 'evt-2', title: 'Révision brevet blanc', date: new Date(2026, 2, 10, 14, 30) },
    { id: 'evt-3', title: 'Correction de dissertation', date: new Date(2026, 2, 18, 10, 0) },
  ],
  unreadMessages: 4,
};
