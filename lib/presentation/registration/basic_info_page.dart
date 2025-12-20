import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zenify/providers/registration_provider.dart';

class BasicInfoPage extends StatefulWidget {
  const BasicInfoPage({super.key});

  @override
  State<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedGender;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final provider = context.read<RegistrationProvider>();
    _nameController =
        TextEditingController(text: provider.registrationData.name ?? '');
    _selectedGender = provider.registrationData.gender;
    _selectedDate = provider.registrationData.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Validate name: 2-20 chars, no special symbols
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '姓名不能为空';
    }
    if (value.length < 2 || value.length > 20) {
      return '姓名长度应在2-20个字符之间';
    }
    // Allow Chinese, English letters, numbers, and spaces
    if (!RegExp(r'^[\u4e00-\u9fffA-Za-z0-9 ]+$').hasMatch(value)) {
      return '姓名不能包含特殊符号';
    }
    return null;
  }

  /// Open date picker and select birth date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // Also update provider
      context.read<RegistrationProvider>().updateBirthDate(picked);
    }
  }

  /// Format date for display
  String _formatDate(DateTime? date) {
    if (date == null) return '选择出生日期';
    return DateFormat('yyyy年MM月dd日').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Name field
              _buildNameField(),
              const SizedBox(height: 24),
              // Gender selection
              _buildGenderField(),
              const SizedBox(height: 24),
              // Birth date selection
              _buildBirthDateField(),
              const SizedBox(height: 40),
              // Next button
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build AppBar with step indicator
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        '基本信息',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Center(
            child: Text(
              '第 1 步 / 4',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build name input field
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '姓名',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '请输入你的姓名',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              validator: _validateName,
              onChanged: (value) {
                context.read<RegistrationProvider>().updateName(value);
                // Avoid calling validate synchronously during build (it may call
                // setState). Defer to the next frame to be safe.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _formKey.currentState?.validate();
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Build gender selection field
  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '性别',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'male',
                  label: Text('男'),
                  icon: Icon(Icons.male),
                ),
                ButtonSegment<String>(
                  value: 'female',
                  label: Text('女'),
                  icon: Icon(Icons.female),
                ),
                ButtonSegment<String>(
                  value: 'other',
                  label: Text('其他'),
                ),
              ],
              // Allow no selection initially (user may not choose immediately).
              // The SegmentedButton requires either a non-empty `selected`
              // set or `emptySelectionAllowed: true` to permit an empty set.
              selected: _selectedGender != null
                  ? <String>{_selectedGender!}
                  : <String>{},
              emptySelectionAllowed: true,
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedGender =
                      newSelection.isNotEmpty ? newSelection.first : null;
                });
                if (_selectedGender != null) {
                  context
                      .read<RegistrationProvider>()
                      .updateGender(_selectedGender!);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Build birth date picker field
  Widget _buildBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '出生日期',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
          child: InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(_selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate != null
                          ? Colors.black87
                          : Colors.grey[400],
                    ),
                  ),
                  Icon(Icons.calendar_today, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ),
        if (_selectedDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '年龄：${DateTime.now().year - _selectedDate!.year} 岁',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
      ],
    );
  }

  /// Build next button
  Widget _buildNextButton() {
    return Consumer<RegistrationProvider>(
      builder: (context, provider, _) {
        // Avoid calling FormState.validate() during build because it may
        // call setState() internally and cause "setState() called during
        // build" errors. Use a pure function to validate the name field.
        final isFormValid = _validateName(_nameController.text) == null;
        final isDateSelected = _selectedDate != null;
        final isGenderSelected = _selectedGender != null;
        final isValid = isFormValid && isDateSelected && isGenderSelected;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isValid ? () => _handleNext(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? Colors.blue : Colors.grey[300],
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '下一步',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Handle next step
  void _handleNext(BuildContext context) {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedGender != null) {
      // Update all data in provider
      final provider = context.read<RegistrationProvider>();
      provider.updateName(_nameController.text);
      provider.updateGender(_selectedGender!);
      provider.updateBirthDate(_selectedDate!);
      provider.nextStep();

      // Navigate to next step (to be implemented)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存基本信息，下一步待实现')),
      );
    }
  }
}
