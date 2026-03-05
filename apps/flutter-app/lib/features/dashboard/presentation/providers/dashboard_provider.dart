import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../calendar/presentation/providers/event_provider.dart';
import '../../domain/dashboard_models.dart';

final dashboardEventsProvider =
    StreamProvider.autoDispose<List<EventItem>>((ref) {
  return ref.watch(eventsForStudentProvider.stream).map(
        (events) => events
            .map((e) => EventItem(id: e.id, title: e.title, date: e.date))
            .toList(),
      );
});
