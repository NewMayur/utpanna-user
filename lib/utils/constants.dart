class Constants {
  // Base URL for your API
  // static const String apiUrl = 'http://127.0.0.1:5000/';
  static const String apiUrl = 'http://192.168.131.92:5000/';

  // JWT token for authentication
  // Note: In a real app, this should be stored securely and updated dynamically
  static String jwtToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTcyNDU2ODkyMCwianRpIjoiYWM3ZWFhYjctY2QxNy00N2I0LWIzNzUtMTZkZGNkYjI1YTkzIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6MSwibmJmIjoxNzI0NTY4OTIwLCJjc3JmIjoiMjQ1MzkwZjQtYTdmZC00ZjEyLTgyOWYtYTQ3ZjFjYzU2NTZmIiwiZXhwIjoxNzI0NTY5ODIwfQ.PI9ikPL7DFHb5RBIfBaHA6GLBWwJYZETaWwbHuBa2F4';

  // Method to update the JWT token
  static void updateJwtToken(String newToken) {
    jwtToken = newToken;
  }

  // Other constants can be added here
  static const int timeoutDuration = 30; // in seconds
  static const String appName = 'Utpanna';
}