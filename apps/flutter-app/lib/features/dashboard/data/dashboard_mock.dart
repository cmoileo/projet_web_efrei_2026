import '../domain/dashboard_models.dart';

abstract final class DashboardMock {
  static final DashboardData studentData = DashboardData(
    taskSummary: const TaskSummary(total: 2, completed: 1, inProgress: 1),
    events: [
      EventItem(
        id: 'evt-1',
        title: 'Séance de maths',
        date: DateTime(2026, 3, 5, 17, 0),
      ),
      EventItem(
        id: 'evt-2',
        title: 'Révision brevet blanc',
        date: DateTime(2026, 3, 10, 14, 30),
      ),
      EventItem(
        id: 'evt-3',
        title: 'Correction de dissertation',
        date: DateTime(2026, 3, 18, 10, 0),
      ),
    ],
    unreadMessages: 2,
    volunteer: const VolunteerInfo(
      firstName: 'Sophie',
      lastName: 'Martin',
      nickname: 'sophiem',
    ),
  );
}
