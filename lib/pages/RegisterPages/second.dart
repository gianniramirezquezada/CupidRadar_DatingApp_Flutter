import 'package:flutter/material.dart';
import 'package:romanceradar/pages/RegisterPages/third.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SecondScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  SecondScreen({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final TextEditingController dobController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  String? dobError;
  String? cityError;
  String? phoneNumberError;

  final List<String> allCities = [
    // Gujarat (GJ)
    'Ahmedabad', 'Amreli district', 'Anand', 'Banaskantha', 'Bharuch',
    'Bhavnagar', 'Dahod', 'The Dangs', 'Gandhinagar',
    'Jamnagar', 'Junagadh', 'Kutch', 'Kheda', 'Mehsana', 'Narmada', 'Navsari',
    'Patan', 'Panchmahal', 'Porbandar', 'Rajkot',
    'Sabarkantha', 'Surendranagar', 'Surat', 'Vyara', 'Vadodara', 'Valsad',
  ];

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != dobController.text) {
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        dobError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 80.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your What\'s Your\nNumber?',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 130, 108, 255),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.0),
                Text(
                  'We protect our community by making sure everyone on romanceradar is real.',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: dobController,
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    errorText: dobError,
                  ),
                ),
                SizedBox(height: 12.0),
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                      errorText: cityError,
                    ),
                    controller: cityController,
                  ),
                  suggestionsCallback: (pattern) {
                    return allCities
                        .where((city) =>
                            city.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      cityController.text = suggestion;
                      cityError = null;
                    });
                  },
                  transitionBuilder: (context, suggestionsBox, controller) {
                    return suggestionsBox;
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !allCities.contains(value)) {
                      return 'City is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.0),
                TextFormField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    errorText: phoneNumberError,
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    if (validateForm()) {
                      int age = calculateAge(dobController.text);
                      if (age >= 18) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThirdScreen(
                              name: widget.name,
                              email: widget.email,
                              password: widget.password,
                              dob: dobController.text,
                              address: cityController.text,
                              phoneNumber: phoneNumberController.text,
                            ),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Age Requirement'),
                              content: Text(
                                  'You must be at least 18 years old to open an account.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 130, 108, 255),
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
      ),
    );
  }

  bool validateForm() {
    bool isValid = true;

    if (dobController.text.isEmpty) {
      setState(() {
        dobError = 'Date of Birth is required';
      });
      isValid = false;
    } else {
      setState(() {
        dobError = null;
      });
    }

    if (cityController.text.isEmpty ||
        !allCities.contains(cityController.text)) {
      setState(() {
        cityError = 'Please select a valid city';
      });
      isValid = false;
    } else {
      setState(() {
        cityError = null;
      });
    }

    if (phoneNumberController.text.isEmpty) {
      setState(() {
        phoneNumberError = 'Phone Number is required';
      });
      isValid = false;
    }
    else if(phoneNumberController.text.length!=10)
    {
       setState(() {
        phoneNumberError = 'Please Enter a valid phone number';
      });
      isValid = false;

    } else {
      setState(() {
        phoneNumberError = null;
      });
    }

    return isValid;
  }

  int calculateAge(String dob) {
    DateTime today = DateTime.now();
    DateTime birthDate = DateTime.parse(dob);
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
