import '../domain/dashboard_data.dart';

abstract interface class DashboardRepository {
  Future<DashboardData> fetchDashboard();
}
