import 'models/call_detail.dart';
import 'models/call_list_item.dart';
import 'models/dashboard_overview.dart';
import 'supabase_service.dart';

class Queries {
  static Future<DashboardOverview> getDashboardOverview() async {
    final response = await SupabaseService.client
        .from('admin_calls_overview')
        .select()
        .single();

    return DashboardOverview.fromJson(response);
  }

  static Future<List<CallListItem>> getCallList() async {
    final response = await SupabaseService.client.from('call_list_view').select();

    return (response as List).map((item) => CallListItem.fromJson(item)).toList();
  }

  static Future<CallDetail> getCallDetails(String callId) async {
    final response = await SupabaseService.client
        .from('call_details_view')
        .select('*, messages:call_messages(*), processing_steps:ai_processing_steps(*)')
        .eq('call_id', callId)
        .single();

    return CallDetail.fromJson(response);
  }
}
