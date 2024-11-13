import 'package:accident_data_storage/models/item.dart';
import 'package:accident_data_storage/pages/accident_page.dart';
import 'package:accident_data_storage/widgets/accident_list_widget.dart';
import 'package:accident_data_storage/widgets/logout_button.dart';
import 'package:accident_data_storage/widgets/sort_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:accident_data_storage/services/supabase_service.dart';
import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/widgets/filter_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Accident>> _accidentData;
  late Future<List<Item>> _itemList;

  Map<String, dynamic>? _currentFilters;
  String? _currentSortBy = 'ID';
  bool isAscending = false;

  @override
  void initState() {
    super.initState();
    _currentFilters = {};
    _fetchAccidentData();
    _fetchAllItems();
  }

  void _fetchAllItems() {
    final futures = [
      _supabaseService.fetchItems('ConstructionField'),
      _supabaseService.fetchItems('ConstructionType'),
      _supabaseService.fetchItems('WorkType'),
      _supabaseService.fetchItems('ConstructionMethod'),
      _supabaseService.fetchItems('DisasterCategory'),
      _supabaseService.fetchItems('AccidentCategory'),
      _supabaseService.fetchItems('AccidentLocationPref'),
    ];

    _itemList = Future.wait(futures)
        .then((lists) => lists.expand((list) => list).toList());
  }

  void _fetchAccidentData() {
    setState(() {
      _accidentData = _supabaseService.fetchAccidentsData(
        filters: _currentFilters,
        sortBy: _currentSortBy,
        isAscending: isAscending,
        context: context,
      );
    });
  }

  void onSortItemPressed(String sortBy) {
    setState(() {
      if (_currentSortBy == sortBy) {
        // Toggle ascending/descending if the same sort item is pressed
        isAscending = !isAscending;
      } else {
        // If a new item is pressed, reset to descending
        _currentSortBy = sortBy;
        isAscending = false;
      }
      _fetchAccidentData();
    });
  }

  Future<void> _navigateToAccidentPage(
      {Accident? accident, required bool isEditing}) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccidentPage(
          accident: accident,
          isEditing: isEditing,
        ),
      ),
    );

    if (result == true) {
      _fetchAccidentData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: LogoutButton(supabaseService: _supabaseService),
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
            onPressed: () {
              // Show the filter bottom sheet
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return FilterBottomSheet(
                    onApplyFilters: (filters) {
                      setState(() {
                        _currentFilters = filters;
                        _fetchAccidentData();
                      });
                    },
                  );
                },
              );
            },
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
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.constructionField,
                  sortBy: 'ConstructionField',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.constructionType,
                  sortBy: '工事の種類',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.workType,
                  sortBy: '工種',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.constructionMethod,
                  sortBy: '工法・形式名',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.disasterCategory,
                  sortBy: '災害分類',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.accidentCategory,
                  sortBy: '事故分類',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.weather,
                  sortBy: '天候',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: localizations.accidentYearMonthTime,
                  sortBy: '事故発生年・月・時間',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                    label: localizations.accidentLocationPref,
                    sortBy: '事故発生場所（都道府県）',
                    currentSortBy: _currentSortBy,
                    isAscending: isAscending,
                    onSortItemPressed: onSortItemPressed)
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _fetchAccidentData(); // Refresh data
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
                    itemList: itemList, // Pass itemList here
                    fetchItemName: _supabaseService
                        .fetchItemName, // Pass fetchItemName function
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
