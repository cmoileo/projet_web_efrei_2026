enum TaskStatus { inProgress, completed }

class TaskSummary {
  const TaskSummary({
    required this.total,
    required this.completed,
    required this.inProgress,
  });

  final int total;
  final int completed;
  final int inProgress;
}

class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.date,
  });

  final String id;
  final String title;
  final DateTime date;
}

class VolunteerInfo {
  const VolunteerInfo({
    required this.firstName,
    required this.lastName,
    required this.nickname,
  });

  final String firstName;
  final String lastName;
  final String nickname;

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }
}

class DashboardData {
  const DashboardData({
    required this.taskSummary,
    required this.events,
    required this.unreadMessages,
    this.volunteer,
  });

  final TaskSummary taskSummary;
  final List<EventItem> events;
  final int unreadMessages;
  final VolunteerInfo? volunteer;
}
