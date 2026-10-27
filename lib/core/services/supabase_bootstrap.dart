import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import 'logger_service.dart';

abstract final class SupabaseBootstrap {
  static bool _isReady = false;

  static bool get isReady => _isReady;

  static Future<void> initialize() async {
    if (!AppConstants.isSupabaseConfigured) {
      LoggerService.warning(
        'Supabase is not configured. Running in local-only mode.',
      );
      return;
    }

    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        publishableKey: AppConstants.supabaseAnonKey,
      );
      _isReady = true;
      LoggerService.info('Supabase initialized');
    } on Object catch (error, stackTrace) {
      LoggerService.error(
        'Supabase initialization failed. Running in local-only mode.',
        error,
        stackTrace,
      );
    }
  }
}
