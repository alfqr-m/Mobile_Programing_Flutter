import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

// Refactoring: InheritedWidget + StatefulWidget diganti satu kelas ChangeNotifier
class UserProvider extends ChangeNotifier {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];
  bool _disposed = false;

  UserProvider() {
    loadUser();
  }

  // Getter yang dibaca oleh widget
  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;
  List<String> get favorites => _favorites;

  // Memuat data dari SharedPreferences
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    final visitCount = (prefs.getInt('visit_count') ?? 0) + 1;
    await prefs.setInt('visit_count', visitCount);
    final favorites = prefs.getStringList('favorites') ?? <String>[];

    _user = User(name: name, email: email, isLoggedIn: isLoggedIn);
    _isDarkMode = isDarkMode;
    _visitCount = visitCount;
    _favorites = favorites;
    _isLoading = false;
    notifyListeners();
  }

  // Menyimpan data user ke SharedPreferences
  Future<void> updateUser(User newUser) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);

    _user = newUser;
    _isLoading = false;
    notifyListeners();
  }

  // Logout: hapus data user (kecuali email)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);

    _user = _user.copyWith(name: '', isLoggedIn: false);
    notifyListeners();
  }

  // Ganti tema lalu simpan preferensinya
  Future<void> toggleTheme() async {
    final newValue = !_isDarkMode;
    _isDarkMode = newValue;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', newValue);
  }

  // Tambah favorit
  Future<void> addFavorite(String item) async {
    _favorites = [..._favorites, item];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
  }

  // Hapus favorit
  Future<void> removeFavorite(String item) async {
    _favorites = _favorites.where((f) => f != item).toList();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
  }

  // Pengaman: jangan memberi tahu listener setelah provider dibuang
  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}