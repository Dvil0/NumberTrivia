import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_event.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_state.dart';

class MockGetConcreteNumberTrivia extends Mock
  implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock
  implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock
  implements InputConverter {}

void main() {
  NumberTriviaBloc numberTriviaBloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp((){
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockInputConverter = MockInputConverter();
    numberTriviaBloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter
    );
  });

  test('should be empty the initial state',
    (){
    // assert
    expect( numberTriviaBloc.initialState, equals( Empty() ) );
  });

  group('GetTriviaForConcreteNumber',(){
    final tNumberString = '1';
    final tNumberInteger = 1;
    final tNumberTrivia = NumberTrivia( number: 1, text: 'Test text.' );

    void setUpMockInputConverterSuccess() =>
      // arrange
      when( mockInputConverter.stringUnsignedInteger( any ) )
        .thenReturn( Right(tNumberInteger) );

    test('should call the inputConverter to validate and convert the string to an unsigned integer',
        () async{
      // arrange
      setUpMockInputConverterSuccess();
      // act
      numberTriviaBloc.dispatch( GetTriviaForConcreteNumber( tNumberString ) );
      await untilCalled( mockInputConverter.stringUnsignedInteger( any ) );
      // assert
      verify( mockInputConverter.stringUnsignedInteger( tNumberString ) );
    });

    test('should emit [Error] when the input is invalid',
        () async{
      // arrange
      when( mockInputConverter.stringUnsignedInteger( any ) )
          .thenReturn(Left(InvalidInputFailure()));
      // assert
      final expected = [
        Empty(),
        Error( message: INVALID_INPUT_FAILURE_MESSAGE )
      ];
      expectLater( numberTriviaBloc.state, emitsInOrder( expected ));
      // act
      numberTriviaBloc.dispatch( GetTriviaForConcreteNumber( tNumberString ) );
    });

    test('should get data from the concrete use case',
      () async{
      // arrange
      setUpMockInputConverterSuccess();
      when( mockGetConcreteNumberTrivia( any ))
        .thenAnswer( (_) async => Right(tNumberTrivia) );
      // act
      numberTriviaBloc.dispatch( GetTriviaForConcreteNumber( tNumberString ) );
      await untilCalled( mockGetConcreteNumberTrivia(any) );
      // assert
      verify( mockGetConcreteNumberTrivia( Params( number: tNumberInteger ) ) );
    });

    test('should emit [Loading, Loaded] when data is gotten successfully',
      () async{
      // arrange
      setUpMockInputConverterSuccess();
      when( mockGetConcreteNumberTrivia( any ))
          .thenAnswer( (_) async => Right(tNumberTrivia) );
      // asset later
      final expected = [
        Empty(),
        Loading(),
        Loaded( trivia: tNumberTrivia )
      ];
      expectLater( numberTriviaBloc.state, emitsInOrder( expected ) );
      // act
      numberTriviaBloc.dispatch( GetTriviaForConcreteNumber( tNumberString ) );
    });

    test('should emit [Loading, Error] when getting data fail',
      () async{
      // arrange
      setUpMockInputConverterSuccess();
      when( mockGetConcreteNumberTrivia( any ))
          .thenAnswer( (_) async => Left( ServerFailure() ) );
      // asset later
      final expected = [
        Empty(),
        Loading(),
        Error( message: SERVER_FAILURE_MESSAGE )
      ];
      expectLater( numberTriviaBloc.state, emitsInOrder( expected ) );
      // act
      numberTriviaBloc.dispatch( GetTriviaForConcreteNumber( tNumberString ) );
    });

    test('should emit [Loading, Error] with a proper message for the error when getting data fail',
        () async{
      // arrange
      setUpMockInputConverterSuccess();
      when( mockGetConcreteNumberTrivia( any ))
          .thenAnswer( (_) async => Left( CacheFailure() ) );
      // asset later
      final expected = [
        Empty(),
        Loading(),
        Error( message: CACHE_FAILURE_MESSAGE )
      ];
      expectLater( numberTriviaBloc.state, emitsInOrder( expected ) );
      // act
      numberTriviaBloc.dispatch( GetTriviaForConcreteNumber( tNumberString ) );
    });
  });

  group('GetTriviaForRandomNumber',(){
    final tNumberTrivia = NumberTrivia( number: 1, text: 'Test text.' );

    test('should get data from the random use case',
            () async{
          // arrange
          when( mockGetRandomNumberTrivia( NoParams() ) )
              .thenAnswer( (_) async => Right(tNumberTrivia) );
          // act
          numberTriviaBloc.dispatch( GetTriviaForRandomNumber() );
          await untilCalled( mockGetRandomNumberTrivia( any ) );
          // assert
          verify( mockGetRandomNumberTrivia( NoParams() ) );
        });

    test('should emit [Loading, Loaded] when data is gotten successfully',
            () async{
          // arrange
          when( mockGetRandomNumberTrivia( any ))
              .thenAnswer( (_) async => Right(tNumberTrivia) );
          // asset later
          final expected = [
            Empty(),
            Loading(),
            Loaded( trivia: tNumberTrivia )
          ];
          expectLater( numberTriviaBloc.state, emitsInOrder( expected ) );
          // act
          numberTriviaBloc.dispatch( GetTriviaForRandomNumber() );
        });

    test('should emit [Loading, Error] when getting data fail',
            () async{
          // arrange
          when( mockGetRandomNumberTrivia( any ))
              .thenAnswer( (_) async => Left( ServerFailure() ) );
          // asset later
          final expected = [
            Empty(),
            Loading(),
            Error( message: SERVER_FAILURE_MESSAGE )
          ];
          expectLater( numberTriviaBloc.state, emitsInOrder( expected ) );
          // act
          numberTriviaBloc.dispatch( GetTriviaForRandomNumber() );
        });

    test('should emit [Loading, Error] with a proper message for the error when getting data fail',
            () async{
          // arrange
          when( mockGetRandomNumberTrivia( any ))
              .thenAnswer( (_) async => Left( CacheFailure() ) );
          // asset later
          final expected = [
            Empty(),
            Loading(),
            Error( message: CACHE_FAILURE_MESSAGE )
          ];
          expectLater( numberTriviaBloc.state, emitsInOrder( expected ) );
          // act
          numberTriviaBloc.dispatch( GetTriviaForRandomNumber() );
        });
  });
}