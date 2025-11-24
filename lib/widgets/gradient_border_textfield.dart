import 'package:flutter/material.dart';

class GradientBorderTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  const GradientBorderTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
  });

  @override
  State<GradientBorderTextField> createState() => _GradientBorderTextFieldState();
}

class _GradientBorderTextFieldState extends State<GradientBorderTextField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_clearError);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_clearError);
    super.dispose();
  }

  void _clearError() {
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null && _errorText!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: hasError 
              ? const LinearGradient(
                  colors: [Color(0xFFDC3545), Color(0xFFFF6B6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF208A33), Color(0xFF6BD377)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            margin: const EdgeInsets.all(1.5), // Border width
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide.none,
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide.none,
                ),
                errorText: null,
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
              validator: (value) {
                final error = widget.validator?.call(value);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _errorText = error;
                    });
                  }
                });
                return error;
              },
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: Color(0xFFDC3545),
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ),
      ],
    );
  }
}
