import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'form.dart';

class FieldWidget extends StatefulWidget {
  final FormData? formData; //this is required to update dependent fields
  final MenuFormField menuFormField;
  const FieldWidget({Key? key, required this.formData, required this.menuFormField}) : super(key: key);

  @override
  State<FieldWidget> createState() => _FieldWidgetState();
}

class _FieldWidgetState extends State<FieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('menuFormField is  ${widget.menuFormField.name}');
  }
}
