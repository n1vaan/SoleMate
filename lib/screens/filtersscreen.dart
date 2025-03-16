import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:sole_mate/models/filterproductmodel.dart';
import 'package:sole_mate/provider/products_provider.dart';
import 'package:sole_mate/widgets/customgradient_button.dart';

class FilterModalBottomSheet extends StatefulWidget {
  final ProductProvider productProvider;
  final ProductFilter? initialFilter; // Add this property

  FilterModalBottomSheet({required this.productProvider, this.initialFilter});

  @override
  _FilterModalBottomSheetState createState() => _FilterModalBottomSheetState();
}

class _FilterModalBottomSheetState extends State<FilterModalBottomSheet> {
  String? selectedColorway;
  RangeValues _currentRangeValues = const RangeValues(50, 600);
  DateTime? _startReleaseDate;
  DateTime? _endReleaseDate;
  bool isOffline = false;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final _formKey = GlobalKey<FormState>();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set the initial filter values
    if (widget.initialFilter != null) {
      selectedColorway = widget.initialFilter!.colorway;
      _currentRangeValues = RangeValues(
        widget.initialFilter!.minRetailPrice,
        widget.initialFilter!.maxRetailPrice,
      );
      _startReleaseDate = widget.initialFilter!.startReleaseDate != null
          ? DateTime.parse(widget.initialFilter!.startReleaseDate!)
          : null;
      _endReleaseDate = widget.initialFilter!.endReleaseDate != null
          ? DateTime.parse(widget.initialFilter!.endReleaseDate!)
          : null;

      // Initialize controllers with initial values
      _startDateController.text = _startReleaseDate != null
          ? _dateFormat.format(_startReleaseDate!)
          : '';
      _endDateController.text =
          _endReleaseDate != null ? _dateFormat.format(_endReleaseDate!) : '';
    }
  }

  Future<void> _selectStartDate() async {
    DateTime initialDate = _startReleaseDate ?? DateTime.now();
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (newDate != null && newDate != initialDate) {
      setState(() {
        _startReleaseDate = newDate;
        _startDateController.text = _dateFormat.format(newDate);
      });
    }
  }

  Future<void> _selectEndDate() async {
    DateTime initialDate = _endReleaseDate ?? DateTime.now();
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (newDate != null && newDate != initialDate) {
      setState(() {
        _endReleaseDate = newDate;
        _endDateController.text = _dateFormat.format(newDate);
      });
    }
  }

  void _applyFilters() {
    if (_formKey.currentState?.validate() ?? false) {
      final filter = ProductFilter(
        colorway: selectedColorway,
        minRetailPrice: _currentRangeValues.start.toDouble(),
        maxRetailPrice: _currentRangeValues.end.toDouble(),
        startReleaseDate: _startReleaseDate != null
            ? _dateFormat.format(_startReleaseDate!)
            : null,
        endReleaseDate: _endReleaseDate != null
            ? _dateFormat.format(_endReleaseDate!)
            : null,
      );

      widget.productProvider.applyFilters(filter);
      Navigator.pop(context);
    }
  }

  void _clearFilters() {
    widget.productProvider.clearFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colorway Dropdown
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Center(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedColorway,
                    items: [
                      {"color": Colors.white, "name": "White"},
                      {"color": Colors.red, "name": "Red"},
                      {"color": Colors.black, "name": "Black"},
                      {"color": Colors.grey, "name": "Gray"},
                      {"color": Colors.pink, "name": "Pink"},
                      {"color": Colors.orange, "name": "Orange"},
                      {"color": Colors.yellow, "name": "Yellow"},
                      {"color": Colors.green, "name": "Green"},
                      {"color": Colors.blue, "name": "Blue"},
                      {"color": Colors.purple, "name": "Purple"},
                      {"color": Colors.brown, "name": "Brown"}
                    ].map((colorItem) {
                      final color = colorItem["color"] as Color;
                      final name = colorItem["name"] as String;
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedColorway = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Select Color',
                      hintStyle: TextStyle(color: textColor),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      isDense: true, // Reduces the padding around the text
                    ),
                    dropdownColor: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    icon: Icon(Icons.arrow_drop_down, color: textColor),
                    iconSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Price Range Slider
              Text(
                'Retail Price Range',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              RangeSlider(
                activeColor: const Color(0xFF55B2FD),
                inactiveColor: const Color(0xFF55B2FD),
                values: _currentRangeValues,
                min: 50,
                max: 600,
                divisions: 55,
                labels: RangeLabels(
                  '\$${_currentRangeValues.start.round()}',
                  '\$${_currentRangeValues.end.round()}',
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentRangeValues = values;
                  });
                },
              ),
              Text(
                'Price: \$${_currentRangeValues.start.round()} - \$${_currentRangeValues.end.round()}',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 16),

              // Release Date Range Picker
              Text(
                'Release Date Range',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectStartDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _startDateController,
                          decoration: InputDecoration(
                            hintText: 'Start Date (YYYY-MM-DD)',
                            hintStyle:
                                TextStyle(color: textColor.withOpacity(0.5)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: borderColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          style: TextStyle(color: textColor),
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (_startReleaseDate == null &&
                                _endReleaseDate != null) {
                              return 'Please select a start date.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectEndDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _endDateController,
                          decoration: InputDecoration(
                            hintText: 'End Date (YYYY-MM-DD)',
                            hintStyle:
                                TextStyle(color: textColor.withOpacity(0.5)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: borderColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          style: TextStyle(color: textColor),
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (_endReleaseDate == null &&
                                _startReleaseDate != null) {
                              return 'Please select an end date.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Apply and Clear Buttons

              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GradientButton(
                      text: 'Apply Filters',
                      onPressed: _applyFilters,
                    ),
                    const SizedBox(height: 16),
                    GradientwhiteButton(
                      text: 'Clear Filters',
                      onPressed: _clearFilters,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
