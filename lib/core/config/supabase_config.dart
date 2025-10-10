class SupabaseConfig {
  // Supabase project credentials
  static const String url = 'https://zkixtbwolqbafehlouyg.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpraXh0YndvbHFiYWZlaGxvdXlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNDE3MzIsImV4cCI6MjA3NTYxNzczMn0.afMgWOaqTIs39-hxllcGvSA492XrHCrFthvekw0roh4';
  
  // Database table names
  static const String agenciesTable = 'agencies';
  static const String projectsTable = 'projects';
  static const String fundFlowTable = 'fund_flow';
  static const String milestonesTable = 'milestones';
  static const String usersTable = 'users';
  static const String auditTrailTable = 'audit_trail';
  static const String chatChannelsTable = 'chat_channels';
  static const String chatMessagesTable = 'chat_messages';
  static const String ticketsTable = 'tickets';
  static const String documentsTable = 'documents';
  static const String meetingsTable = 'meetings';
  
  // Storage buckets
  static const String documentsBucket = 'documents';
  static const String imagesBucket = 'images';
  static const String evidenceBucket = 'evidence';
  
  // Real-time channels
  static const String fundFlowChannel = 'fund_flow_updates';
  static const String projectUpdatesChannel = 'project_updates';
  static const String chatChannel = 'chat_updates';
  static const String notificationsChannel = 'notifications';
}
