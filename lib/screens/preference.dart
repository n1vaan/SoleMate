import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sole_mate/provider/preferences_provider.dart';
import 'package:sole_mate/provider/products_provider.dart';
// import 'package:sole_mate/provider/products_provider.dart';
// import 'package:sole_mate/provider/products_provider.dart';
import 'package:sole_mate/screens/bottomapbar.dart';
import 'package:sole_mate/services/sharedpreferences.dart';
import 'package:sole_mate/widgets/custombutton.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({Key? key}) : super(key: key);

  @override
  _PreferenceScreenState createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  int currentPage = 1;
  final List<String> brands = [
    "ASICS",
    "Onitsuka Tiger",
    "Converse",
    "Birkenstock",
    "Puma",
    "adidas",
    "Nike",
    "Jordan",
    "KAWS",
    "Anta",
    "Crocs",
    "MSCHF",
    "Vans",
    "Fear of God",
    "Timberland",
    "Salomon",
    "Reebok",
    "New Balance",
    "Saucony",
    "OFF-WHITE",
    "Ewing Athletics",
    "Prada",
    "Versace",
    "Alexander McQueen",
    "BAPE",
    "Under Armour",
    "DC Shoes",
    "Christian Louboutin",
    "Jimmy Choo",
    "Fila",
    "Fendi",
    "Li-Ning",
    "Gucci",
    "Louis Vuitton",
    "Chanel",
    "Saint Laurent",
    "Hoka One One",
    "UGG",
    "Balenciaga",
  ];

  @override
  void initState() {
    super.initState();
    // Load preferences when the screen is initialized
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferenceProvider =
        Provider.of<PreferenceProvider>(context, listen: false);
    await preferenceProvider
        .loadPreferences(); // Load preferences and update the provider
  }

  void showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 200),
      ),
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> sendPreferences() async {
    final preferenceProvider =
        Provider.of<PreferenceProvider>(context, listen: false);
    final token = await SharedPreferencesService.getData('auth_token');

    if (token == null) {
      if (mounted) {
        showSnackBar('Authentication token not found.', Colors.red);
      }
      return;
    }

    final success = await preferenceProvider.sendPreferences(token);

    if (success) {
      if (mounted) {
        showSnackBar('Preferences saved successfully.', Colors.green);
      }

      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      await productProvider.resetProvider();
      await productProvider.fetchProducts();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CustomBottomNavBar()),
        );
      }
    } else {
      if (mounted) {
        showSnackBar(
            'Failed to save preferences. Please try again.', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Select brand(s)",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Consumer<PreferenceProvider>(
                  builder: (context, preferenceProvider, child) {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: brands.length,
                      itemBuilder: (BuildContext context, int index) {
                        final brand = brands[index];
                        final isSelected =
                            preferenceProvider.selectedBrands.contains(brand);

                        return InkWell(
                          onTap: () => preferenceProvider.toggleBrand(brand),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF60A6FF)
                                    : Colors.transparent,
                                width: isSelected ? 2.0 : 0.0,
                              ),
                            ),
                            child: Text(
                              capitalizeFirstLetter(
                                  brand), // Capitalize first letter
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 16,
                                color: isSelected
                                    ? const Color(0xFF60A6FF)
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                isLoading: false,
                text: "Start",
                onPressed: sendPreferences,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
