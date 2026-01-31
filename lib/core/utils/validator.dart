class Validator {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    
    final email = value.trim();
    
    if (!email.endsWith('@gmail.com')) {
      return 'Email harus menggunakan @gmail.com';
    }
    
    final parts = email.split('@');
    if (parts.length != 2) return 'Format email tidak valid';
    
    final localPart = parts[0];
    
    if (localPart.length < 3) {
    }
    
    if (email.contains(' ')) {
      return 'Email tidak boleh mengandung spasi';
    }
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password wajib diisi';
    }
    
    final password = value.trim();
    
    if (password.length < 6) {
      return 'Password minimal 6 angka';
    }
    
    if (password.length > 20) {
      return 'Password maksimal 20 angka';
    }
    
    final numericRegex = RegExp(r'^[0-9]+$');
    if (!numericRegex.hasMatch(password)) {
      return 'Password hanya boleh berisi angka (0-9)';
    }
    
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi';
    }
    
    final name = value.trim();
    
    if (name.length < 2) {
      return 'Nama minimal 2 karakter';
    }
    
    if (name.length > 50) {
      return 'Nama maksimal 50 karakter';
    }
    
    if (RegExp(r'^\d+$').hasMatch(name)) {
      return 'Nama tidak boleh hanya berisi angka';
    }
    
    if (RegExp(r'[<>{}[\]\\\/]').hasMatch(name)) {
      return 'Nama mengandung karakter tidak diizinkan';
    }
    
    return null;
  }
}