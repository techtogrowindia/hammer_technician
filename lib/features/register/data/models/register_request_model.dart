class RegisterRequest {
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String passwordConfirmation;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "mobile": mobile,
        "password": password,
        "password_confirmation": passwordConfirmation,
      };
}
