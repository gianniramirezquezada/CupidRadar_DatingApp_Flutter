import 'package:flutter/material.dart';
import 'package:romanceradar/pages/RegisterPages/second.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  bool isEmailExists = false;

  Future<void> checkEmailExists() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('utente')
        .where('email', isEqualTo: emailController.text)
        .get();

    if (result.docs.isNotEmpty) {
      // Email exists in Firestore
      setState(() {
        isEmailExists = true;
        emailError = 'Email già in uso';
      });
    } else {
      // Email does not exist in Firestore
      setState(() {
        isEmailExists = false;
        emailError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informazioni personali'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/Registration1.png',
                  height: 210,
                ),
              ),
              SizedBox(height: 30.0),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorText: nameError,
                ),
                onChanged: (_) {
                  setState(() {
                    nameError = null;
                  });
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorText: emailError,
                ),
                onChanged: (_) {
                  setState(() {
                    emailError = null;
                    isEmailExists = false;
                  });
                },
                onEditingComplete: () async {
                  await checkEmailExists();
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorText: passwordError,
                ),
                onChanged: (_) {
                  setState(() {
                    passwordError = null;
                  });
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Conferma Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorText: confirmPasswordError,
                ),
                onChanged: (_) {
                  setState(() {
                    confirmPasswordError = null;
                  });
                },
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () async {
                  if (validateForm()) {
                    await checkEmailExists();
                    if (!isEmailExists) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecondScreen(
                            name: nameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 130, 108, 255),
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool validateForm() {
    bool isValid = true;

    if (nameController.text.isEmpty) {
      setState(() {
        nameError = 'Name is required';
      });
      isValid = false;
    }

    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Email is required';
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(emailController.text)) {
      setState(() {
        emailError = 'Enter a valid email address';
      });
      isValid = false;
    } else if (isEmailExists) {
      // Email already exists in Firestore
      isValid = false;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = 'Password is required';
      });
      isValid = false;
    } else if (passwordController.text.length < 6) {
      setState(() {
        passwordError = 'Password must be at least 6 characters long';
      });
      isValid = false;
    }

    if (confirmPasswordController.text.isEmpty) {
      setState(() {
        confirmPasswordError = 'Confirm Password is required';
      });
      isValid = false;
    } else if (confirmPasswordController.text != passwordController.text) {
      setState(() {
        confirmPasswordError = 'Passwords do not match';
      });
      isValid = false;
    }

    return isValid;
  }
}
