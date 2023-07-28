import 'package:example/test/field_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'form.dart';

class FormWidget extends StatefulWidget {
  final FormData formData;
  const FormWidget({Key? key, required this.formData}) : super(key: key);

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 600,
        height: 600,
        child: ListView.builder(
            itemCount: widget.formData.fields.length,
            itemExtent: 30,
            itemBuilder: (context, i) {
              return FieldWidget(
                formData: widget.formData,
                //formData: null,
                menuFormField: widget.formData.fields[i],
              );
            }),
      ),
    );
  }
}
