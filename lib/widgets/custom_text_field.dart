import 'package:flutter/material.dart';
import '../app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String placeholder;
  final bool isPassword;

  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.placeholder,
    this.isPassword = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextFormField(
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: AppColors.greyPlaceholder),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.grey, width: 2),
            ),
          ),
          obscureText: isPassword,
        ),
      ],
    );
  }
}
