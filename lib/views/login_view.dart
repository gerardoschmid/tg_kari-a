import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/local_provider.dart';
import '../utils/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Paleta compartida (igual que la del tema de main.dart)
// ─────────────────────────────────────────────────────────────────────────────
const _kPrimaryGreen = Color(0xFF4A7C44);
const _kErrorRed = Color(0xFFC62828);
const _kSuccessGreen = Color(0xFF2E7D32);

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  // ── Controladores Login ──────────────────────────────────────────────────
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  bool _loginPasswordVisible = false;

  // ── Controladores Register ───────────────────────────────────────────────
  final _regFormKey = GlobalKey<FormState>();
  final _regUsernameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();
  bool _regPasswordVisible = false;
  bool _regConfirmVisible = false;

  // ── Estado global ─────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _showRegister = false; // false = Login | true = Sign Up

  // ── Animación de transición ───────────────────────────────────────────────
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  // ─── Validadores ──────────────────────────────────────────────────────────

  String? _validateEmail(String? value, AppLocalizations local) {
    if (value == null || value.trim().isEmpty) return local.get('email_val');
    final trimVal = value.trim();
    if (trimVal == 'admin' || trimVal == 'bypass') return null;
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(trimVal)) return local.get('email_val');
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations local) {
    if (value == null || value.isEmpty) return local.get('pass_val');
    return null;
  }

  String? _validateRegPassword(String? value, AppLocalizations local) {
    if (value == null || value.length < 8) return local.get('pass_strength_val');
    if (!RegExp(r'\d').hasMatch(value)) return local.get('pass_strength_val');
    return null;
  }

  String? _validateUsername(String? value, AppLocalizations local) {
    if (value == null || value.trim().length < 3) return local.get('username_val');
    return null;
  }

  String? _validateConfirm(String? value, AppLocalizations local) {
    if (value != _regPasswordCtrl.text) return local.get('confirm_pass_val');
    return null;
  }

  // ─── Acciones ─────────────────────────────────────────────────────────────

  void _toggleMode() {
    setState(() {
      _showRegister = !_showRegister;
      if (_showRegister) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    });
  }

  Future<void> _handleLogin(AuthProvider auth, AppLocalizations local) async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final success = await auth.login(
        _loginEmailCtrl.text,
        _loginPasswordCtrl.text,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${local.get('correct')} Ayombo!'),
            backgroundColor: _kSuccessGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: _kErrorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister(AuthProvider auth, AppLocalizations local) async {
    if (!_regFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await auth.register(
        _regUsernameCtrl.text,
        _regEmailCtrl.text,
        _regPasswordCtrl.text,
      );
      if (mounted) {
        _showVerifyEmailDialog(local);
        // Limpiar campos tras registro exitoso
        _regUsernameCtrl.clear();
        _regEmailCtrl.clear();
        _regPasswordCtrl.clear();
        _regConfirmCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: _kErrorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showVerifyEmailDialog(AppLocalizations local) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF5E6D3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _kPrimaryGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_unread_rounded,
                  size: 44, color: _kPrimaryGreen),
            ),
            const SizedBox(height: 20),
            Text(
              local.get('verify_email_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              local.get('verify_email_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF795548),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                // Regresar al modo login
                if (_showRegister) _toggleMode();
              },
              child: Text(
                local.get('login_button'),
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(AuthProvider auth, AppLocalizations local) {
    final resetEmailCtrl =
        TextEditingController(text: _loginEmailCtrl.text);
    final dialogFormKey = GlobalKey<FormState>();
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFF5E6D3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            local.get('reset_title'),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
          ),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  local.get('reset_instructions'),
                  style: const TextStyle(color: Color(0xFF795548)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: resetEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: local.get('email'),
                    labelStyle: const TextStyle(color: Color(0xFF795548)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: _kPrimaryGreen, width: 2),
                    ),
                  ),
                  validator: (v) => _validateEmail(v, local),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isResetting ? null : () => Navigator.pop(context),
              child: Text(local.get('cancel'),
                  style: const TextStyle(
                      color: Color(0xFF795548), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isResetting
                  ? null
                  : () async {
                      if (!dialogFormKey.currentState!.validate()) return;
                      setDialogState(() => isResetting = true);
                      try {
                        await auth.sendResetEmail(resetEmailCtrl.text);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(local.get('reset_success')),
                              backgroundColor: _kSuccessGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: _kErrorRed,
                            ),
                          );
                        }
                      } finally {
                        setDialogState(() => isResetting = false);
                      }
                    },
              child: isResetting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(local.get('send'),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Widgets de campo reutilizables ───────────────────────────────────────

  Widget _buildGlassField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscure = false,
    bool? isVisible,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure && !(isVisible ?? false),
      textInputAction: textInputAction,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white60, size: 20),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  (isVisible ?? false) ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kPrimaryGreen, width: 1.5),
        ),
        errorStyle:
            const TextStyle(color: Color(0xFFFF8A80), fontSize: 11),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF8A80)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  // ─── Sección: Login ───────────────────────────────────────────────────────

  Widget _buildLoginForm(AuthProvider auth, AppLocalizations local) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGlassField(
            controller: _loginEmailCtrl,
            hint: local.get('email'),
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => _validateEmail(v, local),
          ),
          const SizedBox(height: 14),
          _buildGlassField(
            controller: _loginPasswordCtrl,
            hint: local.get('password'),
            icon: Icons.lock_outline,
            obscure: true,
            isVisible: _loginPasswordVisible,
            onToggleVisibility: () =>
                setState(() => _loginPasswordVisible = !_loginPasswordVisible),
            textInputAction: TextInputAction.done,
            validator: (v) => _validatePassword(v, local),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              elevation: 6,
              shadowColor: _kPrimaryGreen.withOpacity(0.4),
            ),
            onPressed:
                _isLoading ? null : () => _handleLogin(auth, local),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text(
                    local.get('login_button'),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.8),
                  ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () => _showForgotPasswordDialog(auth, local),
              child: Text(
                local.get('forgot_password'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sección: Sign Up ─────────────────────────────────────────────────────

  Widget _buildRegisterForm(AuthProvider auth, AppLocalizations local) {
    return Form(
      key: _regFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGlassField(
            controller: _regUsernameCtrl,
            hint: local.get('username'),
            icon: Icons.person_outline,
            validator: (v) => _validateUsername(v, local),
          ),
          const SizedBox(height: 14),
          _buildGlassField(
            controller: _regEmailCtrl,
            hint: local.get('email'),
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => _validateEmail(v, local),
          ),
          const SizedBox(height: 14),
          _buildGlassField(
            controller: _regPasswordCtrl,
            hint: local.get('password'),
            icon: Icons.lock_outline,
            obscure: true,
            isVisible: _regPasswordVisible,
            onToggleVisibility: () =>
                setState(() => _regPasswordVisible = !_regPasswordVisible),
            validator: (v) => _validateRegPassword(v, local),
          ),
          const SizedBox(height: 14),
          _buildGlassField(
            controller: _regConfirmCtrl,
            hint: local.get('confirm_password'),
            icon: Icons.lock_person_outlined,
            obscure: true,
            isVisible: _regConfirmVisible,
            onToggleVisibility: () =>
                setState(() => _regConfirmVisible = !_regConfirmVisible),
            textInputAction: TextInputAction.done,
            validator: (v) => _validateConfirm(v, local),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5E3C),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              elevation: 6,
              shadowColor: const Color(0xFF8B5E3C).withOpacity(0.4),
            ),
            onPressed:
                _isLoading ? null : () => _handleRegister(auth, local),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text(
                    local.get('register_button'),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.8),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Build principal ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final localProvider = Provider.of<LocalProvider>(context);
    final local = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── Fondo con imagen o gradiente de respaldo ─────────────────────
          Image.asset(
            'assets/images/background_login.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2E1A11),
                      Color(0xFF1C2E15),
                      Color(0xFF1C100A)
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Capa oscura semi-transparente ─────────────────────────────────
          Container(color: Colors.black.withOpacity(0.58)),

          // ── Selector de idioma ────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.language, color: Colors.white),
                    onSelected: (val) =>
                        localProvider.setLocale(Locale(val)),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'es', child: Text("Español")),
                      const PopupMenuItem(value: 'en', child: Text("English")),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Contenido central ─────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logotipo / Título
                    Text(
                      local.get('login_title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        shadows: [
                          Shadow(
                            blurRadius: 14.0,
                            color: Colors.black54,
                            offset: Offset(2.0, 3.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 80,
                      decoration: BoxDecoration(
                        color: _kPrimaryGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Modo actual: Login o Registro
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: Text(
                        _showRegister
                            ? local.get('register')
                            : 'Inicia sesión',
                        key: ValueKey(_showRegister),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Tarjeta glassmorphism ─────────────────────────────
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.18), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          final offset = _showRegister
                              ? const Offset(1, 0)
                              : const Offset(-1, 0);
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: offset,
                              end: Offset.zero,
                            ).animate(animation),
                            child: FadeTransition(
                                opacity: animation, child: child),
                          );
                        },
                        child: _showRegister
                            ? SizedBox(
                                key: const ValueKey('register'),
                                child: _buildRegisterForm(auth, local))
                            : SizedBox(
                                key: const ValueKey('login'),
                                child: _buildLoginForm(auth, local)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Alternancia Login / Registro ──────────────────────
                    GestureDetector(
                      onTap: _isLoading ? null : _toggleMode,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _showRegister
                              ? local.get('already_have_account')
                              : local.get('no_account'),
                          key: ValueKey(_showRegister),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Mensaje bypass ────────────────────────────────────
                    AnimatedOpacity(
                      opacity: _showRegister ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: _showRegister,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.yellow[800]?.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.yellow[800]!.withOpacity(0.35),
                                width: 1),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.yellow[600], size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    local.get('bypass_login'),
                                    style: TextStyle(
                                        color: Colors.yellow[200],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "User: bypass@karina.com / Pass: bypass123",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 11,
                                    fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}