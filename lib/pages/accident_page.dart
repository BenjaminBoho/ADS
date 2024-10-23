import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/widgets/delete_confirmation_dialog.dart';
import 'package:accident_data_storage/widgets/dropdown_widget.dart';
import 'package:accident_data_storage/widgets/picker_util.dart';
import 'package:accident_data_storage/widgets/picker_widget.dart';
import 'package:accident_data_storage/widgets/save_button.dart';
import 'package:accident_data_storage/widgets/text_field_widget.dart';
import 'package:accident_data_storage/widgets/validation_error_text.dart';
import 'package:flutter/material.dart';
import 'package:accident_data_storage/services/supabase_service.dart';
import 'package:accident_data_storage/models/item.dart';

class AccidentPage extends StatefulWidget {
  final Accident? accident; // Accident object for editing mode
  final bool isEditing; // Flag to indicate if this is edit mode

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

  // Fields for form data
  String? selectedConstructionField;
  String? selectedConstructionType;
  String? selectedWorkType;
  String? selectedConstructionMethod;
  String? selectedDisasterCategory;
  String? selectedAccidentCategory;
  String? selectedWeather;
  String? selectedAccidentLocationPref;

  String? accidentBackground;
  String? accidentCause;
  String? accidentCountermeasure;

  int? accidentYear;
  int? accidentMonth;
  int? accidentTime;

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
    fetchItems(); // Fetch items for dropdowns
    if (widget.isEditing && widget.accident != null) {
      // Pre-fill fields for editing
      selectedConstructionField = widget.accident!.constructionField;
      selectedConstructionType = widget.accident!.constructionType;
      selectedWorkType = widget.accident!.workType;
      selectedConstructionMethod = widget.accident!.constructionMethod;
      selectedDisasterCategory = widget.accident!.disasterCategory;
      selectedAccidentCategory = widget.accident!.accidentCategory;
      selectedWeather = widget.accident?.weather;
      selectedAccidentLocationPref = widget.accident!.accidentLocationPref;
      accidentBackground = widget.accident?.accidentBackground;
      accidentCause = widget.accident?.accidentCause;
      accidentCountermeasure = widget.accident?.accidentCountermeasure;
      accidentYear = widget.accident!.accidentYear;
      accidentMonth = widget.accident!.accidentMonth;
      accidentTime = widget.accident!.accidentTime;
    }
  }

  // Fetch items for dropdown lists
  Future<void> fetchItems() async {
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

  Future<void> saveAccident() async {
    if (widget.isEditing && widget.accident != null) {
      // Update the accident record
      Map<String, dynamic> updatedAccidentData = {
        'ConstructionField': selectedConstructionField,
        'ConstructionType': selectedConstructionType,
        'WorkType': selectedWorkType,
        'ConstructionMethod': selectedConstructionMethod,
        'DisasterCategory': selectedDisasterCategory,
        'AccidentCategory': selectedAccidentCategory,
        'Weather': selectedWeather,
        'AccidentLocationPref': selectedAccidentLocationPref,
        'AccidentYear': accidentYear,
        'AccidentMonth': accidentMonth,
        'AccidentTime': accidentTime,
        'AccidentBackground': accidentBackground,
        'AccidentCause': accidentCause,
        'AccidentCountermeasure': accidentCountermeasure,
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
        'AccidentLocationPref': selectedAccidentLocationPref,
        'AccidentYear': accidentYear,
        'AccidentMonth': accidentMonth,
        'AccidentTime': accidentTime,
        'AccidentBackground': accidentBackground,
        'AccidentCause': accidentCause,
        'AccidentCountermeasure': accidentCountermeasure,
      };
      await _supabaseService.addAccident(newAccidentData);
    }

    Navigator.pop(context, true);
  }

  // Method to submit the form and add new accident data
  Future<void> addAccident() async {
    setState(() {
      showErrorConstructionField = selectedConstructionField == null;
      showErrorConstructionType = selectedConstructionType == null;
      showErrorWorkType = selectedWorkType == null;
      showErrorConstructionMethod = selectedConstructionMethod == null;
      showErrorDisasterCategory = selectedDisasterCategory == null;
      showErrorAccidentCategory = selectedAccidentCategory == null;
      showErrorAccidentLocationPref = selectedAccidentLocationPref == null;
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
        'AccidentLocationPref': selectedAccidentLocationPref,
        'AccidentYear': accidentYear,
        'AccidentMonth': accidentMonth,
        'AccidentTime': accidentTime,
        'AccidentBackground': accidentBackground,
        'AccidentCause': accidentCause,
        'AccidentCountermeasure': accidentCountermeasure,
      };
      await _supabaseService.addAccident(newAccidentData);
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('必要な項目を入力してください')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing && widget.accident != null
              ? '事故ID: ${widget.accident!.accidentId}' // Display AccidentId if editing
              : '新規作成', // Display a default title if adding new data
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
                      Navigator.pop(
                          context, true); // Return to the previous screen
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
              label: '工事分野',
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
              label: '工事の種類',
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
              label: '工種',
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
              label: '工法・形式名',
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
              label: '災害分類',
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
              label: '事故分類',
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
              label: '天候',
              value: selectedWeather,
              items: weatherItems,
              onChanged: (value) {
                setState(() {
                  selectedWeather = value;
                });
              },
            ),
            CustomDropdown(
              label: '事故発生場所（都道府県）',
              value: selectedAccidentLocationPref,
              items: accidentLocationPrefItems,
              onChanged: (value) {
                setState(() {
                  selectedAccidentLocationPref = value;
                });
              },
            ),
            if (showErrorAccidentLocationPref) const ValidationErrorText(),
            // Pickers for year, month, and time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => PickerUtil.showPicker(
                      context: context,
                      items: List<int>.generate(100, (index) => 2024 - index),
                      title: '事故発生年',
                      onSelected: (value) {
                        setState(() {
                          accidentYear = value;
                        });
                      },
                    ),
                    child: CustomPicker(
                      label: '事故発生年',
                      value: accidentYear,
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => PickerUtil.showPicker(
                      context: context,
                      items: List<int>.generate(12, (index) => index + 1),
                      title: '事故発生月',
                      onSelected: (value) {
                        setState(() {
                          accidentMonth = value;
                        });
                      },
                    ),
                    child: CustomPicker(
                      label: '事故発生月',
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
                title: '事故発生時間',
                onSelected: (value) {
                  setState(() {
                    accidentTime = value;
                  });
                },
              ),
              child: CustomPicker(
                label: '事故発生時間',
                value: accidentTime,
              ),
            ),
            if (showErrorAccidentTime) const ValidationErrorText(),
            // Accident background, cause, and countermeasure text fields
            CustomTextField(
              label: '事故に至る経緯と事故の状況',
              initialValue: accidentBackground,
              onChanged: (value) {
                accidentBackground = value;
              },
            ),
            CustomTextField(
              label: '事故の要因（背景も含む）',
              initialValue: accidentCause,
              onChanged: (value) {
                accidentCause = value;
              },
            ),
            CustomTextField(
              label: '事故発生後の対策',
              initialValue: accidentCountermeasure,
              onChanged: (value) {
                accidentCountermeasure = value;
              },
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SaveButton(
                  isEditing: widget.isEditing,
                  onPressed: widget.isEditing ? saveAccident : addAccident,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
