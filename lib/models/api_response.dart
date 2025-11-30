class ApiResponse {
  final bool status;
  final dynamic data;
  final String message;
  final int? code;

  ApiResponse({
    required this.status,
    required this.data,
    required this.message,
    this.code,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] == 200 || json['status'] == true,
      data: json['data'],
      message: json['message'] ?? "",
      code: json['status'] is int ? json['status'] : 0,
    );
  }
}
