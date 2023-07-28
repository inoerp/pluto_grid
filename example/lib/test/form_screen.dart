import 'package:example/test/form.dart';
import 'package:flutter/material.dart';

import 'form_widget.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({Key? key}) : super(key: key);

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FormExample(),
    );
  }
}

class FormExample extends StatefulWidget {
  const FormExample({Key? key}) : super(key: key);

  @override
  State<FormExample> createState() => _FormExampleState();
}

class _FormExampleState extends State<FormExample> {
  @override
  Widget build(BuildContext context) {
    List<MenuFormField> fields = [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('DemoApp'),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: FormWidget(
          formData: FormData(getFieldData()),
        ),
      ),
    );
  }

  int maxNumber = 1000000;
  List<MenuFormField> getFieldData() {
    List<MenuFormField> fields = [];
    for (int i = 0; i < maxNumber; i++) {
      fields.add(MenuFormField("item number ${i.toString()}"));
    }
    return fields;
  }
}
