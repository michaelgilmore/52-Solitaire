import 'package:flutter/material.dart';

class PlayingCard extends StatefulWidget {

  static const values = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
  static const spades = '♠';
  static const clubs = '♣';
  static const hearts = '♥';
  static const diamonds = '♦';
  static const suits = [spades, clubs, hearts, diamonds];

  static const DRAG_SOURCE_WASTE = 0;
  static const DRAG_SOURCE_TABLEAU_1 = 1;
  static const DRAG_SOURCE_TABLEAU_2 = 2;
  static const DRAG_SOURCE_TABLEAU_3 = 3;
  static const DRAG_SOURCE_TABLEAU_4 = 4;
  static const DRAG_SOURCE_TABLEAU_5 = 5;
  static const DRAG_SOURCE_TABLEAU_6 = 6;
  static const DRAG_SOURCE_TABLEAU_7 = 7;
  static const List<int> DRAG_SOURCE_TABLEAUS = [DRAG_SOURCE_TABLEAU_1, DRAG_SOURCE_TABLEAU_2, DRAG_SOURCE_TABLEAU_3, DRAG_SOURCE_TABLEAU_4, DRAG_SOURCE_TABLEAU_5, DRAG_SOURCE_TABLEAU_6, DRAG_SOURCE_TABLEAU_7];
  static const DRAG_SOURCE_FOUNDATION_HEARTS = 8;
  static const DRAG_SOURCE_FOUNDATION_DIAMONDS = 9;
  static const DRAG_SOURCE_FOUNDATION_CLUBS = 10;
  static const DRAG_SOURCE_FOUNDATION_SPADES = 11;
  static const List<int> DRAG_SOURCE_FOUNDATIONS = [DRAG_SOURCE_FOUNDATION_HEARTS, DRAG_SOURCE_FOUNDATION_DIAMONDS, DRAG_SOURCE_FOUNDATION_CLUBS, DRAG_SOURCE_FOUNDATION_SPADES];
  static const DRAG_SOURCE_STOCK = 12;

  static PlayingCard placeholder = PlayingCard('', '', false);

  static double cardWidth = 100.0;
  static double cardHeight = 150.0;
  static double fontSize = 24;
  static double topRightFontSize = 12;

  String value;
  final String suit;
  final Color suitColor;
  bool _isFaceUp = false;
  //Add accessor for isFaceUp
  bool get isFaceUp => _isFaceUp;
  set isFaceUp(bool value) {
    // print('Setting isFaceUp to $value for ${toStr()}');
    _isFaceUp = value;
  }
  int currentPile = PlayingCard.DRAG_SOURCE_STOCK;

  PlayingCard(this.value, this.suit, this._isFaceUp, {super.key}) :
    suitColor = suit == hearts || suit == diamonds ? Colors.red : Colors.black {
  }

  @override
  State<PlayingCard> createState() => _PlayingCardState();

  String toStr() {
    return '$value $suit';
  }
}

class _PlayingCardState extends State<PlayingCard> {

  Color cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {

    // print('Screen width ${MediaQuery.of(context).size.width}, height ${MediaQuery.of(context).size.height}');

    //Set cardWidth to one tenth of the screen width from MediaQuery
    PlayingCard.cardWidth = MediaQuery.of(context).size.width / 10;
    PlayingCard.cardHeight = MediaQuery.of(context).size.height / 5;
    PlayingCard.fontSize = MediaQuery.of(context).size.width < 600 ? 10 : 24;
    PlayingCard.topRightFontSize = MediaQuery.of(context).size.width < 600 ? 5 : 12;

    cardColor = widget.isFaceUp ? Colors.white : Colors.blue;

    return Draggable(
        data: widget,
        feedback: Container(
          width: PlayingCard.cardWidth,
          height: PlayingCard.cardHeight,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Text(widget.value + widget.suit, style: TextStyle(color: widget.isFaceUp ? widget.suitColor : cardColor, fontSize: PlayingCard.topRightFontSize)),
                ),
                const Text(''),
                Text(widget.value, style: TextStyle(color: widget.isFaceUp ? widget.suitColor : cardColor, fontSize: PlayingCard.fontSize)),
                Text(widget.suit, style: TextStyle(color: widget.isFaceUp ? widget.suitColor : cardColor, fontSize: PlayingCard.fontSize)),
              ],
            )
          )
        ),
        child: Container(
          width: PlayingCard.cardWidth,
          height: PlayingCard.cardHeight,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Text(widget.value + widget.suit, style: TextStyle(color: widget.isFaceUp ? widget.suitColor : cardColor, fontSize: PlayingCard.topRightFontSize)),
                ),
                const Text(''),
                Text(widget.value, style: TextStyle(color: widget.isFaceUp ? widget.suitColor : cardColor, fontSize: PlayingCard.fontSize)),
                Text(widget.suit, style: TextStyle(color: widget.isFaceUp ? widget.suitColor : cardColor, fontSize: PlayingCard.fontSize)),
              ],
            )
          )
        ),
    );
  }

  //Override equality operator
  @override
  bool operator ==(Object other) {
    if (other is PlayingCard) {
      return widget.value == other.value && widget.suit == other.suit;
    }
    return false;
  }
}
