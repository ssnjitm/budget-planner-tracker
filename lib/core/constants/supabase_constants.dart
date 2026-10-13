export '../database/tables.dart';

abstract final class SupabaseConstants {
  static const authCallbackScheme = 'io.supabase.pocketbudget';
  static const authCallbackUrl = '$authCallbackScheme://login-callback';
}
