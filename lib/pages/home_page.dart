import 'package:accident_data_storage/models/item.dart';
import 'package:accident_data_storage/navigation/navigation_helper.dart';
import 'package:accident_data_storage/providers/accident_provider.dart';
import 'package:accident_data_storage/widgets/accident_list_widget.dart';
import 'package:accident_data_storage/widgets/logout_button.dart';
import 'package:flutter/material.dart';
import 'package:accident_data_storage/services/supabase_service.dart';
import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/widgets/filter_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:accident_data_storage/widgets/sort_button_row.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<Accident>> _accidentData;

  @override
  void initState() {
    super.initState();
    final accidentProvider =
        Provider.of<AccidentProvider>(context, listen: false);
    _accidentData = accidentProvider.fetchAccidentData();
  }

  void onSortItemPressed(String sortBy) {
    final accidentProvider =
        Provider.of<AccidentProvider>(context, listen: false);
    accidentProvider.updateSorting(sortBy);
    setState(() {
      _accidentData = accidentProvider.fetchAccidentData();
    });
  }

  void _openAccidentPage({Accident? accident, required bool isEditing}) {
    navigateToAccidentPage(
      context: context,
      accident: accident,
      isEditing: isEditing,
      onPageReturn: () {
        setState(() {
          _accidentData = context.read<AccidentProvider>().fetchAccidentData();
        });
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FilterBottomSheet(
          onApplyFilters: (filters) {
            Provider.of<AccidentProvider>(context, listen: false)
                .updateFilters(filters);
            setState(() {
              _accidentData =
                  Provider.of<AccidentProvider>(context, listen: false)
                      .fetchAccidentData();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: LogoutButton(supabaseService: SupabaseService()),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SortButtonRow(onSortItemPressed: onSortItemPressed),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _accidentData =
                      context.read<AccidentProvider>().fetchAccidentData();
                });
              },
              child: FutureBuilder<List<Item>>(
                future: context.read<AccidentProvider>().fetchAllItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No item data found'));
                  }

                  final itemList = snapshot.data!;
                  return AccidentListWidget(
                    accidentData: _accidentData,
                    itemList: itemList,
                    fetchItemName: SupabaseService().fetchItemName,
                    onAccidentTap: (accident) => _openAccidentPage(
                      accident: accident,
                      isEditing: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAccidentPage(isEditing: false),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.create),
      ),
    );
  }
}
