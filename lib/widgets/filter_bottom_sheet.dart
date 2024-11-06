import 'package:accident_data_storage/widgets/dropdown_widget.dart';
import 'package:accident_data_storage/widgets/picker_util.dart';
import 'package:accident_data_storage/widgets/picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:accident_data_storage/models/item.dart';
import 'package:accident_data_storage/services/supabase_service.dart';
import 'package:accident_data_storage/utils/language_utils.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic> filters) onApplyFilters;

  const FilterBottomSheet({super.key, required this.onApplyFilters});

  @override
  FilterBottomSheetState createState() => FilterBottomSheetState();
}

class FilterBottomSheetState extends State<FilterBottomSheet> {
  final SupabaseService _supabaseService = SupabaseService();

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
    final language = getDeviceLanguage();
    constructionFieldItems =
        await _supabaseService.fetchItems('ConstructionField', language);
    constructionTypeItems =
        await _supabaseService.fetchItems('ConstructionType', language);
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
          const Text('フィルター',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16.0),
          // Construction Field Dropdown
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
          const SizedBox(height: 16.0),
          // Construction Type Dropdown
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
          const SizedBox(height: 16.0),
          // From Year, Month
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => PickerUtil.showPicker(
                    context: context,
                    items: years,
                    title: '開始年',
                    onSelected: (value) {
                      setState(() {
                        fromYear = value;
                      });
                    },
                  ),
                  child: CustomPicker(
                    label: '開始年',
                    value: fromYear,
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => PickerUtil.showPicker(
                    context: context,
                    items: List<int>.generate(12, (index) => index + 1),
                    title: '開始月',
                    onSelected: (value) {
                      setState(() {
                        fromMonth = value;
                      });
                    },
                  ),
                  child: CustomPicker(
                    label: '開始月',
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
                    title: '終了年',
                    onSelected: (value) {
                      setState(() {
                        toYear = value;
                      });
                    },
                  ),
                  child: CustomPicker(
                    label: '終了年',
                    value: toYear,
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => PickerUtil.showPicker(
                    context: context,
                    items: List<int>.generate(12, (index) => index + 1),
                    title: '終了月',
                    onSelected: (value) {
                      setState(() {
                        toMonth = value;
                      });
                    },
                  ),
                  child: CustomPicker(
                    label: '終了月',
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
                    title: '開始時間',
                    onSelected: (value) {
                      setState(() {
                        fromHour = value;
                      });
                    },
                  ),
                  child: CustomPicker(
                    label: '開始時間',
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
                    title: '終了時間',
                    onSelected: (value) {
                      setState(() {
                        toHour = value;
                      });
                    },
                  ),
                  child: CustomPicker(
                    label: '終了時間',
                    value: toHour,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),
          // Accident Background TextField
          TextFormField(
            decoration: const InputDecoration(labelText: '事故に至る経緯と事故の状況'),
            onChanged: (value) {
              accidentBackground = value;
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            child: const Text('フィルターを適用'),
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
