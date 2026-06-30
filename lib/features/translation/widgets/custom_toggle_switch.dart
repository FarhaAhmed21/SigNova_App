import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomToggleSwitch extends StatefulWidget {
  final bool isTextToSignInitial;
  final Function(bool isTextToSign) onChanged;

  const CustomToggleSwitch({
    super.key,
    this.isTextToSignInitial = true,
    required this.onChanged,
  });

  @override
  State<CustomToggleSwitch> createState() => _CustomToggleSwitchState();
}

class _CustomToggleSwitchState extends State<CustomToggleSwitch> {
  late bool _isTextToSign;

  @override
  void initState() {
    super.initState();
    _isTextToSign = widget.isTextToSignInitial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.5.h,
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(25.sp),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              title: "SIGN TO TEXT",
              isActive: !_isTextToSign,
              onTap: () {
                if (_isTextToSign) {
                  setState(() => _isTextToSign = false);
                  widget.onChanged(false);
                }
              },
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              title: "TEXT TO SIGN",
              isActive: _isTextToSign,
              onTap: () {
                if (!_isTextToSign) {
                  setState(() => _isTextToSign = true);
                  widget.onChanged(true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 0),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6B4CF4) : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF4A4A4A),
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
