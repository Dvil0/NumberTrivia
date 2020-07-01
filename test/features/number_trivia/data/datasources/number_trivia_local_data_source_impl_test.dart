import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matcher/matcher.dart';
import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock
  implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl numberTriviaLocalDataSourceImpl;
  MockSharedPreferences mockSharedPreferences;

  setUp((){
    mockSharedPreferences = MockSharedPreferences();
    numberTriviaLocalDataSourceImpl = NumberTriviaLocalDataSourceImpl( sharedPreferences: mockSharedPreferences );
  });

  group('getLasNumberTrivia',(){
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode( fixture('trivia_cached.json') )
    );

    test('should return NumberTrivia from SharedPreferences when there is one in the cache',
      () async {
      // arrange
      when(mockSharedPreferences.getString(any)).thenReturn( fixture('trivia_cached.json') );
      // act
      final result = await numberTriviaLocalDataSourceImpl.getLastNumberTrivia();
      // assert
      verify( mockSharedPreferences.getString( CACHED_NUMBER_TRIVIA ));
      expect( result, equals(tNumberTriviaModel));
    });

    test('should throw CacheException when there is not cached value',
      () async {
      // arrange
      when(mockSharedPreferences.getString(any)).thenReturn( null );
      // act
      final call = numberTriviaLocalDataSourceImpl.getLastNumberTrivia;
      // assert
      expect( () => call() , throwsA( TypeMatcher<CacheException>() ) );
    });
  });

  group('cacheNumberTrivia', (){
    final tNumberTriviaModel = NumberTriviaModel( number: 1, text: 'Test Trivia.');

    test('should call SharedPreferences to cache the data ',
      () async {
      // act
      numberTriviaLocalDataSourceImpl.cacheNumberTrivia( tNumberTriviaModel );
      // assert
      final expectedJson = json.encode( tNumberTriviaModel.toJson() );
      verify( mockSharedPreferences.setString( CACHED_NUMBER_TRIVIA, expectedJson ) );
    });
  });
}