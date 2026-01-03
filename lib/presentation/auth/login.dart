import 'package:flutter/material.dart';
import 'package:zenify/services/api.dart';
import 'package:zenify/services/user_session.dart';
import 'package:zenify/services/user_data_cache.dart';
import 'package:zenify/routes/app_routes.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _isLoading = false;
  bool _isLoginMode = true; // 切换登录/注册模式
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      dynamic response;
      if (_isLoginMode) {
        response = await Api.login(
          LoginRequest(
            name: _nameController.text,
            password: _passwordController.text,
          ),
        );
        print('loginresponse: $response');

        // 保存登录响应数据
        await UserSession.saveLoginResponse(response);

        AppRoutes.navigateToMainPageAndReplace(context);
      } else {
        // 注册模式：获取缓存的用户画像数据
        final userProfile = await UserDataCache.getUserProfile();

        response = await Api.register(
          LoginRequest(
            name: _nameController.text,
            email: _emailController.text,
            fullName: _fullNameController.text,
            password: _passwordController.text,
            userProfile: userProfile.isNotEmpty ? userProfile : null,
          ),
        );
        if (response != null) {
          var userInfo = await Api.login(
            LoginRequest(
              name: _nameController.text,
              password: _passwordController.text,
            ),
          );
          // 注册成功后自动登录
          await UserSession.saveLoginResponse(userInfo);

          // 注册成功后清除本地缓存
          await UserDataCache.clearCache();

          AppRoutes.navigateToMainPageAndReplace(context);
        } else {
          setState(() => _errorMessage = 'Registration failed, please try again later');
        }
      }
      print('loginobject: $response');
    } catch (e) {
      setState(() => _errorMessage = 'Login failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _switchAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(_isLoginMode ? 'Login' : 'Register'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              if (!_isLoginMode) ...[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: _isLoginMode
                      ? null
                      : (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: _isLoginMode
                      ? null
                      : (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                ),
                SizedBox(height: 20),
              ],
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (!_isLoginMode && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text(_isLoginMode ? 'Login' : 'Register'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : _switchAuthMode,
                child: Text(
                  _isLoginMode ? 'No account? Register now' : 'Already have an account? Login',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
