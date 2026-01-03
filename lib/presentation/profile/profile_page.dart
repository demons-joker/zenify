import 'package:flutter/material.dart';
import 'package:zenify/services/api.dart';
import 'package:zenify/services/user_session.dart';
import 'package:zenify/routes/app_routes.dart';
import 'package:zenify/presentation/qr_scanner/qr_scanner_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserInfo? _userInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await Api.getUserInfo();
      final userInfoJson =
          response is Map ? response['user_info'] ?? response : response;
      if (mounted) {
        setState(() {
          _userInfo = UserInfo.fromJson(userInfoJson);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to get user info: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _scanAndBindDevice() async {
    try {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => QRScannerPage()),
      );

      if (result != null && result.isNotEmpty) {
        _bindDevice(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _bindDevice(String deviceId) async {
    try {
      await Api.bindDevice(deviceId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Device bound successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // 重新加载用户信息（包含设备信息）
        _loadUserInfo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to bind device: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _unbindDevice(DeviceInfo device) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Unbind'),
        content: Text('Are you sure you want to unbind device "${device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Api.unbindDevice(device.deviceId);

        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Device unbound successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
          // 重新加载用户信息（包含设备信息）
          _loadUserInfo();
        }
      } catch (e) {
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unbind device: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              size: 18,
            ),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<Widget>(
        future: _buildProfileContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return Center(child: Text('Unknown error'));
          }
        },
      ),
    );
  }

  Future<Widget> _buildProfileContent() async {
    if (await UserSession.isLoggedIn() == false) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Not logged in', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AppRoutes.navigateToLoginAndReplace(context);
              },
              child: Text('Go to login'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadUserInfo,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_userInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User info not available', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadUserInfo,
              child: Text('Reload'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          // 用户头像和信息概览
          _buildProfileHeader(),
          SizedBox(height: 32),

          // // 用户详细信息卡片
          // _buildUserInfoSection(),
          // SizedBox(height: 24),

          // 设备管理部分
          _buildDeviceSection(),
          SizedBox(height: 24),

          // // 操作按钮
          // _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDeviceSection() {
    final devices = _userInfo?.devices ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        if (devices.isEmpty)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.devices,
                  size: 48,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 12),
                Text(
                  'No devices bound',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.qr_code_scanner),
                    label: Text('Scan QR to bind device'),
                    onPressed: _scanAndBindDevice,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...devices
              .map((device) => Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.devices,
                          color: Colors.green,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Device ID: ${device.deviceId}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Status: ${device.isOnline ? "Online" : "Offline"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: device.isOnline
                                      ? Colors.green
                                      : Colors.grey[600],
                                ),
                              ),
                              if (device.lastLoginAt != null) ...[
                                SizedBox(height: 2),
                                Text(
                                  'Last login: ${_formatDateTime(device.lastLoginAt!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.link_off, color: Colors.red),
                          onPressed: () => _unbindDevice(device),
                          tooltip: 'Unbind device',
                        ),
                      ],
                    ),
                  ))
              .toList(),
        // if (devices.isNotEmpty)
        //   Padding(
        //     padding: EdgeInsets.only(top: 12),
        //     child: SizedBox(
        //       width: double.infinity,
        //       child: OutlinedButton.icon(
        //         icon: Icon(Icons.add),
        //         label: Text('添加更多设备'),
        //         onPressed: _scanAndBindDevice,
        //         style: OutlinedButton.styleFrom(
        //           padding: EdgeInsets.symmetric(vertical: 12),
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // 头像
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue[50],
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.person,
            size: 60,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 16),

        // 用户名
        Text(
          _userInfo!.fullName.isNotEmpty
              ? _userInfo!.fullName
              : _userInfo!.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),

        // 邮箱
        Text(
          _userInfo!.email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Column(
      children: [
        // _buildInfoItem('用户ID', _userInfo!.id.toString()),
        Divider(height: 1),
        _buildInfoItem('用户名', _userInfo!.name),
        Divider(height: 1),
        _buildInfoItem('电子邮箱', _userInfo!.email),
        Divider(height: 1),
        _buildInfoItem('手机号码', _userInfo!.phone),
        Divider(height: 1),
        _buildInfoItem('全名', _userInfo!.fullName),
        Divider(height: 1),
        _buildInfoItem('来源', _userInfo!.source),
        Divider(height: 1),
        _buildInfoItem('账号状态', _userInfo!.isActive ? '已激活' : '未激活'),
        Divider(height: 1),
        _buildInfoItem('注册时间', _formatDateTime(_userInfo!.createdAt)),
        Divider(height: 1),
      ],
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : '未设置',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(Icons.edit, size: 20),
            label: Text('编辑资料', style: TextStyle(fontSize: 16)),
            onPressed: () {
              // 跳转到编辑页面
              // Navigator.push(context, MaterialPageRoute(
              //   builder: (context) => EditProfilePage(userInfo: _userInfo!)
              // ));
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(Icons.settings, size: 20),
            label: Text('设置', style: TextStyle(fontSize: 16)),
            onPressed: () {
              // 跳转到设置页面
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    try {
      await Api.logout();
      await UserSession.clear();
      AppRoutes.navigateToLoginAndReplace(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
