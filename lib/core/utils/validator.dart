class Validator {
   static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    
    // Validasi khusus @gmail.com
    if (!value.trim().endsWith('@gmail.com')) {
      return 'Email harus menggunakan @gmail.com';
    }
    
    return null;
  }

   static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (value.length > 20) {
      return 'Password maksimal 20 karakter';
    }
    return null;
  }


  
  // ========== VALIDASI NAMA ==========
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    if (value.trim().length > 50) {
      return 'Nama maksimal 50 karakter';
    }
    if (RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Nama tidak boleh hanya berisi angka';
    }
    if (RegExp(r'[<>{}[\]\\\/]').hasMatch(value)) {
      return 'Nama mengandung karakter tidak diizinkan';
    }
    return null;
  }


 

 

  //
}
