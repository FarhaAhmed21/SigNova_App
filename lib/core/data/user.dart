import 'package:shared_preferences/shared_preferences.dart';

class User {
  String? id;
  String? userName;
  String? email;
  String? phone;
  String? password;
  String? avatarUrl;
  String? accessToken;
  String? refreshToken;
  bool? isDeaf;
  String? dob;
  String? gender;

  static final User _instance = User._internal();
  factory User() => _instance;
  User._internal();

  Future<void> update({
    String? id,
    String? userName,
    String? email,
    String? avatarUrl,
    String? accessToken,
    String? refreshToken,
    bool? isDeaf,
    String? phone,
    String? dob,
    String? gender,
  }) async {
    this.id = id ?? this.id;
    this.userName = userName ?? this.userName;
    this.email = email ?? this.email;
    this.avatarUrl = avatarUrl ?? this.avatarUrl;
    this.accessToken = accessToken ?? this.accessToken;
    this.refreshToken = refreshToken ?? this.refreshToken;
    this.isDeaf = isDeaf ?? this.isDeaf;
    this.phone = phone ?? this.phone;
    this.dob = dob ?? this.dob;
    this.gender = gender ?? this.gender;

    final prefs = await SharedPreferences.getInstance();
    if (this.id != null) await prefs.setString('id', this.id!);
    if (this.userName != null) {
      await prefs.setString('userName', this.userName!);
    }
    if (this.email != null) {
      await prefs.setString('email', this.email!);
    }
    if (this.avatarUrl != null) {
      await prefs.setString('avatarUrl', this.avatarUrl!);
    }
    if (this.accessToken != null) {
      await prefs.setString('accessToken', this.accessToken!);
    }
    if (this.refreshToken != null) {
      await prefs.setString('refreshToken', this.refreshToken!);
    }
    if (this.isDeaf != null) {
      await prefs.setBool('isDeaf', this.isDeaf!);
    }
    if (this.phone != null) {
      await prefs.setString('phone', this.phone!);
    }
    if (this.dob != null) {
      await prefs.setString('dob', this.dob!);
    }
    if (this.gender != null) {
      await prefs.setString('gender', this.gender!);
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id');
    userName = prefs.getString('userName');
    email = prefs.getString('email');
    avatarUrl = prefs.getString('avatarUrl');
    accessToken = prefs.getString('accessToken');
    refreshToken = prefs.getString('refreshToken');
    isDeaf = prefs.getBool('isDeaf');
    phone = prefs.getString('phone');
    dob = prefs.getString('dob');
    gender = prefs.getString('gender');
  }

  Future<void> clear() async {
    id = null;
    userName = null;
    email = null;
    avatarUrl = null;
    accessToken = null;
    refreshToken = null;
    isDeaf = null;
    phone = null;
    dob = null;
    gender = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('userName');
    await prefs.remove('email');
    await prefs.remove('avatarUrl');
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('isDeaf');
    await prefs.remove('phone');
    await prefs.remove('dob');
    await prefs.remove('gender');
  }
}
