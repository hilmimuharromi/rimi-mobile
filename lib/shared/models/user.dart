import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    this.phone,
    this.email,
    this.fullName,
    this.referralCode,
    this.role = 'member',
    this.isActive = true,
  });

  final String id;
  final String? phone;
  final String? email;
  final String? fullName;
  final String? referralCode;
  final String role;
  final bool isActive;

  String get displayName => fullName?.isNotEmpty == true
      ? fullName!
      : (email ?? phone ?? 'Member Rimi');

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      referralCode: json['referral_code'] as String?,
      role: json['role'] as String? ?? 'member',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'email': email,
        'full_name': fullName,
        'referral_code': referralCode,
        'role': role,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [id, phone, email, fullName, referralCode, role, isActive];
}

class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

class AuthSession extends Equatable {
  const AuthSession({
    required this.tokens,
    required this.user,
  });

  final AuthTokens tokens;
  final User user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      tokens: AuthTokens.fromJson(json),
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  List<Object?> get props => [tokens, user];
}
