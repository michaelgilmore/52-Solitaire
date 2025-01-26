import 'package:flutter/material.dart';
import 'package:gsolitaire/settings.dart';

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

  double cardWidth = 100.0;
  double cardHeight = 160.0;

  double centerFontSize = 24;
  double cornerFontSize = 12;
  double spaceBetweenCenterAndCorner = 20;

  String value;
  final String suit;
  final Color suitColor;
  bool isFaceUp = false;
  int _currentPile = PlayingCard.DRAG_SOURCE_STOCK;
  int get currentPile => _currentPile;//1-based
  set currentPile(int newPile) {
    // print('setting ${toStr()} currentPile to $newPile, was $_currentPile');
    _currentPile = newPile;
  }

  PlayingCard? _cardOnTopOfThisOne;
  PlayingCard? get cardOnTopOfThisOne => _cardOnTopOfThisOne;
  set cardOnTopOfThisOne(PlayingCard? card) {
    // print('setting ${toStr()} cardOnTopOfThisOne to ${card?.toStr()}');
    _cardOnTopOfThisOne = card;
  }

  PlayingCard(this.value, this.suit, this.isFaceUp, {super.key}) :
    suitColor = suit == hearts || suit == diamonds ? Colors.red : Colors.black {
    // print('PlayingCard constructor($value$suit) - isFaceUp: $isFaceUp');
  }

  @override
  State<PlayingCard> createState() => _PlayingCardState();

  String toStr() {
    return '$value $suit';
  }
}

class _PlayingCardState extends State<PlayingCard> {

  //Debugging
  bool showCurrentPile = false;
  bool showCardOnTop = false;

  Color cardColor = Colors.white;
  Color textColor = Colors.white;
  final Color cardBorderColor = Colors.grey[500]!;

  Color cardBackColor = Colors.blue;
  Color cardFrontColor = Colors.white;

  @override
  void initState() {
    super.initState();

    cardBackColor = Settings.colorMapNotifier.value[Settings.COLOR_AREA_CARD_BACK] ?? Colors.blue;
    cardFrontColor = Settings.colorMapNotifier.value[Settings.COLOR_AREA_CARD_FRONT] ?? Colors.white;

  }

  @override
  Widget build(BuildContext context) {
    // print('PlayingCard build(${widget.toStr()}) - currentPile: ${widget.currentPile}, isFaceUp: ${widget.isFaceUp}');
    cardColor = widget.isFaceUp ? cardFrontColor : cardBackColor;
    textColor = widget.isFaceUp ? widget.suitColor : cardColor;

    return Draggable(
        data: widget,
        feedback: getCardContainer(),
        child: getCardContainer(),
    );
  }

  Container getCardContainer() {
    String cardTopRow = '';
    if(showCardOnTop) {
      if(widget.cardOnTopOfThisOne == null) {
        cardTopRow = 'XX';
      } else {
        cardTopRow = widget.cardOnTopOfThisOne!.toStr();
      }
    }
    if(showCurrentPile) {
      cardTopRow = '${widget.currentPile} ';
    }
    cardTopRow += widget.value + widget.suit;

    return Container(
        width: widget.cardWidth,
        height: widget.cardHeight,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: cardBorderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Visibility(
              visible: widget.isFaceUp,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(cardTopRow,
                        style: TextStyle(
                          color: textColor,
                          fontSize: widget.cornerFontSize,
                          fontWeight: FontWeight.bold
                        )
                    ),
                  ),
                  SizedBox(height: widget.spaceBetweenCenterAndCorner),
                  Text(widget.value, style: TextStyle(color: textColor, fontSize: widget.centerFontSize)),
                  Text(widget.suit, style: TextStyle(color: textColor, fontSize: widget.centerFontSize)),
                  SizedBox(height: widget.spaceBetweenCenterAndCorner),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(widget.value + widget.suit,
                      style: TextStyle(
                        color: textColor,
                        fontSize: widget.cornerFontSize,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ],
              ),
            )
        )
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is PlayingCard) {
      return widget.value == other.value && widget.suit == other.suit;
    }
    return false;
  }

  @override
  int get hashCode => widget.value.hashCode ^ widget.suit.hashCode;
}
