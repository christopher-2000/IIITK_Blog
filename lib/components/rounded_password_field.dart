import 'package:flutter/material.dart';
import 'package:iiitk_app/components/text_field_container.dart';
//import 'package:flutter_auth/constants.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  const RoundedPasswordField({
    Key key,
    this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        validator: (value) {
          return value.isEmpty ? "Password is Required" : null;
        },
        controller: controller,
        obscureText: true,
        onChanged: onChanged,
        cursorColor: Colors.green[700],
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: Colors.green[700],
          ),
          suffixIcon: Icon(
            Icons.visibility,
            color: Colors.green[700],
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
