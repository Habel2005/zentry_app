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
}
