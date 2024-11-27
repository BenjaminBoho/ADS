import 'package:accident_data_storage/models/accident.dart';
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
  final List<Stakeholder> stakeholders;

  const AccidentPage({
    super.key,
    this.accident,
    required this.isEditing,
    required this.stakeholders,
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

  List<Stakeholder> getValidStakeholdersForCreation(int accidentId) {
    return stakeholders.where((stakeholder) {
      return stakeholder.role.isNotEmpty && stakeholder.name.isNotEmpty;
    }).map((stakeholder) {
      return Stakeholder(
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

  @override
  void initState() {
    super.initState();

    final dropdownProvider =
        Provider.of<DropdownProvider>(context, listen: false);
    dropdownProvider.fetchAllDropdownItems();

    if (widget.isEditing && widget.accident != null) {
      // Pre-fill accident fields
      populateFields(widget.accident!);

      // Fetch stakeholders for editing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchStakeholdersForAccident(widget.accident!.accidentId!);
      });
    } else {
      // Add an empty stakeholder row by default when creating a new accident
      _addStakeholder();
    }
  }

  Future<void> fetchStakeholdersForAccident(int accidentId) async {
    final stakeholderProvider =
        Provider.of<StakeholderProvider>(context, listen: false);
    final fetchedStakeholders =
        await stakeholderProvider.fetchStakeholders(accidentId);

    setState(() {
      stakeholders = fetchedStakeholders;
      stakeholderNameControllers = List.generate(
        stakeholders.length,
        (index) => TextEditingController(
          text: stakeholders[index].name.isNotEmpty
              ? stakeholders[index].name
              : '',
        ),
      );

      // Add an empty stakeholder row for new input
      _addStakeholder();
    });
  }

  Future<void> handleStakeholders({
    required int accidentId,
    required List<int> stakeholdersToDelete,
  }) async {
    final stakeholderProvider =
        Provider.of<StakeholderProvider>(context, listen: false);

    // Add or update stakeholders
    for (var stakeholder in stakeholders) {
      if (stakeholder.role.isNotEmpty && stakeholder.name.isNotEmpty) {
        if (stakeholder.stakeholderId == null) {
          // Add new stakeholder
          await stakeholderProvider.addStakeholdersForAccident(
            accidentId,
            [stakeholder],
          );
        } else {
          // Update existing stakeholder
          await stakeholderProvider.updateStakeholder(stakeholder);
        }
      }
    }

    // Delete marked stakeholders
    for (var stakeholderId in stakeholdersToDelete) {
      await stakeholderProvider.deleteStakeholder(stakeholderId, accidentId);
    }
  }

  void _addStakeholder() {
    setState(() {
      stakeholders.add(
        Stakeholder(
          stakeholderId: null,
          accidentId: widget.accident?.accidentId ?? 0,
          role: '',
          name: '',
        ),
      );
      stakeholderNameControllers.add(TextEditingController());
    });
  }

  void _removeStakeholder(int index) {
    setState(() {
      if (index < stakeholders.length) {
        // Mark stakeholder for deletion if it has a valid ID
        if (stakeholders[index].stakeholderId != 0) {
          stakeholdersToDelete.add(stakeholders[index].stakeholderId!);
          debugPrint(
              'Stakeholder marked for deletion: ${stakeholders[index].stakeholderId}');
        }

        // Remove stakeholder from the list and dispose its controller
        stakeholders.removeAt(index);
        stakeholderNameControllers[index].dispose();
        stakeholderNameControllers.removeAt(index);

        debugPrint('Current stakeholders to delete: $stakeholdersToDelete');
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
    if (!isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fillInRequired)),
      );
      return;
    }

    final accidentProvider =
        Provider.of<AccidentProvider>(context, listen: false);

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

    // Update stakeholders
    await handleStakeholders(
      accidentId: widget.accident!.accidentId!,
      stakeholdersToDelete: stakeholdersToDelete,
    );

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  bool isFormValid() {
    validateFields();
    return !validationErrors.containsValue(true);
  }

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

  Future<List<Map<String, dynamic>>> prepareStakeholdersForCreation(
      int accidentId) async {
    return getValidStakeholdersForCreation(accidentId)
        .map((stakeholder) => stakeholder.toMap())
        .toList();
  }

  // Method to submit the form and add new accident data
  Future<void> addAccident() async {
    if (!isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fillInRequired)),
      );
      return;
    }

    final newAccident = Accident(
      accidentId: null, // null because it's auto-generated
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
      stakeholders: [], // This will be handled separately
    );

    final supabaseService =
        Provider.of<SupabaseService>(context, listen: false);

    try {
      // Prepare stakeholders for creation
      final stakeholders = await prepareStakeholdersForCreation(0);

      if (stakeholders.isNotEmpty) {
        // Add accident with stakeholders
        await supabaseService.addAccidentWithStakeholders(
          newAccident.toMap(),
          stakeholders,
        );
      } else {
        // Add accident without stakeholders
        await supabaseService.addAccident(newAccident.toMap());
      }

      // Navigate back with success
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      // Handle any errors during the process
      debugPrint('Error adding accident: $error');
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
              : localizations.create,
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
                            .deleteAccident(widget.accident!.accidentId!);
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
                              value: stakeholders[index].role.isNotEmpty
                                  ? stakeholders[index].role
                                  : null,
                              items: dropdownProvider.stakeholder,
                              onChanged: (value) {
                                setState(() {
                                  stakeholders[index] = Stakeholder(
                                    stakeholderId:
                                        stakeholders[index].stakeholderId,
                                    accidentId: stakeholders[index].accidentId,
                                    role: value ?? '',
                                    name: stakeholders[index].name,
                                  );
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: TextField(
                              controller: stakeholderNameControllers[index],
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .stakeholderName,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  stakeholders[index] = Stakeholder(
                                    stakeholderId:
                                        stakeholders[index].stakeholderId,
                                    accidentId: stakeholders[index].accidentId,
                                    role: stakeholders[index].role,
                                    name: value,
                                  );
                                });
                              },
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Add or Delete button
                          IconButton(
                            icon: index == stakeholders.length - 1
                                ? const Icon(Icons.add, color: Colors.grey)
                                : const Icon(Icons.delete, color: Colors.grey),
                            onPressed: index == stakeholders.length - 1
                                ? _addStakeholder
                                : () => _removeStakeholder(index),
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
