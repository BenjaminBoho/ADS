import 'package:accident_data_storage/widgets/dropdown_widget.dart';
import 'package:accident_data_storage/widgets/picker_util.dart';
import 'package:accident_data_storage/widgets/picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:accident_data_storage/models/item.dart';
import 'package:accident_data_storage/services/supabase_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic> filters) onApplyFilters;

  const FilterBottomSheet({super.key, required this.onApplyFilters});

  @override
  FilterBottomSheetState createState() => FilterBottomSheetState();
}

class FilterBottomSheetState extends State<FilterBottomSheet> {
  final SupabaseService _supabaseService = SupabaseService();
  AppLocalizations get localizations => AppLocalizations.of(context)!;

  // State variables for filters
  String? selectedConstructionField;
  String? selectedConstructionType;
  String? accidentBackground;

  // Date range filters
  int? fromYear;
  int? fromMonth;
  int? toYear;
  int? toMonth;
  int? fromHour;
  int? toHour;

  List<int> years = List<int>.generate(
      DateTime.now().year - 2010 + 1, (index) => DateTime.now().year - index);

  // Lists for dropdowns
  List<Item> constructionFieldItems = [];
  List<Item> constructionTypeItems = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    constructionFieldItems =
        await _supabaseService.fetchItems('ConstructionField');
    constructionTypeItems =
        await _supabaseService.fetchItems('ConstructionType');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(localizations.filter,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16.0),
          // Construction Field Dropdown
          CustomDropdown(
            label: localizations.constructionField,
            value: selectedConstructionField,
            items: constructionFieldItems,
            onChanged: (value) {
              setState(() {
                selectedConstructionField = value;
              });
            },
          ),
          const SizedBox(height: 16.0),
          // Construction Type Dropdown
          CustomDropdown(
            label: localizations.constructionType,
            value: selectedConstructionType,
            items: constructionTypeItems,
            onChanged: (value) {
              setState(() {
                selectedConstructionType = value;
              });
            },
          ),
          const SizedBox(height: 16.0),
          // From Year, Month
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => PickerUtil.showPicker(
                    context: context,
                    items: years,
                    title: localizations.startYear,
                    onSelected: (value) {
                      setState(() {
                        fromYear = value;
                      });
                    },
                  ),
                  child: CustomPicker(
                    label: localizations.startYear,
                    value: fromYear,
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => PickerUtil.showPicker(
                    context: context,
                    items: List<int>.generate(12, (index) => index + 1),
                    title: localizations.startMonth,
                    onSelected: (value) {
                      setState(() {
                        fromMonth = value;
                      });
                    },
                  ),
                  child: CustomPicker(
                    label: localizations.startMonth,
                    value: fromMonth,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // To Year and Month
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => PickerUtil.showPicker(
                    context: context,
                    items: years,
                    title: localizations.endYear,
                    onSelected: (value) {
                      setState(() {
                        toYear = value;
                      });
                    },
                  ),
                  child: CustomPicker(
                    label: localizations.endYear,
                    value: toYear,
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => PickerUtil.showPicker(
                    context: context,
                    items: List<int>.generate(12, (index) => index + 1),
                    title: localizations.endMonth,
                    onSelected: (value) {
                      setState(() {
                        toMonth = value;
                      });
                    },
                  ),
                  child: CustomPicker(
                    label: localizations.endMonth,
                    value: toMonth,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // From and To Hour
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => PickerUtil.showPicker(
                    context: context,
                    items: List<int>.generate(
                        24, (index) => index), // Hours from 0 to 23
                    title: localizations.startTime,
                    onSelected: (value) {
                      setState(() {
                        fromHour = value;
                      });
                    },
                  ),
                  child: CustomPicker(
                    label: localizations.startTime,
                    value: fromHour,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: InkWell(
                  onTap: () => PickerUtil.showPicker(
                    context: context,
                    items: List<int>.generate(
                        24, (index) => index), // Hours from 0 to 23
                    title: localizations.endTime,
                    onSelected: (value) {
                      setState(() {
                        toHour = value;
                      });
                    },
                  ),
                  child: CustomPicker(
                    label: localizations.endTime,
                    value: toHour,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),
          // Accident Background TextField
          TextFormField(
            decoration: InputDecoration(labelText: localizations.accidentBackground),
            onChanged: (value) {
              accidentBackground = value;
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            child: Text(localizations.applyFilter),
            onPressed: () {
              Map<String, dynamic> filters = {
                'constructionField': selectedConstructionField,
                'constructionType': selectedConstructionType,
                'fromYear': fromYear,
                'toYear': toYear,
                'fromMonth': fromMonth,
                'toMonth': toMonth,
                'fromTime': fromHour,
                'toTime': toHour,
                'accidentBackground': accidentBackground,
              };
              widget.onApplyFilters(filters);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
