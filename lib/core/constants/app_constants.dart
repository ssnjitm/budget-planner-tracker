abstract final class AppConstants {
  static const appName = 'PocketBudget';
  static const appVersion = '1.0.0';
  static const defaultCurrency = 'NPR';

  static const databaseName = 'pocketbudget.db';
  static const databaseVersion = 4;

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isSupabaseConfigured =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  static const supabaseSessionKey = 'pb.supabase.session';
  static const userIdKey = 'pb.user.id';
  static const onboardedKey = 'pb.onboarded';
  static const settingsKey = 'pb.user_settings';

  static const cloudSyncEnabled = false;
  static const syncBatchSize = 50;
  static const syncMaxAttempts = 10;
}
