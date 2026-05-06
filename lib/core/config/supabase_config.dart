import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    try {
      const envFiles = ['.env', '.env.local'];
      var loadedFile = '';

      for (final fileName in envFiles) {
        try {
          print('🔧 Supabase: Loading $fileName...');
          await dotenv.load(fileName: fileName);
          loadedFile = fileName;
          break;
        } catch (_) {
          // Try the next supported env filename.
        }
      }

      if (loadedFile.isEmpty) {
        throw Exception(
          'No supported env file found. Expected one of: ${envFiles.join(', ')}',
        );
      }

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['PUBLIC_SUPABASE_ANON_KEY'];

      print('🔧 Supabase env file: $loadedFile');
      print('🔧 Supabase URL: $supabaseUrl');
      print('🔧 Supabase Key: ${supabaseAnonKey?.substring(0, 20)}...');

      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception('Supabase credentials not found in .env');
      }

      print('🔧 Supabase: Initializing client...');
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      print('✅ Supabase: Initialized successfully!');
      print('🔧 Supabase REST URL: ${client.rest.url}');
      print('🔧 Supabase Auth Session: ${client.auth.currentSession == null ? 'none' : 'present'}');
    } catch (e, stackTrace) {
      print('❌ Supabase initialization error: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
