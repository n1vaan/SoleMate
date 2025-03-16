import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sole_mate/screens/preference.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({Key? key}) : super(key: key);

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String selectedGender = ''; 

  void selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
    saveSelectedGender(selectedGender);
  }

  Future<void> saveSelectedGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_gender', gender);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PreferenceScreen()),
    );
  }

  Widget buildGenderContainer(String genderText, String imagePath) {
    bool isSelected = selectedGender == genderText;
    bool isInitial = selectedGender.isEmpty;

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => selectGender(genderText),
      child: Container(
        width: double.infinity,
        height: 92,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFD0CCFE), Color(0xFF55B2FD)],
                )
              : isInitial
                  ? null
                  : LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        isDarkMode
                            ? const Color(0xFFD0CCFE).withOpacity(0.45)
                            : const Color(0xFFD0CCFE).withOpacity(0.45),
                        isDarkMode
                            ? const Color(0xFFD0CCFE).withOpacity(0.45)
                            : const Color(0xFF55B2FD).withOpacity(0.45),
                      ],
                    ),
          color: isInitial
              ? isDarkMode
                  ? const Color.fromARGB(255, 195, 208, 243).withOpacity(0.45)
                  : const Color(0xFFD0CCFE).withOpacity(0.45)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    genderText,
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Image.asset(
                  imagePath,
                  width: 50,
                  height: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose Category",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              buildGenderContainer("Male", "assets/icons/men.png"),
              const SizedBox(height: 20),
              buildGenderContainer("Female", "assets/icons/women.png"),
              const SizedBox(height: 20),
              buildGenderContainer("Unisex", "assets/icons/unisex.png"),
            ],
          ),
        ),
      ),
    );
  }
}
