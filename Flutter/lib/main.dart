import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'status_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LicenseRenewalApp());
}

class LicenseRenewalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car License Renewal',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LicenseFormPage(),
    );
  }
}

class LicenseFormPage extends StatefulWidget {
  @override
  _LicenseFormPageState createState() => _LicenseFormPageState();
}

class _LicenseFormPageState extends State<LicenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> formData = {};

  final List<String> statusOptions = ['Pending', 'In Review', 'Approved'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('License Renewal Form')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField('Name'),
              buildTextField('NRC'),
              buildTextField('License Number'),
              buildTextField('Car Type'),
              buildTextField('Phone Number'),
              buildDropdown('RTAD Status'),
              buildDropdown('Insurance Status'),
              buildDropdown('Municipal Status'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: Text('Submit'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatusPage()),
                  );
                },
                child: Text('View Submitted Forms'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      onSaved: (value) => formData[label] = value ?? '',
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget buildDropdown(String label) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: 'Pending',
      items: statusOptions
          .map((status) => DropdownMenuItem(
              value: status, child: Text(status)))
          .toList(),
      onChanged: (value) {
        setState(() {
          formData[label] = value!;
        });
      },
    );
  }

  void submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      await FirebaseFirestore.instance.collection('renewals').add(formData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form submitted')),
      );

      _formKey.currentState?.reset();
      setState(() {
        formData.clear();
      });
    }
  }
}