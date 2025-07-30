// File: lib/models/user_model.dart

import 'package:supabase_flutter/supabase_flutter.dart';

/// Model yang merepresentasikan data user dalam aplikasi kita
/// 
/// Class ini berfungsi sebagai wrapper yang menyimpan informasi penting
/// dari Supabase User object dalam format yang lebih mudah digunakan
/// di seluruh aplikasi kita
class Authuser {
  const Authuser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.provider,
    this.createdAt,
    this.lastSignInAt,
  });

  /// ID unik user dari Supabase
  final String id;
  
  /// Email address user yang terverifikasi
  final String email;
  
  /// Nama lengkap user dari provider OAuth (Google)
  final String? name;
  
  /// URL foto profil user dari provider OAuth
  final String? photoUrl;
  
  /// Provider yang digunakan untuk sign in (google, email, dll)
  final String? provider;
  
  /// Timestamp ketika user pertama kali mendaftar
  final DateTime? createdAt;
  
  /// Timestamp terakhir kali user melakukan sign in
  final DateTime? lastSignInAt;

  /// Factory constructor untuk membuat Authuser dari Supabase User object
  /// 
  /// Fungsi ini mengekstrak data yang diperlukan dari complex User object
  /// dan mengubahnya menjadi format yang lebih sederhana dan konsisten
  factory Authuser.fromSupabaseUser(User user) {
    // Mengekstrak data dari userMetadata yang bisa berbeda-beda
    // tergantung provider OAuth yang digunakan
    final metadata = user.userMetadata ?? {};
    
    return Authuser(
      id: user.id,
      email: user.email ?? '',
      // Google bisa mengirim nama dengan key 'full_name' atau 'name'
      name: metadata['full_name'] as String? ?? 
            metadata['name'] as String?,
      // Google biasanya mengirim foto dengan key 'avatar_url' atau 'picture'
      photoUrl: metadata['avatar_url'] as String? ?? 
                metadata['picture'] as String?,
      // Mengambil provider dari app metadata
      provider: user.appMetadata['provider'] as String?,
      createdAt: user.createdAt != null ? DateTime.parse(user.createdAt!) : null,
      lastSignInAt: user.lastSignInAt != null ? DateTime.parse(user.lastSignInAt!) : null,
    );
  }

  /// Method untuk membuat copy dari object dengan beberapa field yang diubah
  /// 
  /// Berguna untuk update data user tanpa harus membuat object baru sepenuhnya
  Authuser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? provider,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return Authuser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  /// Method untuk mendapatkan initial atau huruf pertama nama
  /// Berguna untuk menampilkan avatar dengan huruf jika tidak ada foto
  String get initials {
    if (name == null || name!.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : '?';
    }
    
    final words = name!.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }

  /// Method untuk mendapatkan display name yang user-friendly
  String get displayName => name ?? email;

  @override
  String toString() {
    return 'Authuser(id: $id, email: $email, name: $name, provider: $provider)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Authuser &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.photoUrl == photoUrl &&
        other.provider == provider;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, name, photoUrl, provider);
  }
}