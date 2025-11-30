class LoginResponse {
  final bool status;
  final String token;
  final String userEmail;
  final int userId;

  LoginResponse({
    required this.status,
    required this.token,
    required this.userEmail,
    required this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final user = data['user'] ?? {};

    return LoginResponse(
      status: json['status'] == 200, // <--- DI SINI FIX-NYA
      token: data['token'] ?? "",
      userEmail: user['email'] ?? "",
      userId: int.tryParse(user['id'].toString()) ?? 0,
    );
  }
}
