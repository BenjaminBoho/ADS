import 'package:accident_data_storage/models/item.dart';
import 'package:accident_data_storage/pages/accident_page.dart';
import 'package:accident_data_storage/providers/accident_provider.dart';
import 'package:accident_data_storage/widgets/accident_list_widget.dart';
import 'package:accident_data_storage/widgets/logout_button.dart';
import 'package:accident_data_storage/widgets/sort_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:accident_data_storage/services/supabase_service.dart';
import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/widgets/filter_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<Accident>> _accidentData;
  late Future<List<Item>> _itemList;

  @override
  void initState() {
    super.initState();
    final accidentProvider =
        Provider.of<AccidentProvider>(context, listen: false);
    _accidentData = accidentProvider.fetchAccidentData();
    _itemList = accidentProvider.fetchAllItems();
  }

  void onSortItemPressed(String sortBy) {
    final accidentProvider =
        Provider.of<AccidentProvider>(context, listen: false);
    accidentProvider.updateSorting(sortBy);
    setState(() {
      _accidentData = accidentProvider.fetchAccidentData();
    });
  }

    Future<void> _navigateToAccidentPage({Accident? accident, required bool isEditing}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccidentPage(
          accident: accident,
          isEditing: isEditing,
        ),
      ),
    );

    if (result == true) {
      // Triggers a data refresh in AccidentProvider when the user returns
      setState(() {
        _accidentData = context.read<AccidentProvider>().fetchAccidentData();
      });
    }
  }


  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FilterBottomSheet(
          onApplyFilters: (filters) {
            final accidentProvider =
                Provider.of<AccidentProvider>(context, listen: false);
            accidentProvider.updateFilters(filters);
            setState(() {
              _accidentData = accidentProvider.fetchAccidentData();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: LogoutButton(supabaseService: SupabaseService()),
        // leading: PopupMenuButton<String>(
        //   icon: const Icon(Icons.menu),
        //   onSelected: (String result) async {
        //     if (result == 'logout') {
        //       // Call the logout function
        //       await _supabaseService.logout();
        //       // Navigate back to the login page
        //       Navigator.pushReplacementNamed(context, '/');
        //     }
        //   },
        //   itemBuilder: (BuildContext context) => [
        //     const PopupMenuItem<String>(
        //       value: 'logout',
        //       child: ListTile(
        //         leading: Icon(Icons.logout),
        //         title: Text('ログアウト'),
        //       ),
        //     ),
        //   ],
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort buttons in a horizontal scroll view
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SortButton(
                  label: 'ID',
                  sortBy: 'ID',
                  currentSortBy:
                      context.watch<AccidentProvider>().currentSortBy,
                  isAscending: context.watch<AccidentProvider>().isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.constructionField,
                  sortBy: 'ConstructionField',
                  currentSortBy:
                      context.watch<AccidentProvider>().currentSortBy,
                  isAscending: context.watch<AccidentProvider>().isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.constructionType,
                  sortBy: '工事の種類',
                  currentSortBy:
                      context.watch<AccidentProvider>().currentSortBy,
                  isAscending: context.watch<AccidentProvider>().isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.workType,
                  sortBy: '工種',
                  currentSortBy:
                      context.watch<AccidentProvider>().currentSortBy,
                  isAscending: context.watch<AccidentProvider>().isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.constructionMethod,
                  sortBy: '工法・形式名',
                  currentSortBy:
                      context.watch<AccidentProvider>().currentSortBy,
                  isAscending: context.watch<AccidentProvider>().isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.disasterCategory,
                  sortBy: '災害分類',
                  currentSortBy:
                      context.watch<AccidentProvider>().currentSortBy,
                  isAscending: context.watch<AccidentProvider>().isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.accidentCategory,
                  sortBy: '事故分類',
                  currentSortBy:
                      context.watch<AccidentProvider>().currentSortBy,
                  isAscending: context.watch<AccidentProvider>().isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.weather,
                  sortBy: '天候',
                  currentSortBy:
                      context.watch<AccidentProvider>().currentSortBy,
                  isAscending: context.watch<AccidentProvider>().isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.accidentYearMonthTime,
                  sortBy: '事故発生年・月・時間',
                  currentSortBy:
                      context.watch<AccidentProvider>().currentSortBy,
                  isAscending: context.watch<AccidentProvider>().isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                    label: localizations.accidentLocationPref,
                    sortBy: '事故発生場所（都道府県）',
                    currentSortBy:
                        context.watch<AccidentProvider>().currentSortBy,
                    isAscending: context.watch<AccidentProvider>().isAscending,
                    onSortItemPressed: onSortItemPressed)
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
                future: _itemList, // Use the future _itemList we initialized
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
                    onAccidentTap: (accident) => _navigateToAccidentPage(
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
        onPressed: () => _navigateToAccidentPage(isEditing: false),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.create),
      ),
    );
  }
}
