import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dashboard_mock.dart';
import '../../domain/dashboard_models.dart';

final dashboardDataProvider = Provider<DashboardData>((ref) {
  return DashboardMock.studentData;
});
