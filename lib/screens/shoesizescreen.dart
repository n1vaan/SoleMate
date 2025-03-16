import 'package:flutter/material.dart';
import 'package:sole_mate/widgets/customgradient_button.dart';

class ShoeSizeScreen extends StatefulWidget {
  @override
  _ShoeSizeScreenState createState() => _ShoeSizeScreenState();
}

class _ShoeSizeScreenState extends State<ShoeSizeScreen> {
  String selectedConversion = 'UK';
  String? selectedShoeSize;
  final List<String> conversions = ['US W', 'US M', 'UK', 'CM', 'KR', 'EU'];
  final Map<String, List<String>> shoeSizes = {
    'US M': ['ALL', '3.5', '4', '4.5', '5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11'],
    'US W': ['ALL', '5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11', '11.5', '12', '12.5'],
    'UK': ['ALL', '3.5', '4', '4.5', '5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11'],
    'CM': ['ALL', '5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11', '11.5', '12', '12.5'],
    'KR': ['ALL', '3.5', '4', '4.5', '5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11'],
    'EU': ['ALL', '5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11', '11.5', '12', '12.5'],
  };
  final Map<String, String> shoePrices = {
    'ALL': '\$250',
    '3.5': '\$50',
    '4': '\$52',
    '4.5': '\$54',
    '5': '\$56',
    '5.5': '\$58',
    '6': '\$60',
    '6.5': '\$62',
    '7': '\$64',
    '7.5': '\$66',
    '8': '\$68',
    '8.5': '\$70',
    '9': '\$72',
    '9.5': '\$74',
    '10': '\$76',
    '10.5': '\$78',
    '11': '\$80',
    '11.5': '\$82',
    '12': '\$84',
    '12.5': '\$86',
    // Add more prices as needed
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
           backgroundColor: Colors.transparent,
         leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('      Select Shoe Size'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: conversions.map((conversion) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChoiceChip(
                      label: Text(
                        conversion,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: selectedConversion == conversion,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedConversion = selected ? conversion : selectedConversion;
                          selectedShoeSize = null; // Reset the selected shoe size when conversion changes
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: getShoeSizes().length,
                itemBuilder: (BuildContext context, int index) {
                  String shoeSize = getShoeSizes()[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedShoeSize = shoeSize;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: NextScreen(
                              conversion: selectedConversion,
                              shoeSize: selectedShoeSize!,
                              price: shoePrices[selectedShoeSize!]!,
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedShoeSize == shoeSize
                            ? theme.primaryColor
                            : isDarkMode ? Colors.grey[800] : Color.fromARGB(97, 136, 136, 136),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: selectedShoeSize == shoeSize
                              ? Colors.black
                              : Colors.transparent,
                          width: selectedShoeSize == shoeSize ? 2.0 : 0.0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              shoeSize,
                              style: TextStyle(
                                color: selectedShoeSize == shoeSize ? Colors.white : isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          const Text('BID', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> getShoeSizes() {
    return shoeSizes[selectedConversion] ?? [];
  }
}

class NextScreen extends StatelessWidget {
  final String conversion;
  final String shoeSize;
  final String price;

  NextScreen({required this.conversion, required this.shoeSize, required this.price});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversion: $conversion',
          style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Shoe Size: $shoeSize',
          style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Price: $price',
          style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GradientButton(
          text: "Save",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
