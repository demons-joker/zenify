# BottomInputSection 通用底部输入组件

## 概述
`BottomInputSection` 是一个通用的底部输入组件，适用于问卷调查中的输入框和下一步按钮组合。

## 使用方法

### 1. 导入组件
```dart
import '../../widgets/bottom_input_section.dart';
```

### 2. 在Scaffold中使用
```dart
Scaffold(
  // ... 其他属性
  bottomNavigationBar: BottomInputSection(
    controller: yourController,
    placeholder: 'Add more',
    onPressed: () => yourOnPressed(),
    onChanged: (value) {
      setState(() {
        // 处理输入变化
      });
    },
  ),
)
```

## 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| controller | TextEditingController? | null | 输入框控制器 |
| placeholder | String | 'Add more' | 占位符文本 |
| onPressed | VoidCallback? | null | 按钮点击回调 |
| onChanged | Function(String)? | null | 输入内容变化回调 |
| buttonImagePath | String? | ImageConstant.imgButton | 自定义按钮图片路径 |

## 特性

- ✅ **固定底部定位** - 始终显示在屏幕底部
- ✅ **响应式布局** - 输入框占3/4，按钮占1/4
- ✅ **SafeArea支持** - 自动处理安全区域
- ✅ **统一样式** - 与应用设计风格保持一致
- ✅ **高度可定制** - 支持自定义占位符和按钮图片
- ✅ **类型安全** - 完整的TypeScript类型支持

## 使用场景

- 问卷调查中的"其他"选项输入
- 任何需要底部输入框+按钮组合的页面
- 评论输入和提交
- 搜索和确认操作

## 示例用法

```dart
class ExampleScreen extends StatefulWidget {
  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('示例')),
      body: Center(
        child: Text('主要内容区域'),
      ),
      bottomNavigationBar: BottomInputSection(
        controller: _controller,
        placeholder: '请输入内容',
        onPressed: () {
          // 处理按钮点击
          print('输入内容: ${_controller.text}');
        },
        onChanged: (value) {
          setState(() {
            // 更新状态
          });
        },
      ),
    );
  }
}
```