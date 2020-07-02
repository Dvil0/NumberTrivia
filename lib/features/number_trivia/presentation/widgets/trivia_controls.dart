import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_event.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key key,
  }) : super(key: key);

  @override
  _TriviaControlsState createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String inputString;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        //TextField
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Input a number'
          ),
          onChanged: (value) {
            inputString = value;
          },
          onSubmitted: (_) {
            dispatchConcrete();
          },
        ),
        SizedBox( height: 10),
        Row(
          children: <Widget>[
            Expanded(
                child: RaisedButton(
                  child: Text( 'Search' ),
                  color: Theme.of(context).primaryColor,
                  textTheme: ButtonTextTheme.primary,
                  onPressed: dispatchConcrete,
                )
            ),
            SizedBox( width: 10 ),
            Expanded(
                child: RaisedButton(
                  child: Text( 'Get random trivia' ),
                  onPressed: dispatchRandom,
                )
            ),
          ],
        )
      ],
    );
  }

  void dispatchConcrete( ) {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
        .dispatch( GetTriviaForConcreteNumber( inputString ) );
    FocusScope.of(context).unfocus();
  }

  void dispatchRandom( ) {
    BlocProvider.of<NumberTriviaBloc>(context)
        .dispatch( GetTriviaForRandomNumber() );
  }
}