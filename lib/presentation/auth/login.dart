import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenify/services/api.dart';
import 'package:zenify/services/user_session.dart';
import 'package:zenify/services/user_data_cache.dart';
import 'package:zenify/routes/app_routes.dart';
import 'package:zenify/utils/toast_helper.dart';
import 'package:zenify/utils/error_message_helper.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  static const String _rememberUsernameKey = 'auth_remember_username';
  static const String _savedUsernameKey = 'auth_saved_username';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _isLoading = false;
  bool _isLoginMode = true; // 切换登录/注册模式
  bool _obscurePassword = true;
  bool _rememberUsername = true;

  @override
  void initState() {
    super.initState();
    _loadRememberedUsername();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final username = _nameController.text.trim();
      final password = _passwordController.text;
      final email = _emailController.text.trim();
      final fullName = _fullNameController.text.trim();

      dynamic response;
      if (_isLoginMode) {
        response = await Api.login(
          LoginRequest(
            name: username,
            password: password,
          ),
        );

        // 清除 API 缓存，确保使用新 token
        Api.clearAuthCache();

        // 保存登录响应数据
        await UserSession.saveLoginResponse(response);
        await _persistRememberedUsername(username);

        if (!mounted) return;
        AppRoutes.navigateToMainPageAndReplace(context);
      } else {
        // 注册模式：获取缓存的用户画像数据
        final userProfile = await UserDataCache.getUserProfile();

        response = await Api.register(
          LoginRequest(
            name: username,
            email: email,
            fullName: fullName,
            password: password,
            userProfile: userProfile.isNotEmpty ? userProfile : null,
          ),
        );
        if (response != null) {
          Api.clearAuthCache();
          await UserSession.saveLoginResponse(response);
          await _persistRememberedUsername(username);
          await UserDataCache.clearCache();

          if (!mounted) return;
          AppRoutes.navigateToMainPageAndReplace(context);
          return; /*

          await Api.login(
            LoginRequest(
              name: username,
              password: password,
            ),
          );

          // 清除 API 缓存，确保使用新 token
          Api.clearAuthCache();

          // 注册成功后自动登录
          await UserSession.saveLoginResponse(response);
          await _persistRememberedUsername(username);

          // 注册成功后清除本地缓存
          await UserDataCache.clearCache();

          if (!mounted) return;
          AppRoutes.navigateToMainPageAndReplace(context);
          */
        } else {
          if (!mounted) return;
          ToastHelper.error(context, '注册失败，请稍后重试');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ToastHelper.error(context, _friendlyAuthError(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _switchAuthMode() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    setState(() {
      _isLoginMode = !_isLoginMode;
      _obscurePassword = true;
    });
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  String _friendlyAuthError(dynamic error) {
    final raw = error.toString().toLowerCase();

    if (raw.contains('401') ||
        raw.contains('unauthorized') ||
        raw.contains('invalid credentials') ||
        raw.contains('invalid password') ||
        raw.contains('wrong password') ||
        raw.contains('password incorrect')) {
      return '用户名或密码错误，请重试';
    }

    if (raw.contains('404') ||
        raw.contains('user not found') ||
        raw.contains('account not found')) {
      return '账号不存在，请先注册';
    }

    if (raw.contains('409') ||
        raw.contains('already exists') ||
        raw.contains('duplicate') ||
        raw.contains('conflict')) {
      return '该账号已存在，请直接登录';
    }

    if (raw.contains('timeout') || raw.contains('socketexception')) {
      return '网络异常，请检查网络后重试';
    }

    return ErrorMessageHelper.format(error);
  }

  Future<void> _loadRememberedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberUsernameKey) ?? true;
    final savedName = prefs.getString(_savedUsernameKey) ?? '';

    if (!mounted) return;
    setState(() {
      _rememberUsername = remember;
      if (remember && savedName.isNotEmpty) {
        _nameController.text = savedName;
      }
    });
  }

  Future<void> _persistRememberedUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberUsernameKey, _rememberUsername);
    if (_rememberUsername) {
      await prefs.setString(_savedUsernameKey, username);
    } else {
      await prefs.remove(_savedUsernameKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F9FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.health_and_safety_rounded,
                    size: 54,
                    color: Color(0xFF4A90D9),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isLoginMode ? '欢迎回来' : '创建账号',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoginMode ? '登录继续你的健康旅程' : '注册后即可开始体验 Zenify',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration(
                            label: '用户名',
                            icon: Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '请输入用户名';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        if (!_isLoginMode) ...[
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _fieldDecoration(
                              label: '邮箱',
                              icon: Icons.email_outlined,
                            ),
                            validator: _isLoginMode
                                ? null
                                : (value) {
                                    final trimmed = value?.trim() ?? '';
                                    if (trimmed.isEmpty) {
                                      return '请输入邮箱';
                                    }
                                    if (!RegExp(
                                      r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$',
                                    ).hasMatch(trimmed)) {
                                      return '请输入有效邮箱';
                                    }
                                    return null;
                                  },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _fullNameController,
                            textInputAction: TextInputAction.next,
                            decoration: _fieldDecoration(
                              label: '姓名',
                              icon: Icons.badge_outlined,
                            ),
                            validator: _isLoginMode
                                ? null
                                : (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return '请输入姓名';
                                    }
                                    return null;
                                  },
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _isLoading ? null : _submit(),
                          decoration: _fieldDecoration(
                            label: '密码',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入密码';
                            }
                            if (!_isLoginMode && value.length < 6) {
                              return '密码至少 6 位';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberUsername,
                              onChanged: _isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _rememberUsername = value ?? true;
                                      });
                                    },
                              activeColor: const Color(0xFF4A90D9),
                              visualDensity: VisualDensity.compact,
                            ),
                            const Text(
                              '记住用户名',
                              style: TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90D9),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_isLoginMode ? '登录' : '注册'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: _isLoading ? null : _switchAuthMode,
                    child: Text(
                      _isLoginMode ? '没有账号？去注册' : '已有账号？去登录',
                      style: const TextStyle(
                        color: Color(0xFF4A90D9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
