class PenggunaModel {
  final String idUser;
  final String nama;
  final String role;
  final String? email;
  final DateTime? createdAt;

  PenggunaModel({
    required this.idUser,
    required this.nama,
    required this.role,
    this.email,
    this.createdAt,
  });

  // From JSON (dari Supabase)
  factory PenggunaModel.fromJson(Map<String, dynamic> json) {
    return PenggunaModel(
      idUser: json['id_user'] as String,
      nama: json['nama'] as String? ?? '',
      role: json['role'] as String? ?? 'peminjam',
      email: json['email'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // To JSON (untuk kirim ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'nama': nama,
      'role': role,
      if (email != null) 'email': email,
    };
  }

  // Copy with (untuk update data)
  PenggunaModel copyWith({
    String? idUser,
    String? nama,
    String? role,
    String? email,
    DateTime? createdAt,
  }) {
    return PenggunaModel(
      idUser: idUser ?? this.idUser,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Getter untuk role yang sudah diformat
  String get roleFormatted {
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }

  // Getter untuk initial
  String get initial {
    return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
  }
}