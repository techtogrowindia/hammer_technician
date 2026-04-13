class LoginRequest {
  final String mobile;
  final String password;

  LoginRequest({
    required this.mobile,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "mobile": mobile,
      "password": password,
    };
  }
}
