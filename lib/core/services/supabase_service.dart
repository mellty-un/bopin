import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://kecqmrefrthmuoldpufg.supabase.co',     
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtlY3FtcmVmcnRobXVvbGRwdWZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgzMzY3MTIsImV4cCI6MjA4MzkxMjcxMn0.EzoVEl9z7Y4zq9vlk9bGpYwFIx4xDz7xiEhDzjd66ZA',     
    );
  }

  static SupabaseClient get client =>
      Supabase.instance.client;

  static String handleError(dynamic error) {
    if (error is PostgrestException) {
      return error.message;
    } else if (error is AuthException) {
      return error.message;
    } else {
      return 'Terjadi kesalahan: ${error.toString()}';
    }
  }

    static String getStorageUrl(String fileName) {
    return 'https://kecqmrefrthmuoldpufg.supabase.co/storage/v1/object/public/alat-images/$fileName';
  }

}
