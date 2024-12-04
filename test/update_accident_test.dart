import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/providers/accident_provider.dart';
import 'package:accident_data_storage/services/supabase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'update_accident_test.mocks.dart';

@GenerateMocks([
  SupabaseService,
  SupabaseClient, 
  SupabaseQueryBuilder, 
  PostgrestFilterBuilder
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseService mockSupabaseService;
  late AccidentProvider accidentProvider;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    
    // Ensure AccidentProvider is created with the mock service
    accidentProvider = AccidentProvider(supabaseService: mockSupabaseService);
  });

  test('throws exception when UpdatedAt does not match', () async {
    const accidentId = 1;
    final accident = Accident(
      accidentId: accidentId,
      updatedAt: DateTime.parse('2024-12-03T13:02:46.925672+00:00'),
      constructionField: '',
      constructionType: '',
      workType: '',
      constructionMethod: '',
      disasterCategory: '',
      accidentCategory: '',
      accidentLocationPref: '', 
      accidentYear: 2, 
      accidentMonth: 1, 
      accidentTime: 2,
    );

    // Mock the Supabase service update method
    when(mockSupabaseService.updateAccident(
      accidentId,
      any,
      accident.updatedAt.toIso8601String(),
    )).thenThrow(const PostgrestException(
      message: 'Conflict detected: Data has been updated by another user.',
      code: 'CONFLICT',
    ));

    // Expect the method to return false due to the thrown exception
    final result = await accidentProvider.updateAccident(accident);

    expect(result, isFalse);

    // Verify the mock methods were called
    verify(mockSupabaseService.updateAccident(
      accidentId,
      any,
      accident.updatedAt.toIso8601String(),
    )).called(1);
  });
}