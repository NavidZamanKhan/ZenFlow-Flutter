class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://zenflow-5u3r.onrender.com';

  // Auth Endpoints
  static const String register = '/api/auth/register/';
  static const String verifyEmail = '/api/auth/verify-email/';
  static const String resendOtp = '/api/auth/resend-otp/';
  static const String login = '/api/auth/login/';
  static const String refresh = '/api/auth/refresh/';
  static const String googleAuth = '/api/auth/google/';
  static const String logout = '/api/auth/logout/';
  static const String me = '/api/auth/me/';
  static const String setPassword = '/api/auth/password/set/';
  static const String passwordOtp = '/api/auth/password/otp/';
  static const String passwordReset = '/api/auth/password/reset/';
  static const String deleteAccountOtp = '/api/auth/delete-account/otp/';
  static const String deleteAccount = '/api/auth/delete-account/';

  // Workspace endpoints
  static const String tasks = '/api/tasks/';
  static const String events = '/api/events/';
  static const String expenses = '/api/expenses/';
  static const String budget = '/api/budget/';
}
