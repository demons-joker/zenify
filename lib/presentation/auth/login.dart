import 'package:flutter/material.dart';
import 'package:zenify/services/api.dart';
import 'package:zenify/services/user_session.dart';
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

        // 保存登录响应数据
        await UserSession.saveLoginResponse(response);

        AppRoutes.navigateToMainPageAndReplace(context);
      } else {
        response = await Api.register(
          LoginRequest(
            name: _nameController.text,
            email: _emailController.text,
            fullName: _fullNameController.text,
            password: _passwordController.text,
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
          AppRoutes.navigateToMainPageAndReplace(context);
        } else {
          setState(() => _errorMessage = '注册失败，请稍后再试');
        }
      }
      print('loginobject: $response');
    } catch (e) {
      setState(() => _errorMessage = '登录失败: ${e.toString()}');
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
        title: Text(_isLoginMode ? '用户登录' : '用户注册'),
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
                  labelText: '用户名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
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
                    labelText: '电子邮箱',
                    border: OutlineInputBorder(),
                  ),
                  validator: _isLoginMode
                      ? null
                      : (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入电子邮箱';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return '请输入有效的电子邮箱';
                          }
                          return null;
                        },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: '全名',
                    border: OutlineInputBorder(),
                  ),
                  validator: _isLoginMode
                      ? null
                      : (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入您的全名';
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
                  labelText: '密码',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  if (!_isLoginMode && value.length < 6) {
                    return '密码至少6位';
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
                    : Text(_isLoginMode ? '登录' : '注册'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : _switchAuthMode,
                child: Text(
                  _isLoginMode ? '没有账号？立即注册' : '已有账号？立即登录',
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
