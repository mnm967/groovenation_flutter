class AuthUser {
  final String? userId;
  final String? username;
  final String? userCity;
  final String? profilePicUrl;
  final String? coverPicUrl;
  final String? authToken;

  AuthUser(this.userId, this.username, this.userCity, this.profilePicUrl,
      this.coverPicUrl, this.authToken);

  factory AuthUser.fromJson(dynamic json) {
    return AuthUser(
      json['userId'],
      json['username'],
      json['userCity'],
      json['profilePicUrl'],
      json['coverPicUrl'],
      json['auth_token'],
    );
  }
}
