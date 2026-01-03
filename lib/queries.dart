import 'dart:developer';

import 'models/call_detail.dart';
import 'models/call_list_item.dart';
import 'models/dashboard_overview.dart';
import 'supabase_service.dart';

class Queries {
  static Future<DashboardOverview> getDashboardOverview() async {
    try {
      final response = await SupabaseService.client
          .from('admin_calls_overview')
          .select()
          .single();

      return DashboardOverview.fromJson(response);
    } catch (e, s) {
      log('Error fetching dashboard overview', error: e, stackTrace: s);
      rethrow;
    }
  }

  static Future<List<CallListItem>> getCallList() async {
    try {
      final response = await SupabaseService.client.from('admin_call_list').select();
      return (response as List).map((item) => CallListItem.fromJson(item)).toList();
    } catch (e, s) {
      log('Error fetching call list', error: e, stackTrace: s);
      rethrow;
    }
  }

  static Future<CallDetail> getCallDetails(String callId) async {
    try {
      final response = await SupabaseService.client
          .from('admin_call_detail')
          .select()
          .eq('call_id', callId);

      // Since the view might return multiple rows for a single call (due to joins),
      // we'll fetch the list and then process it into a single CallDetail object.
      if (response.isEmpty) {
        throw Exception('Call not found');
      }

      return CallDetail.fromJson(response);
    } catch (e, s) {
      log('Error fetching call details for callId: $callId', error: e, stackTrace: s);
      rethrow;
    }
  }
}
