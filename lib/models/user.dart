class User {
  final String login;
  final String password;

  User({required this.login, required this.password});

  Map<String, dynamic> toJson() => {
    'login': login,
    'password': password,
  };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['login'],
      password: json['password'],
    );
  }
}
