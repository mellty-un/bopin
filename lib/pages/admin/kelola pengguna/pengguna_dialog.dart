import 'package:aplikasi_peminjaman_alat/core/services/pengguna_service.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/validator.dart';
import 'package:aplikasi_peminjaman_alat/models/pengguna_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PenggunaDialog extends StatefulWidget {
  final PenggunaModel? pengguna;
  final bool isEdit;

  const PenggunaDialog({super.key, this.pengguna, this.isEdit = false});

  @override
  State<PenggunaDialog> createState() => _PenggunaDialogState();
}

class _PenggunaDialogState extends State<PenggunaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<String> _roleOptions = ['Admin', 'Petugas', 'Peminjam'];
  String? _selectedRole;

  bool _isLoading = false;
  bool _loadingEmail = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.pengguna != null) {
      _nameController.text = widget.pengguna!.nama;
      _selectedRole = widget.pengguna!.roleFormatted;
      
      if (widget.pengguna!.email != null && widget.pengguna!.email!.isNotEmpty) {
        _emailController.text = widget.pengguna!.email!;
      } else {
        _loadUserEmail();
      }
    }
  }

  Future<void> _loadUserEmail() async {
    if (widget.pengguna == null) return;
    
    setState(() => _loadingEmail = true);
    
    try {
      final detail = await PenggunaService.getPenggunaDetail(widget.pengguna!.idUser);
      if (mounted) {
        setState(() {
          _emailController.text = detail['email'] ?? '';
          _loadingEmail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingEmail = false;
          _emailController.text = '';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==================== FIXED _savePengguna FUNCTION ====================
  Future<void> _savePengguna() async {
    setState(() => _errorMessage = null);

    if (_selectedRole == null) {
      setState(() => _errorMessage = 'Role harus dipilih');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.isEdit) {
        final email = _emailController.text.trim().toLowerCase();
        final role = _selectedRole!.toLowerCase();
        
        await PenggunaService.updatePengguna(
          idUser: widget.pengguna!.idUser,
          nama: _nameController.text.trim(),
          role: role,
          email: email,
        );
        
        print('✅ Update berhasil: ${widget.pengguna!.idUser}');
      } else {
        final email = _emailController.text.trim().toLowerCase();
        final password = _passwordController.text.trim();
        final nama = _nameController.text.trim();
        final role = _selectedRole!.toLowerCase();
        
        if (email.isEmpty) {
          throw Exception('Email tidak boleh kosong');
        }
        
        if (password.isEmpty) {
          throw Exception('Password tidak boleh kosong');
        }
        
        if (nama.isEmpty) {
          throw Exception('Nama tidak boleh kosong');
        }
        
        if (!email.endsWith('@gmail.com')) {
          throw Exception('Email harus menggunakan @gmail.com');
        }
        
        final localPart = email.split('@')[0];
        if (localPart.length < 6) {
          throw Exception('Email minimal 6 karakter sebelum @\nContoh: ${localPart}123456@gmail.com');
        }
        
        print('🔄 Membuat pengguna: $email, role: $role');
        
        final userId = await PenggunaService.createPengguna(
          email: email,
          password: password,
          nama: nama,
          role: role,
        );
        
        print('✅ Create berhasil, user ID: $userId');
      }

      if (!mounted) return;
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      Navigator.of(context).pop(true);
      
    } catch (e) {
      if (!mounted) return;
      
      print('❌ Error di _savePengguna: $e');
      
      String errorMessage = e.toString();
      
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      if (errorMessage.contains('already registered') || 
          errorMessage.contains('Email sudah terdaftar')) {
        errorMessage = 'Email sudah terdaftar di sistem';
      }
      
      if (errorMessage.contains('Password minimal')) {
        errorMessage = 'Password minimal 6 angka';
      }
      
      if (errorMessage.contains('minimal 6 karakter')) {
        errorMessage = 'Email minimal 6 karakter sebelum @\nContoh: nama123456@gmail.com';
      }
      
      setState(() {
        _isLoading = false;
        _errorMessage = errorMessage;
      });
      
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _errorMessage == errorMessage) {
          setState(() => _errorMessage = null);
        }
      });
    }
  }

  // ==================== VALIDASI EMAIL YANG FIXED ====================
  String? _validateEmail(String? value) {
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
    final domain = parts[1];
    
    if (localPart.length < 6) {
      return 'Email terlalu pendek.\nMinimal 6 karakter sebelum @\nSaran: ${localPart}123456@gmail.com';
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.isEdit ? 'Edit Pengguna' : 'Tambah Pengguna',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Form Nama
                const Text(
                  'Nama',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) => Validator.name(value),
                ),
                const SizedBox(height: 16),

                // Form Role
                const Text(
                  'Role',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: _roleOptions.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Role harus dipilih' : null,
                ),
                const SizedBox(height: 16),

                // Form Email
                const Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                _loadingEmail
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : TextFormField(
                        controller: _emailController,
                        enabled: true,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: _validateEmail,
                      ),
                
                if (!widget.isEdit) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Kata Sandi',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      hintText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: const Icon(Icons.lock, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword 
                              ? Icons.visibility_off 
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) => Validator.password(value),
                  ),
                  
                ],

                const SizedBox(height: 24),

                // Tombol
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          side: const BorderSide(color: Color(0xFF3A587A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Color(0xFF3A587A)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _savePengguna,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A587A),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Simpan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}