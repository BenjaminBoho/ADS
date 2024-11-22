import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/models/accident_data.dart';
import 'package:accident_data_storage/models/stakeholder_data.dart';
import 'package:accident_data_storage/providers/accident_provider.dart';
import 'package:accident_data_storage/providers/dropdown_provider.dart';
import 'package:accident_data_storage/providers/stakeholder_provider.dart';
import 'package:accident_data_storage/services/supabase_service.dart';
import 'package:accident_data_storage/widgets/delete_confirmation_dialog.dart';
import 'package:accident_data_storage/widgets/dropdown_widget.dart';
import 'package:accident_data_storage/widgets/picker_util.dart';
import 'package:accident_data_storage/widgets/picker_widget.dart';
import 'package:accident_data_storage/widgets/validation_error_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:accident_data_storage/models/stakeholder.dart';

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

  String? stakeholderRole;
  String? stakeholderName;

  List<Stakeholder> stakeholders = [];
  List<TextEditingController> stakeholderNameControllers = [];
  List<int> stakeholdersToDelete = [];

  List<StakeholderData> getValidStakeholdersForCreation(int accidentId) {
    return stakeholders.where((stakeholder) {
      return stakeholder.role.isNotEmpty && stakeholder.name.isNotEmpty;
    }).map((stakeholder) {
      return StakeholderData(
        accidentId: accidentId,
        role: stakeholder.role,
        name: stakeholder.name,
      );
    }).toList();
  }

  List<Stakeholder> getValidStakeholdersForUpdate() {
    return stakeholders.where((stakeholder) {
      return stakeholder.role.isNotEmpty && stakeholder.name.isNotEmpty;
    }).toList();
  }

  Map<String, bool> validationErrors = {
    'constructionField': false,
    'constructionType': false,
    'workType': false,
    'constructionMethod': false,
    'disasterCategory': false,
    'accidentCategory': false,
    'accidentLocationPref': false,
    'accidentYear': false,
    'accidentMonth': false,
    'accidentTime': false,
  };

  void validateFields() {
    setState(() {
      validationErrors['constructionField'] = selectedConstructionField == null;
      validationErrors['constructionType'] = selectedConstructionType == null;
      validationErrors['workType'] = selectedWorkType == null;
      validationErrors['constructionMethod'] =
          selectedConstructionMethod == null;
      validationErrors['disasterCategory'] = selectedDisasterCategory == null;
      validationErrors['accidentCategory'] = selectedAccidentCategory == null;
      validationErrors['accidentLocationPref'] = accidentLocationPref == null;
      validationErrors['accidentYear'] = accidentYear == null;
      validationErrors['accidentMonth'] = accidentMonth == null;
      validationErrors['accidentTime'] = accidentTime == null;
    });
  }

  bool isFormValid() {
    validateFields();
    return !validationErrors.containsValue(true);
  }

  @override
  void initState() {
    super.initState();

    // Debugging
    final supabaseService =
        Provider.of<SupabaseService>(context, listen: false);
    debugPrint('SupabaseService initialized: $supabaseService');

    final dropdownProvider =
        Provider.of<DropdownProvider>(context, listen: false);
    dropdownProvider.fetchAllDropdownItems();

    if (widget.isEditing && widget.accident != null) {
      // Pre-fill accident fields
      populateFields(widget.accident!);

      // Fetch stakeholders for editing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<StakeholderProvider>(context, listen: false)
            .fetchStakeholders(widget.accident!.accidentId)
            .then((fetchedStakeholders) {
          setState(() {
            stakeholders = fetchedStakeholders;

            // Ensure at least one empty stakeholder row exists for editing
            if (stakeholders.isEmpty) {
              _addStakeholder();
            }

            stakeholderNameControllers = stakeholders
                .map((stakeholder) =>
                    TextEditingController(text: stakeholder.name))
                .toList();
          });
        });
      });
    } else {
      // Add an empty stakeholder row by default when creating a new accident
      _addStakeholder();
    }
  }

  void _addStakeholder() {
    setState(() {
      stakeholders.add(Stakeholder(
        stakeholderId: 0, // Temporary placeholder
        accidentId:
            widget.accident?.accidentId ?? 0, // Assign accidentId if editing
        role: '',
        name: '',
      ));
      stakeholderNameControllers.add(TextEditingController());
    });
  }

  void _removeStakeholder(int index) {
    setState(() {
      if (index < stakeholders.length) {
        if (stakeholders[index].stakeholderId != 0) {
          stakeholdersToDelete.add(stakeholders[index].stakeholderId);
          debugPrint(
              'Stakeholder marked for deletion: ${stakeholders[index].stakeholderId}');
        }
        stakeholders.removeAt(index);
        stakeholderNameControllers[index].dispose();
        stakeholderNameControllers.removeAt(index);
      }
    });
  }

  void populateFields(Accident accident) {
    selectedConstructionField = accident.constructionField;
    selectedConstructionType = accident.constructionType;
    selectedWorkType = accident.workType;
    selectedConstructionMethod = accident.constructionMethod;
    selectedDisasterCategory = accident.disasterCategory;
    selectedAccidentCategory = accident.accidentCategory;
    selectedWeather = accident.weather;
    accidentLocationPref = accident.accidentLocationPref;
    accidentBackground = accident.accidentBackground;
    accidentCause = accident.accidentCause;
    accidentCountermeasure = accident.accidentCountermeasure;
    accidentYear = accident.accidentYear;
    accidentMonth = accident.accidentMonth;
    accidentTime = accident.accidentTime;
    zipcode = accident.zipcode;
    addressDetail = accident.addressDetail;

    // Initialize text fields for zip code and address
    _zipCodeController.text = zipcode != null ? zipcode.toString() : '';
    _addressController.text = addressDetail ?? '';
  }

  Future<void> handleZipCodeSubmit(String zipCode) async {
    final dropdownProvider =
        Provider.of<DropdownProvider>(context, listen: false);
    final accidentProvider =
        Provider.of<AccidentProvider>(context, listen: false);

    final prefValue = await accidentProvider.handleZipCodeSubmit(
      zipCode,
      _addressController,
      dropdownProvider.accidentLocationPrefItems,
    );

    if (prefValue != null) {
      setState(() {
        accidentLocationPref = prefValue;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noAddressFound)),
        );
      }
    }
  }

  Future<void> saveAccident() async {
    final accidentProvider =
        Provider.of<AccidentProvider>(context, listen: false);
    final stakeholderProvider =
        Provider.of<StakeholderProvider>(context, listen: false);

    final updatedAccident = Accident(
      accidentId: widget.accident!.accidentId,
      constructionField: selectedConstructionField!,
      constructionType: selectedConstructionType!,
      workType: selectedWorkType!,
      constructionMethod: selectedConstructionMethod!,
      disasterCategory: selectedDisasterCategory!,
      accidentCategory: selectedAccidentCategory!,
      weather: selectedWeather,
      accidentYear: accidentYear!,
      accidentMonth: accidentMonth!,
      accidentTime: accidentTime!,
      accidentLocationPref: accidentLocationPref!,
      accidentBackground: accidentBackground,
      accidentCause: accidentCause,
      accidentCountermeasure: accidentCountermeasure,
      zipcode: int.tryParse(_zipCodeController.text),
      addressDetail: _addressController.text,
    );

    // Update accident data
    await accidentProvider.updateAccident(updatedAccident);

    // Handle stakeholder updates
    final validStakeholders = getValidStakeholdersForUpdate();
    final newStakeholders =
        stakeholders.where((s) => s.stakeholderId == 0).toList();

    for (var stakeholder in validStakeholders) {
      await stakeholderProvider.updateStakeholder(stakeholder);
    }

    for (var newStakeholder in newStakeholders) {
      final stakeholderData = StakeholderData(
        accidentId: widget.accident!.accidentId,
        role: newStakeholder.role,
        name: newStakeholder.name,
      );
      await stakeholderProvider.addStakeholdersForAccident(
          widget.accident!.accidentId, [stakeholderData]);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  // Method to submit the form and add new accident data
  Future<void> addAccident() async {
    if (isFormValid()) {
      final newAccident = AccidentData(
        constructionField: selectedConstructionField!,
        constructionType: selectedConstructionType!,
        workType: selectedWorkType!,
        constructionMethod: selectedConstructionMethod!,
        disasterCategory: selectedDisasterCategory!,
        accidentCategory: selectedAccidentCategory!,
        weather: selectedWeather,
        accidentYear: accidentYear!,
        accidentMonth: accidentMonth!,
        accidentTime: accidentTime!,
        accidentLocationPref: accidentLocationPref!,
        accidentBackground: accidentBackground,
        accidentCause: accidentCause,
        accidentCountermeasure: accidentCountermeasure,
        zipcode: int.tryParse(_zipCodeController.text),
        addressDetail: _addressController.text,
      );

      final validStakeholders = getValidStakeholdersForCreation(0);

      // Decide which method to use
      if (validStakeholders.isNotEmpty) {
        await Provider.of<SupabaseService>(context, listen: false)
            .addAccidentWithStakeholders(
          newAccident.toMap(),
          validStakeholders.map((s) => s.toMap()).toList(),
        );
      } else {
        await Provider.of<SupabaseService>(context, listen: false)
            .addAccident(newAccident.toMap());
      }

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
    final dropdownProvider = Provider.of<DropdownProvider>(context);
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
                      if (context.mounted) {
                        await Provider.of<AccidentProvider>(context,
                                listen: false)
                            .deleteAccident(widget.accident!.accidentId);
                      }
                      if (context.mounted) {
                        Navigator.pop(
                            context, true); // Return to the previous screen
                      }
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
              label: localizations.constructionField,
              value: selectedConstructionField,
              items: dropdownProvider.constructionFieldItems,
              onChanged: (value) {
                setState(() {
                  selectedConstructionField = value;
                });
              },
            ),
            if (validationErrors['constructionField']!)
              const ValidationErrorText(),
            CustomDropdown(
              label: localizations.constructionType,
              value: selectedConstructionType,
              items: dropdownProvider.constructionTypeItems,
              onChanged: (value) {
                setState(() {
                  selectedConstructionType = value;
                });
              },
            ),
            if (validationErrors['constructionType']!)
              const ValidationErrorText(),
            CustomDropdown(
              label: localizations.workType,
              value: selectedWorkType,
              items: dropdownProvider.workTypeItems,
              onChanged: (value) {
                setState(() {
                  selectedWorkType = value;
                });
              },
            ),
            if (validationErrors['workType']!) const ValidationErrorText(),
            CustomDropdown(
              label: localizations.constructionMethod,
              value: selectedConstructionMethod,
              items: dropdownProvider.constructionMethodItems,
              onChanged: (value) {
                setState(() {
                  selectedConstructionMethod = value;
                });
              },
            ),
            if (validationErrors['constructionMethod']!)
              const ValidationErrorText(),
            CustomDropdown(
              label: localizations.disasterCategory,
              value: selectedDisasterCategory,
              items: dropdownProvider.disasterCategoryItems,
              onChanged: (value) {
                setState(() {
                  selectedDisasterCategory = value;
                });
              },
            ),
            if (validationErrors['disasterCategory']!)
              const ValidationErrorText(),
            CustomDropdown(
              label: localizations.accidentCategory,
              value: selectedAccidentCategory,
              items: dropdownProvider.accidentCategoryItems,
              onChanged: (value) {
                setState(() {
                  selectedAccidentCategory = value;
                });
              },
            ),
            if (validationErrors['accidentCategory']!)
              const ValidationErrorText(),
            CustomDropdown(
              label: localizations.weather,
              value: selectedWeather,
              items: dropdownProvider.weatherItems,
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
              items: dropdownProvider.accidentLocationPrefItems,
              onChanged: (value) {
                setState(() {
                  accidentLocationPref = value;
                });
              },
            ),
            if (validationErrors['accidentLocationPref']!)
              const ValidationErrorText(),
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
            if (validationErrors['accidentYear']! &&
                validationErrors['accidentMonth']!)
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
            if (validationErrors['accidentTime']!) const ValidationErrorText(),
            // Stakeholder Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: List.generate(stakeholders.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          // Role dropdown
                          Expanded(
                            flex: 3,
                            child: CustomDropdown(
                              label:
                                  AppLocalizations.of(context)!.stakeholderRole,
                              value: stakeholders[index].role.isEmpty
                                  ? null
                                  : stakeholders[index].role,
                              items: dropdownProvider.stakeholder,
                              onChanged: (value) {
                                setState(() {
                                  stakeholders[index].role = value ?? '';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Name text field
                          Expanded(
                            flex: 5,
                            child: TextField(
                              controller: stakeholderNameControllers[index],
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .stakeholderName,
                              ),
                              onChanged: (value) {
                                stakeholders[index].name = value;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Add or Delete button logic
                          if (index ==
                              stakeholders.length -
                                  1) // Last row gets the add button
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.grey),
                              onPressed: _addStakeholder,
                            )
                          else // All other rows get the delete button
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () => _removeStakeholder(index),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),

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
