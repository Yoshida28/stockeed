class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://nxasokoyzfomjbupwnlp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54YXNva295emZvbWpidXB3bmxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5ODU1NjEsImV4cCI6MjA2NzU2MTU2MX0.vMRdJLA8pcDVH_A0INVFP2EiYk2vpAZTsoUp0pdny9s';

  // User Roles
  static const String roleDistributor = 'distributor';
  static const String roleRetailClient = 'retail_client';

  // Sync Status
  static const String syncStatusPending = 'pending_sync';
  static const String syncStatusSynced = 'synced';
  static const String syncStatusFailed = 'sync_failed';

  // Default Values
  static const double defaultGstRate = 18.0;
  static const int defaultLowStockThreshold = 10;

  // App Information
  static const String appName = 'Stocked';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Powerful business management app for distributors and retail clients';
}
