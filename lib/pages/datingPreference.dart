import 'package:flutter/material.dart';

class DatingPreferenceSelection extends StatelessWidget {
  final String? currentDatingPreference;
  final Function(String) onPreferenceSelected;

  const DatingPreferenceSelection({
    required this.currentDatingPreference,
    required this.onPreferenceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(221, 231, 45, 45),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      // Add logic here to close the widget
                      Navigator.pop(context);
                    },
                    color: Colors.black,
                    iconSize: 30.0,
                  ),
                ),
              ],
            ),
          ),
          buildListTile('Male', Icons.male, Colors.blue),
          buildListTile('Female', Icons.female, Colors.pink),
          buildListTile('Any', Icons.transgender, Colors.grey),
        ],
      ),
    );
  }

  Widget buildListTile(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: currentDatingPreference == title
                ? color.withOpacity(0.3)
                : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          leading: Icon(
            icon,
            color: color,
          ),
          onTap: () => onPreferenceSelected(title),
        ),
      ),
    );
  }
}
