import 'package:accident_data_storage/models/accident_display.dart';
import 'package:accident_data_storage/pages/accident_page.dart';
import 'package:accident_data_storage/widgets/accident_list_widget.dart';
import 'package:accident_data_storage/widgets/logout_button.dart';
import 'package:accident_data_storage/widgets/sort_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:accident_data_storage/services/supabase_service.dart';
import 'package:accident_data_storage/models/accident_data.dart';
import 'package:accident_data_storage/widgets/filter_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<AccidentDisplayModel>> _accidentData;

  Map<String, dynamic>? _currentFilters;
  String? _currentSortBy = 'ID';
  bool isAscending = false;

  @override
  void initState() {
    super.initState();
    _currentFilters = {};
    _fetchAccidentData();
  }

  void _fetchAccidentData() {
    setState(() {
      _accidentData = _supabaseService
          .fetchAccidentsData(
        filters: _currentFilters,
        sortBy: _currentSortBy,
        isAscending: isAscending,
      )
          .then((data) async {
        // Fetch localized items for mapping
        final genres = [
          'ConstructionField',
          'ConstructionType',
          'WorkType',
          'ConstructionMethod',
          'DisasterCategory',
          'AccidentCategory',
          'AccidentLocationPref'
        ];
        final items = await Future.wait(
            genres.map((genre) => _supabaseService.fetchItems(genre)));
        final itemList =
            items.expand((item) => item).toList(); // Flatten the list

        return await _supabaseService.mapAccidentsToDisplayModel(
            data, itemList);
      });
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
      {AccidentDisplayModel? accident, required bool isEditing}) async {
    // Convert AccidentDisplayModel to AccidentDataModel if in editing mode
    AccidentDataModel? accidentData = isEditing && accident != null
        ? AccidentDataModel(
            accidentId: accident.accidentId,
            constructionField: accident.constructionField,
            constructionType: accident.constructionType,
            workType: accident.workType,
            constructionMethod: accident.constructionMethod,
            disasterCategory: accident.disasterCategory,
            accidentCategory: accident.accidentCategory,
            weather: accident.weather,
            accidentYear: accident.accidentYear,
            accidentMonth: accident.accidentMonth,
            accidentTime: accident.accidentTime,
            accidentLocationPref: accident.accidentLocationPref,
            accidentBackground: accident.accidentBackground,
            accidentCause: accident.accidentCause,
            accidentCountermeasure: accident.accidentCountermeasure,
            postalCode: accident.postalCode,
            addressDetail: accident.addressDetail,
          )
        : null;

    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccidentPage(
          accident: accidentData,
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
                  label: '工事分野',
                  sortBy: '工事分野',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: '工事の種類',
                  sortBy: '工事の種類',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: '工種',
                  sortBy: '工種',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: '工法・形式名',
                  sortBy: '工法・形式名',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: '災害分類',
                  sortBy: '災害分類',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: '事故分類',
                  sortBy: '事故分類',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: '天候',
                  sortBy: '天候',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                  label: '事故発生年・月・時間',
                  sortBy: '事故発生年・月・時間',
                  currentSortBy: _currentSortBy,
                  isAscending: isAscending,
                  onSortItemPressed: onSortItemPressed,
                ),
                SortButton(
                    label: '事故発生場所（都道府県）',
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
                _fetchAccidentData(); // データを再取得
              },
              child: AccidentListWidget(
                accidentData: _accidentData,
                onAccidentTap: (accident) => _navigateToAccidentPage(
                  accident: accident,
                  isEditing: true,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAccidentPage(isEditing: false),
        icon: const Icon(Icons.add),
        label: const Text('新規作成'),
      ),
    );
  }
}
