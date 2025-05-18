import 'package:flutter/material.dart';
import '../../app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final String placeholder;
  final bool isPassword;
  final TextEditingController controller; // Adicionando o controller

  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.placeholder,
    this.isPassword = false,
    required this.controller,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: const TextStyle(color: AppColors.greyPlaceholder),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.grey, width: 2),
            ),
          ),
          obscureText: widget.isPassword,
        ),
      ],
    );
  }
}
