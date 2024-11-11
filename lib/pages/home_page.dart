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
  AppLocalizations get localizations => AppLocalizations.of(context)!;

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
        isAscending: isAscending, context: context,
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
        final itemList = items.expand((item) => item).toList();

        return await Future.wait(data.map((accidentMap) async {
          return Accident(
            accidentId: accidentMap['AccidentId'] as int,
            constructionField: await _supabaseService.fetchItemName(itemList, accidentMap['ConstructionField'], 'ConstructionField'),
            constructionType: await _supabaseService.fetchItemName(itemList, accidentMap['ConstructionType'], 'ConstructionType'),
            workType: await _supabaseService.fetchItemName(itemList, accidentMap['WorkType'], 'WorkType'),
            constructionMethod: await _supabaseService.fetchItemName(itemList, accidentMap['ConstructionMethod'], 'ConstructionMethod'),
            disasterCategory: await _supabaseService.fetchItemName(itemList, accidentMap['DisasterCategory'], 'DisasterCategory'),
            accidentCategory: await _supabaseService.fetchItemName(itemList, accidentMap['AccidentCategory'], 'AccidentCategory'),
            weather: accidentMap['Weather'] as String?,
            weatherCondition: accidentMap['Weather'] as String?,
            accidentYear: accidentMap['AccidentYear'] as int,
            accidentMonth: accidentMap['AccidentMonth'] as int,
            accidentTime: accidentMap['AccidentTime'] as int,
            accidentLocationPref: await _supabaseService.fetchItemName(itemList, accidentMap['AccidentLocationPref'], 'AccidentLocationPref'),
            accidentBackground: accidentMap['AccidentBackground'] as String?,
            accidentCause: accidentMap['AccidentCause'] as String?,
            accidentCountermeasure: accidentMap['AccidentCountermeasure'] as String?,
            zipcode: accidentMap['Zipcode'] as int?,
            addressDetail: accidentMap['AddressDetail'] as String?
          );
        }).toList());
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
        label: Text(AppLocalizations.of(context)!.create),
      ),
    );
  }
}
