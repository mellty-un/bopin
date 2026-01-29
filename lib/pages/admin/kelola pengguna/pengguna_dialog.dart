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
        await PenggunaService.updatePengguna(
          idUser: widget.pengguna!.idUser,
          nama: _nameController.text.trim(),
          role: _selectedRole!,
          email: _emailController.text.trim(),
        );
      } else {
        await PenggunaService.createPengguna(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          nama: _nameController.text.trim(),
          role: _selectedRole!,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
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
                    hintText: 'Masukkan nama lengkap',
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
                          hintText: 'namasaya123456@gmail.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email harus diisi';
                          }
                          
                          // Wajib @gmail.com
                          if (!value.endsWith('@gmail.com')) {
                            return 'Email harus menggunakan @gmail.com';
                          }
                          
                          final parts = value.split('@');
                          if (parts.length != 2) return 'Format tidak valid';
                          
                          final beforeAt = parts[0];
                          
                          // **SUPABASE MINIMAL 6 KARAKTER SEBELUM @**
                          if (beforeAt.length < 6) {
                            return 'Minimal 6 karakter sebelum @\n'
                                   'Saran: ${beforeAt}123456@gmail.com';
                          }
                          
                          if (value.contains(' ')) {
                            return 'Email tidak boleh mengandung spasi';
                          }
                          
                          return null;
                        },
                      ),
                
             
                // Form Password (hanya untuk tambah)
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
                      hintText: 'Masukkan 6-20 angka',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Icon(Icons.lock, size: 20),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Hanya angka 0-9, minimal 6 digit',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
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