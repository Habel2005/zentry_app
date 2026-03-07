import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/dashboard_data.dart';
import 'models/call_detail.dart';
import 'models/admin_call_list.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Supabase URL or Anon Key not found in .env file');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  SupabaseClient get client => Supabase.instance.client;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  User? get currentUser => client.auth.currentUser;

  Future<void> signIn(String email, String password) async {
    try {
      await client.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      log('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<DashboardData> getDashboardData() async {
    try {
      final response = await client
          .from('admin_calls_overview')
          .select()
          .order('day', ascending: false)
          .limit(1)
          .single();
      return DashboardData.fromJson(response);
    } catch (e) {
      log('Error fetching dashboard data: $e');
      return DashboardData(totalCalls: 0, ongoingCalls: 0, droppedCalls: 0, aiCalls: 0, humanCalls: 0, sttGood: 0, sttLow: 0, sttFailed: 0);
    }
  }

Future<List<Map<String, dynamic>>> getTopCallerIntents() async {
    try {
      // 1. Find the most recent date we have data for
      final latestDateResponse = await client
          .from('call_intents')
          .select('created_at')
          .order('created_at', ascending: false)
          .limit(1);

      if ((latestDateResponse as List).isEmpty) return [];

      // 2. Extract the day from that latest record
      final latestDate = DateTime.parse(latestDateResponse[0]['created_at']);
      final startOfLatestDay = DateTime(latestDate.year, latestDate.month, latestDate.day);

      // 3. Fetch all intents for that specific day
      final response = await client
          .from('call_intents')
          .select('intent')
          .filter('created_at', 'gte', startOfLatestDay.toIso8601String());

      if ((response as List).isEmpty) return [];

      final intentCounts = <String, int>{};
      for (final item in response) {
        final intent = item['intent'] as String;
        intentCounts[intent] = (intentCounts[intent] ?? 0) + 1;
      }

      final sortedIntents = intentCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final totalIntents = sortedIntents.fold<int>(0, (sum, e) => sum + e.value);
      if (totalIntents == 0) return [];

      return sortedIntents
          .take(5)
          .map((e) => {
                'intent': e.key,
                'value': (e.value / totalIntents) * 100,
              })
          .toList();
    } catch (e) {
      log('Error fetching top caller intents: $e');
      return [];
    }
  }

  Future<Map<String, double>> getAiPipelineLatency() async {
    try {
      // 1. Find the most recent date we have latency data for
      final latestDateResponse = await client
          .from('ai_processing_steps')
          .select('created_at')
          .filter('latency_ms', 'not.is', 'null')
          .order('created_at', ascending: false)
          .limit(1);

      if ((latestDateResponse as List).isEmpty) {
        return {'STT': 0.0, 'LLM': 0.0, 'TTS': 0.0};
      }

      // 2. Extract the day from that latest record
      final latestDate = DateTime.parse(latestDateResponse[0]['created_at']);
      final startOfLatestDay = DateTime(latestDate.year, latestDate.month, latestDate.day);

      // 3. Fetch all latencies for that specific day
      final response = await client
          .from('ai_processing_steps')
          .select('step_type, latency_ms')
          .filter('latency_ms', 'not.is', 'null')
          .filter('created_at', 'gte', startOfLatestDay.toIso8601String());

      final latencies = <String, List<int>>{};
      for (final item in response as List<dynamic>) {
        final stepType = (item['step_type'] as String).toLowerCase();
        final latency = item['latency_ms'] as int;
        if (!latencies.containsKey(stepType)) {
          latencies[stepType] = [];
        }
        latencies[stepType]!.add(latency);
      }

      final avgLatencies = <String, double>{};
      latencies.forEach((key, value) {
        if (value.isNotEmpty) {
          avgLatencies[key] = value.reduce((a, b) => a + b) / value.length;
        } else {
          avgLatencies[key] = 0.0;
        }
      });

      return {
        'STT': avgLatencies['stt'] ?? 0.0,
        'LLM': avgLatencies['llm'] ?? avgLatencies['brain'] ?? 0.0,
        'TTS': avgLatencies['tts'] ?? 0.0,
      };
    } catch (e) {
      log('Error fetching AI pipeline latency: $e');
      return {'STT': 0.0, 'LLM': 0.0, 'TTS': 0.0};
    }
  }
  
  Future<List<AdminCallList>> getCallList() async {
    try {
      final response = await client
          .from('admin_call_list')
          .select();
       final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => AdminCallList.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      log('Error fetching call list: $e');
      rethrow;
    }
  }

  Future<CallDetail?> getCallDetails(String callId) async {
    try {
      final response = await client
          .from('admin_call_detail')
          .select()
          .eq('call_id', callId)
          .maybeSingle();

      if (response == null) {
        return null;
      }
      return CallDetail.fromJson(response);
    } catch (e) {
      log('Error fetching call details: $e');
      rethrow;
    }
  }

  Future<int> getPendingConsultationsCount() async {
    try {
      final response = await client
          .from('consultation_requests')
          .select('id')
          .eq('status', 'pending');
          
      return (response as List).length;
    } catch (e) {
      log('Error fetching pending consultations: $e');
      return 0; // Failsafe so UI doesn't crash
    }
  }

  Future<Map<String, dynamic>?> getFullCallDetails(String callId) async {
    try {
      // 1. Get Session Data (We removed the caller_profiles join, phone_hash is already here!)
      final sessionResponse = await client
          .from('call_sessions')
          .select() // Just select everything from the session row
          .eq('id', callId)
          .maybeSingle();

      if (sessionResponse == null) return null;

      // 2. Get Transcript (Ordered correctly)
      final messagesResponse = await client
          .from('call_messages')
          .select()
          .eq('call_id', callId)
          .order('created_at', ascending: true);

      // 3. Get AI Health Data (Latencies)
      final stepsResponse = await client
          .from('ai_processing_steps')
          .select('step_type, latency_ms, status')
          .eq('call_id', callId);

      // 4. Get Consultation Status (Did they ask for a human?)
      final consultResponse = await client
          .from('consultation_requests')
          .select('status')
          .eq('call_id', callId)
          .maybeSingle();

      return {
        'session': sessionResponse,
        'messages': messagesResponse as List<dynamic>,
        'ai_steps': stepsResponse as List<dynamic>,
        'consultation_status': consultResponse?['status'] ?? 'None',
      };
    } catch (e) {
      log('Error fetching full call details: $e');
      return null;
    }
  }

  // Get the specific interests triggered during THIS exact call
  Future<List<dynamic>> getInterestsForCall(String callId) async {
    try {
      final response = await client
          .from('interest_signals')
          .select('program_code, quota_type, strength')
          .eq('call_id', callId);
      return response as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  // Get the last 4 messages of the transcript to give the admin context
  Future<List<dynamic>> getTranscriptSnippet(String callId) async {
    try {
      final response = await client
          .from('call_messages')
          .select('speaker, raw_text')
          .eq('call_id', callId)
          .order('created_at', ascending: false) // Get newest first
          .limit(4);
      return (response as List<dynamic>).reversed.toList(); // Reverse to read top-to-bottom
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getCallerProfiles() async {
    try {
      final response = await client
          .from('caller_profiles')
          .select()
          .order('last_seen', ascending: false);
      return response as List<dynamic>;
    } catch (e) {
      log('Error fetching caller profiles: $e');
      return [];
    }
  }

  Future<List<dynamic>> getCallerInterests(String callerId) async {
    try {
      final response = await client
          .from('interest_signals')
          .select('program_code, quota_type, strength, created_at')
          .eq('caller_id', callerId)
          .order('created_at', ascending: false);
      return response as List<dynamic>;
    } catch (e) {
      log('Error fetching caller interests: $e');
      return [];
    }
  }

  // Fetch all consultations, ordered by newest first
  Future<List<dynamic>> getConsultationRequests() async {
    try {
      final response = await client
          .from('consultation_requests')
          .select()
          .order('created_at', ascending: false);
      return response as List<dynamic>;
    } catch (e) {
      log('Error fetching consultations: $e');
      return [];
    }
  }

  // Update the status of a consultation (pending -> contacted -> resolved)
  Future<void> updateConsultationStatus(String id, String status) async {
    try {
      await client
          .from('consultation_requests')
          .update({'status': status})
          .eq('id', id);
    } catch (e) {
      log('Error updating consultation status: $e');
      rethrow;
    }
  }
}
