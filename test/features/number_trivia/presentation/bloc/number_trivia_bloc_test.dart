import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
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

    test('should call the inputConverter to validate and convert the string to an unsigned integer',
        () async{
      // arrange
      when( mockInputConverter.stringUnsignedInteger( any ) )
        .thenReturn(Right(tNumberInteger));
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
  });
}