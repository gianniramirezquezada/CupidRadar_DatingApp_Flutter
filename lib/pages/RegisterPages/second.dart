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
    // Lombardia (LO)
    'Milano', 'Bergamo', 'Brescia', 'Como', 'Cremona',
    'Lecco', 'Lodi', 'Mantova', 'Monza',
    'Pavia', 'Sondrio', 'Varese', 'Busto Arsizio', 'Gallarate', 'Legnano', 'Rho',
    'Seregno', 'Desio', 'Voghera', 'Cinisello Balsamo',
    'Sesto San Giovanni', 'Cologno Monzese', 'Abbiategrasso', 'Magenta', 'Gorgonzola', 'Carate Brianza',
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
        title: Text('Informazioni personali'),
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
                  'Dati ',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 130, 108, 255),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.0),
                Text(
                  'Proteggiamo la nostra comunity assicurandoci che tutti su pochi siano reali.',
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
                    labelText: 'Data di nascita',
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
                      labelText: 'Città',
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
                      return 'Linserimento della città è obbligatoria';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.0),
                TextFormField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Numero di telefono',
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
                              title: Text('Requisiti di età'),
                              content: Text(
                                  'Per creare un accont è neccesario avere minimo 18 anni'),
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
                    backgroundColor: Color.fromARGB(255, 130, 108, 255),
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Avanti',
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
        dobError = 'Data di nascita obbligatoria';
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
        cityError = 'Scegli una città valida';
      });
      isValid = false;
    } else {
      setState(() {
        cityError = null;
      });
    }

    if (phoneNumberController.text.isEmpty) {
      setState(() {
        phoneNumberError = 'Il numero di telefono è obbligatorio';
      });
      isValid = false;
    }
    else if(phoneNumberController.text.length!=10)
    {
       setState(() {
        phoneNumberError = 'Inserisci un numero di telefono valido';
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
