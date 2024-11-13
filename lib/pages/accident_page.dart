import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/services/address_services.dart';
import 'package:accident_data_storage/widgets/delete_confirmation_dialog.dart';
import 'package:accident_data_storage/widgets/dropdown_widget.dart';
import 'package:accident_data_storage/widgets/picker_util.dart';
import 'package:accident_data_storage/widgets/picker_widget.dart';
import 'package:accident_data_storage/widgets/validation_error_text.dart';
import 'package:flutter/material.dart';
import 'package:accident_data_storage/services/supabase_service.dart';
import 'package:accident_data_storage/models/item.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccidentPage extends StatefulWidget {
  final Accident? accident;
  final bool isEditing;

  const AccidentPage({
    super.key,
    this.accident,
    required this.isEditing,
  });

  @override
  AccidentPageState createState() => AccidentPageState();
}

class AccidentPageState extends State<AccidentPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Fields for form data
  String? selectedConstructionField;
  String? selectedConstructionType;
  String? selectedWorkType;
  String? selectedConstructionMethod;
  String? selectedDisasterCategory;
  String? selectedAccidentCategory;
  String? selectedWeather;

  String? accidentBackground;
  String? accidentCause;
  String? accidentCountermeasure;

  int? accidentYear;
  int? accidentMonth;
  int? accidentTime;

  int? zipcode;
  String? accidentLocationPref;
  String? addressDetail;

  // Dropdown items
  List<Item> constructionFieldItems = [];
  List<Item> constructionTypeItems = [];
  List<Item> workTypeItems = [];
  List<Item> constructionMethodItems = [];
  List<Item> disasterCategoryItems = [];
  List<Item> accidentCategoryItems = [];
  List<Item> weatherItems = [];
  List<Item> accidentLocationPrefItems = [];

  bool showErrorConstructionField = false;
  bool showErrorConstructionType = false;
  bool showErrorWorkType = false;
  bool showErrorConstructionMethod = false;
  bool showErrorDisasterCategory = false;
  bool showErrorAccidentCategory = false;
  bool showErrorAccidentLocationPref = false;
  bool showErrorAccidentYear = false;
  bool showErrorAccidentMonth = false;
  bool showErrorAccidentTime = false;

  @override
  void initState() {
    super.initState();
    fetchDropDownItems();
    if (widget.isEditing && widget.accident != null) {
      // Pre-fill fields for editing
      selectedConstructionField = widget.accident!.constructionField;
      selectedConstructionType = widget.accident!.constructionType;
      selectedWorkType = widget.accident!.workType;
      selectedConstructionMethod = widget.accident!.constructionMethod;
      selectedDisasterCategory = widget.accident!.disasterCategory;
      selectedAccidentCategory = widget.accident!.accidentCategory;
      selectedWeather = widget.accident?.weather;
      accidentLocationPref = widget.accident!.accidentLocationPref;
      accidentBackground = widget.accident?.accidentBackground;
      accidentCause = widget.accident?.accidentCause;
      accidentCountermeasure = widget.accident?.accidentCountermeasure;
      accidentYear = widget.accident!.accidentYear;
      accidentMonth = widget.accident!.accidentMonth;
      accidentTime = widget.accident!.accidentTime;

      zipcode = widget.accident!.zipcode;
      addressDetail = widget.accident!.addressDetail;
      _zipCodeController.text = zipcode != null ? zipcode.toString() : '';
      _addressController.text = addressDetail ?? '';
    }
  }

  // Fetch items for dropdown lists
  Future<void> fetchDropDownItems() async {
    constructionFieldItems =
        await _supabaseService.fetchItems('ConstructionField');
    constructionTypeItems =
        await _supabaseService.fetchItems('ConstructionType');
    workTypeItems = await _supabaseService.fetchItems('WorkType');
    constructionMethodItems =
        await _supabaseService.fetchItems('ConstructionMethod');
    disasterCategoryItems =
        await _supabaseService.fetchItems('DisasterCategory');
    accidentCategoryItems =
        await _supabaseService.fetchItems('AccidentCategory');
    weatherItems = await _supabaseService.fetchItems('Weather');
    accidentLocationPrefItems =
        await _supabaseService.fetchItems('AccidentLocationPref');

    setState(() {}); // Update the UI after fetching items
  }

  Future<void> handleZipCodeSubmit(String zipCode) async {
    final address = await fetchAddressFromZipCode(zipCode);

    if (address != null) {
      setState(() {
        _addressController.text = '${address.address2} ${address.address3}';

        accidentLocationPref = accidentLocationPrefItems
            .firstWhere((item) => item.itemName == address.address1)
            .itemValue;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.fillInRequired)),
        );
      }
    }
  }

  Future<void> saveAccident() async {
    if (widget.isEditing && widget.accident != null) {
      // Retrieve the latest values from the controllers
      zipcode = int.tryParse(_zipCodeController.text);
      addressDetail = _addressController.text;

      // Update the accident record
      Map<String, dynamic> updatedAccidentData = {
        'ConstructionField': selectedConstructionField,
        'ConstructionType': selectedConstructionType,
        'WorkType': selectedWorkType,
        'ConstructionMethod': selectedConstructionMethod,
        'DisasterCategory': selectedDisasterCategory,
        'AccidentCategory': selectedAccidentCategory,
        'Weather': selectedWeather,
        'AccidentLocationPref': accidentLocationPref,
        'AccidentYear': accidentYear,
        'AccidentMonth': accidentMonth,
        'AccidentTime': accidentTime,
        'AccidentBackground': accidentBackground,
        'AccidentCause': accidentCause,
        'AccidentCountermeasure': accidentCountermeasure,
        'Zipcode': zipcode,
        'AddressDetail': _addressController.text,
      };
      await _supabaseService.updateAccident(
          widget.accident!.accidentId, updatedAccidentData);
    } else {
      // Add new accident record
      Map<String, dynamic> newAccidentData = {
        'ConstructionField': selectedConstructionField,
        'ConstructionType': selectedConstructionType,
        'WorkType': selectedWorkType,
        'ConstructionMethod': selectedConstructionMethod,
        'DisasterCategory': selectedDisasterCategory,
        'AccidentCategory': selectedAccidentCategory,
        'Weather': selectedWeather,
        'AccidentLocationPref': accidentLocationPref,
        'AccidentYear': accidentYear,
        'AccidentMonth': accidentMonth,
        'AccidentTime': accidentTime,
        'AccidentBackground': accidentBackground,
        'AccidentCause': accidentCause,
        'AccidentCountermeasure': accidentCountermeasure,
        'Zipcode': zipcode,
        'AddressDetail': _addressController.text,
      };
      await _supabaseService.addAccident(newAccidentData);
    }
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  // Method to submit the form and add new accident data
  Future<void> addAccident() async {
    // Retrieve the latest values from the controllers
    zipcode = int.tryParse(_zipCodeController.text);
    addressDetail = _addressController.text;

    setState(() {
      showErrorConstructionField = selectedConstructionField == null;
      showErrorConstructionType = selectedConstructionType == null;
      showErrorWorkType = selectedWorkType == null;
      showErrorConstructionMethod = selectedConstructionMethod == null;
      showErrorDisasterCategory = selectedDisasterCategory == null;
      showErrorAccidentCategory = selectedAccidentCategory == null;
      showErrorAccidentLocationPref = accidentLocationPref == null;
      showErrorAccidentYear = accidentYear == null;
      showErrorAccidentMonth = accidentMonth == null;
      showErrorAccidentTime = accidentTime == null;
    });

    if (!showErrorConstructionField &&
        !showErrorConstructionType &&
        !showErrorWorkType &&
        !showErrorConstructionMethod &&
        !showErrorDisasterCategory &&
        !showErrorAccidentCategory &&
        !showErrorAccidentLocationPref &&
        !showErrorAccidentYear &&
        !showErrorAccidentMonth &&
        !showErrorAccidentTime) {
      // Proceed with saving data
      Map<String, dynamic> newAccidentData = {
        'ConstructionField': selectedConstructionField,
        'ConstructionType': selectedConstructionType,
        'WorkType': selectedWorkType,
        'ConstructionMethod': selectedConstructionMethod,
        'DisasterCategory': selectedDisasterCategory,
        'AccidentCategory': selectedAccidentCategory,
        'Weather': selectedWeather,
        'AccidentLocationPref': accidentLocationPref,
        'AccidentYear': accidentYear,
        'AccidentMonth': accidentMonth,
        'AccidentTime': accidentTime,
        'AccidentBackground': accidentBackground,
        'AccidentCause': accidentCause,
        'AccidentCountermeasure': accidentCountermeasure,
      };
      await _supabaseService.addAccident(newAccidentData);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fillInRequired)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing && widget.accident != null
              ? '${localizations.accidentID}: ${widget.accident!.accidentId}' // Display AccidentId if editing
              : localizations
                  .create, // Display a default title if adding new data
        ),
        actions: widget.isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    // Confirm the deletion with the user
                    bool? confirmDelete = await showDialog(
                      context: context,
                      builder: (context) => const DeleteConfirmationDialog(),
                    );
                    // If confirmed, delete the accident
                    if (confirmDelete == true) {
                      await _supabaseService
                          .deleteAccident(widget.accident!.accidentId);
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      } // Return to the previous screen
                    }
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdowns for construction field, type, and others
            CustomDropdown(
              label: localizations.constructionType,
              value: selectedConstructionField,
              items: constructionFieldItems,
              onChanged: (value) {
                setState(() {
                  selectedConstructionField = value;
                });
              },
            ),
            if (showErrorConstructionField) const ValidationErrorText(),
            CustomDropdown(
              label: localizations.constructionField,
              value: selectedConstructionType,
              items: constructionTypeItems,
              onChanged: (value) {
                setState(() {
                  selectedConstructionType = value;
                });
              },
            ),
            if (showErrorConstructionType) const ValidationErrorText(),
            CustomDropdown(
              label: localizations.workType,
              value: selectedWorkType,
              items: workTypeItems,
              onChanged: (value) {
                setState(() {
                  selectedWorkType = value;
                });
              },
            ),
            if (showErrorWorkType) const ValidationErrorText(),
            CustomDropdown(
              label: localizations.constructionMethod,
              value: selectedConstructionMethod,
              items: constructionMethodItems,
              onChanged: (value) {
                setState(() {
                  selectedConstructionMethod = value;
                });
              },
            ),
            if (showErrorConstructionMethod) const ValidationErrorText(),
            CustomDropdown(
              label: localizations.disasterCategory,
              value: selectedDisasterCategory,
              items: disasterCategoryItems,
              onChanged: (value) {
                setState(() {
                  selectedDisasterCategory = value;
                });
              },
            ),
            if (showErrorDisasterCategory) const ValidationErrorText(),
            CustomDropdown(
              label: localizations.accidentCategory,
              value: selectedAccidentCategory,
              items: accidentCategoryItems,
              onChanged: (value) {
                setState(() {
                  selectedAccidentCategory = value;
                });
              },
            ),
            if (showErrorAccidentCategory) const ValidationErrorText(),
            CustomDropdown(
              label: localizations.weather,
              value: selectedWeather,
              items: weatherItems,
              onChanged: (value) {
                setState(() {
                  selectedWeather = value;
                });
              },
            ),
            TextFormField(
              controller: _zipCodeController,
              decoration: InputDecoration(
                labelText: localizations.zipcode,
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(7)],
              keyboardType: TextInputType.number,
              onChanged: (value) {
                zipcode = int.tryParse(value);
                if (value.length == 7) {
                  handleZipCodeSubmit(value);
                }
              },
              onFieldSubmitted: handleZipCodeSubmit,
            ),

            CustomDropdown(
              label: localizations.accidentLocationPref,
              value: accidentLocationPref,
              items: accidentLocationPrefItems,
              onChanged: (value) {
                setState(() {
                  accidentLocationPref = value;
                });
              },
            ),
            if (showErrorAccidentLocationPref) const ValidationErrorText(),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: localizations.address,
              ),
              onChanged: (value) {
                addressDetail = value;
              },
            ),
            // Pickers for year, month, and time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => PickerUtil.showPicker(
                      context: context,
                      items: List<int>.generate(100, (index) => 2024 - index),
                      title: localizations.accidentYear,
                      onSelected: (value) {
                        setState(() {
                          accidentYear = value;
                        });
                      },
                    ),
                    child: CustomPicker(
                      label: localizations.accidentYear,
                      value: accidentYear,
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => PickerUtil.showPicker(
                      context: context,
                      items: List<int>.generate(12, (index) => index + 1),
                      title: localizations.accidentMonth,
                      onSelected: (value) {
                        setState(() {
                          accidentMonth = value;
                        });
                      },
                    ),
                    child: CustomPicker(
                      label: localizations.accidentMonth,
                      value: accidentMonth,
                    ),
                  ),
                ),
              ],
            ),
            if (showErrorAccidentYear & showErrorAccidentMonth)
              const ValidationErrorText(),
            InkWell(
              onTap: () => PickerUtil.showPicker(
                context: context,
                items: List<int>.generate(24, (index) => index),
                title: localizations.accidentTime,
                onSelected: (value) {
                  setState(() {
                    accidentTime = value;
                  });
                },
              ),
              child: CustomPicker(
                label: localizations.accidentTime,
                value: accidentTime,
              ),
            ),
            if (showErrorAccidentTime) const ValidationErrorText(),

            TextFormField(
              decoration: InputDecoration(
                labelText: localizations.accidentBackground,
              ),
              initialValue: accidentBackground,
              keyboardType: TextInputType.multiline,
              maxLines: null, // 複数行対応
              onChanged: (value) {
                accidentBackground = value;
              },
            ),

            // 事故の要因（背景も含む）入力フィールド
            TextFormField(
              decoration: InputDecoration(
                labelText: localizations.accidentCause,
              ),
              initialValue: accidentCause,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onChanged: (value) {
                accidentCause = value;
              },
            ),

            // 事故発生後の対策入力フィールド
            TextFormField(
              initialValue: accidentCountermeasure,
              decoration: InputDecoration(
                labelText: localizations.accidentCountermeasure,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null, // 複数行対応
              onChanged: (value) {
                accidentCountermeasure = value;
              },
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 100,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: widget.isEditing ? saveAccident : addAccident,
                    child: Text(
                      widget.isEditing
                          ? AppLocalizations.of(context)!.update
                          : AppLocalizations.of(context)!.save,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
