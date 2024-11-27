import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/accident.dart';
import '../models/item.dart';
import '../models/stakeholder.dart';
import '../navigation/navigation_helper.dart';
import '../providers/accident_provider.dart';
import '../providers/stakeholder_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/accident_list_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/logout_button.dart';
import '../widgets/sort_button_row.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<Accident>> _accidentData;
  late Future<List<Item>> _itemData;
  late Future<Map<int, List<Stakeholder>>> _stakeholdersMap;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final accidentProvider = context.read<AccidentProvider>();
    final stakeholderProvider = context.read<StakeholderProvider>();

    _accidentData = accidentProvider.fetchAccidentData();
    _itemData = accidentProvider.fetchAllItems();

    // Fetch stakeholders for all accidents
    _stakeholdersMap = _accidentData.then((accidents) async {
      try {
        Map<int, List<Stakeholder>> stakeholdersMap = {};
        for (final accident in accidents) {
          final stakeholders =
              await stakeholderProvider.fetchStakeholders(accident.accidentId!);
          stakeholdersMap[accident.accidentId!] = stakeholders;
        }
        return stakeholdersMap;
      } catch (e, stackTrace) {
        debugPrint("Error fetching stakeholders: $e");
        debugPrint("Stack Trace: $stackTrace");
        return {};
      }
    });
  }

  void onSortItemPressed(String sortBy) {
    final accidentProvider = context.read<AccidentProvider>();
    accidentProvider.updateSorting(sortBy);
    setState(() {
      _accidentData = accidentProvider.fetchAccidentData();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FilterBottomSheet(
          onApplyFilters: (filters) {
            final accidentProvider = context.read<AccidentProvider>();
            accidentProvider.updateFilters(filters);
            setState(() {
              _accidentData = accidentProvider.fetchAccidentData();
            });
          },
        );
      },
    );
  }

  void _openAccidentPage({Accident? accident, required bool isEditing}) async {
    final stakeholders = isEditing
        ? await context
            .read<StakeholderProvider>()
            .fetchStakeholders(accident!.accidentId!)
        : <Stakeholder>[];

    debugPrint(
        'Navigating to AccidentPage with accident: $accident, isEditing: $isEditing, stakeholders: $stakeholders');

    navigateToAccidentPage(
      context: context,
      accident: accident,
      isEditing: isEditing,
      stakeholders: stakeholders,
      onPageReturn: () {
        debugPrint('Returned from AccidentPage');
        setState(() {
          final accidentProvider = context.read<AccidentProvider>();
          _accidentData = accidentProvider.fetchAccidentData();
        });
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
                  _loadInitialData();
                });
              },
              child: FutureBuilder(
                future:
                    Future.wait([_accidentData, _itemData, _stakeholdersMap]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data![0].isEmpty) {
                    return const Center(child: Text('No accidents found'));
                  }

                  final accidents = snapshot.data![0] as List<Accident>;
                  final itemList = snapshot.data![1] as List<Item>;
                  final stakeholdersMap =
                      snapshot.data![2] as Map<int, List<Stakeholder>>;

                  return AccidentListWidget(
                    accidents: accidents,
                    itemList: itemList,
                    fetchItemName: SupabaseService().fetchItemName,
                    stakeholdersMap: stakeholdersMap,
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
