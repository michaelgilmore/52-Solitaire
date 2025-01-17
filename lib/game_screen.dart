import 'package:flutter/material.dart';
import 'package:gsolitaire/playing_card.dart';
import 'package:gsolitaire/settings.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.title});

  final String title;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  final int BOTTOM_NAV_INDEX_HOME = 0;
  final int BOTTOM_NAV_INDEX_RESET = 1;
  final int BOTTOM_NAV_INDEX_TOOLS = 2;

  late List<PlayingCard> stock;
  List<PlayingCard> waste = [];
  List<List<PlayingCard>> foundation = [];
  List<List<PlayingCard>> tableau = [];

  int _currentBottomNavIndex = 0;

  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();

    _currentBottomNavIndex = BOTTOM_NAV_INDEX_HOME;

    stock = shuffledDeck();

    for (int j = 0; j < 7; j++) {
      tableau.add([]);
    }

    //Deal cards to tableau
    for(int i = 0; i <= 6; i++) {
      for (int j = i; j < 7; j++) {
        stock[0].currentPile = PlayingCard.DRAG_SOURCE_TABLEAUS[j];
        stock[0].isFaceUp = j == i;
        tableau[j].add(stock[0]);
        stock.removeAt(0);
      }
    }

    for(int i = 0; i < 4; i++) {
      foundation.add([]);
      foundation[i].add(PlayingCard('', PlayingCard.suits[i], true, key: UniqueKey()/*Key(PlayingCard.suits[i])*/));
      foundation[i].last.currentPile = PlayingCard.DRAG_SOURCE_FOUNDATIONS[i];
    }
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    if(_currentBottomNavIndex == BOTTOM_NAV_INDEX_RESET) {
      resetGame();
    }
    else if(_currentBottomNavIndex == BOTTOM_NAV_INDEX_TOOLS) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const Settings()
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('GameScreen build()');

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    const double firstResponsiveWidthThreshold = 820;
    const double secondResponsiveWidthThreshold = 500;
    double surroundingPadding = screenWidth > firstResponsiveWidthThreshold ? 50 : 25;
    double spaceBetweenWasteAndFoundation = screenWidth > firstResponsiveWidthThreshold ? 100 : 50;

    //Default values for wider screen
    double cardHeight = 160;
    double cardWidth = 100;
    double centerFontSize = 24;
    double cornerFontSize = 12;
    double spaceBetweenCenterAndCorner = 20;

    if(screenWidth < secondResponsiveWidthThreshold) {
      cardHeight = 80;
      cardWidth = 50;
      centerFontSize = 12;
      cornerFontSize = 6;
      spaceBetweenCenterAndCorner = 8;
    }
    else if(screenWidth < firstResponsiveWidthThreshold) {
      cardHeight = 100;
      cardWidth = 63;
      centerFontSize = 16;
      cornerFontSize = 8;
      spaceBetweenCenterAndCorner = 12;
    }

    //loop through all cards in stock and waste and set card height and width
    for(int i = 0; i < stock.length; i++) {
      stock[i].cardHeight = cardHeight;
      stock[i].cardWidth = cardWidth;
      stock[i].centerFontSize = centerFontSize;
      stock[i].cornerFontSize = cornerFontSize;
      stock[i].spaceBetweenCenterAndCorner = spaceBetweenCenterAndCorner;
    }
    for(int i = 0; i < waste.length; i++) {
      waste[i].cardHeight = cardHeight;
      waste[i].cardWidth = cardWidth;
      waste[i].centerFontSize = centerFontSize;
      waste[i].cornerFontSize = cornerFontSize;
      waste[i].spaceBetweenCenterAndCorner = spaceBetweenCenterAndCorner;
    }

    //loop through all cards in foundation piles and set card height and width
    for(int i = 0; i < 4; i++) {
      for(int j = 0; j < foundation[i].length; j++) {
        foundation[i][j].cardHeight = cardHeight;
        foundation[i][j].cardWidth = cardWidth;
        foundation[i][j].centerFontSize = centerFontSize;
        foundation[i][j].cornerFontSize = cornerFontSize;
        foundation[i][j].spaceBetweenCenterAndCorner = spaceBetweenCenterAndCorner;
      }
    }

    //loop through all cards in tableau and set card height and width
    for(int i = 0; i < 7; i++) {
      for(int j = 0; j < tableau[i].length; j++) {
        tableau[i][j].cardHeight = cardHeight;
        tableau[i][j].cardWidth = cardWidth;
        tableau[i][j].centerFontSize = centerFontSize;
        tableau[i][j].cornerFontSize = cornerFontSize;
        tableau[i][j].spaceBetweenCenterAndCorner = spaceBetweenCenterAndCorner;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentBottomNavIndex,
          onTap: _onBottomNavItemTapped,
          unselectedItemColor: Colors.lightBlueAccent,
          selectedItemColor: Colors.lightBlue,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Reset',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handyman),
              label: 'Tools',
            ),
          ]
      ),
      body: Padding(
        padding: EdgeInsets.all(surroundingPadding),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Visibility(
                visible: stock.isEmpty && waste.isEmpty && foundation[0].length == 14 && foundation[1].length == 14 && foundation[2].length == 14 && foundation[3].length == 14,
                child: const Text('YOU WIN!')
              ),

              //Stock, Waste, Foundation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //Stock
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          if(stock.isNotEmpty) {
                            stock[0].currentPile = PlayingCard.DRAG_SOURCE_WASTE;
                            waste.add(stock[0]);
                            stock.removeAt(0);
                            waste.last.isFaceUp = true;
                          }
                          else {
                            stock = waste.toList();
                            for (var card in stock) {
                              card.isFaceUp = false;
                              card.currentPile = PlayingCard.DRAG_SOURCE_STOCK;
                            }
                            waste.clear();
                          }
                        });
                      },
                      child: Column(
                          children: [
                            stock.isNotEmpty ? stock[0] : PlayingCard.placeholder,
                            Text(stock.length.toString()),
                          ]
                      )
                  ),

                  //Waste
                  GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          if(waste.isEmpty) {
                            return;
                          }

                          PlayingCard topCard = waste.last;

                          //Check each foundation pile to see if the top card can be moved there
                          for(int i = 0; i < 4; i++) {
                            if(isValidFoundationDrop(foundation[i].last, topCard)) {
                              // print('Moving card to foundation');
                              foundation[i].add(waste.removeLast());
                              foundation[i].last.currentPile = PlayingCard.DRAG_SOURCE_FOUNDATIONS[i];
                              return;
                            }
                          }

                          //Check each tableau pile to see if the top card can be moved there
                          for(int i = 0; i < 7; i++) {
                            if(isValidTableauDrop(tableau[i].isNotEmpty ? tableau[i].last : null, topCard)) {
                              // print('Moving card to tableau');
                              tableau[i].add(waste.removeLast());
                              tableau[i].last.currentPile = PlayingCard.DRAG_SOURCE_TABLEAUS[i];
                              return;
                            }
                          }
                        });
                      },
                      child: Column(
                          children: [
                            waste.isNotEmpty ? waste.last : SizedBox(height: cardHeight, width: cardWidth),
                            Text(waste.length.toString()),
                          ]
                      )
                  ),

                  SizedBox(width: spaceBetweenWasteAndFoundation),

                  //Foundation
                  for(int a = 0; a < 4; a++)
                    DragTarget(
                      onAcceptWithDetails: (DragTargetDetails data) {
                        PlayingCard droppedCard = data.data;
                        // print('onAcceptWithDetails ${droppedCard.toStr()}');

                        if(isValidFoundationDrop(foundation[a].last, droppedCard)) {
                          // print('Accepting foundation drop');
                          foundation[a].add(droppedCard);
                          removeCardFromDragSource(droppedCard);
                          foundation[a].last.currentPile = PlayingCard.DRAG_SOURCE_FOUNDATIONS[a];
                        }
                      },
                      onWillAcceptWithDetails: (DragTargetDetails data) {
                        PlayingCard droppedCard = data.data;
                        // print('onWillAcceptWithDetails ${droppedCard.toStr()}');

                        if(isValidFoundationDrop(foundation[a].last, droppedCard)) {
                          // print('Will accept foundation drop');
                          return true;
                        }

                        // print('Rejecting drop');
                        return false;
                      },
                      builder: (context, candidateData, rejectedData) => Column(
                        children: [
                          foundation[a].last,
                          Text((foundation[a].length - 1).toString()),//TODO: Don't have empty be a card. Then we won't need to subtract 1 here.
                        ],
                      ),
                    ),
                ],
              ),

              //Spacer
              const Row(
                children: [
                  SizedBox(height: 50)
                ],
              ),

              //Tableau
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for(int i = 0; i < 7; i++)
                    GestureDetector(
                      onDoubleTap: () {
                        // print('Double tap on tableau $i card ${tableau[i].last.toStr()}');
                        setState(() {
                          if(tableau[i].isEmpty) {
                            return;
                          }

                          PlayingCard topCard = tableau[i].last;

                          //Check each foundation pile to see if the top card can be moved there
                          for(int j = 0; j < 4; j++) {
                            if(isValidFoundationDrop(foundation[j].last, topCard)) {
                              // print('Moving card to foundation');
                              foundation[j].add(tableau[i].removeLast());
                              foundation[j].last.currentPile = PlayingCard.DRAG_SOURCE_FOUNDATIONS[j];

                              if(tableau[i].isNotEmpty && !tableau[i].last.isFaceUp) {
                                tableau[i].last.isFaceUp = true;
                                //HACK Remove last card and recreate it with isFaceUp set to true. Seems like not managing state properly.
                                PlayingCard newLast = PlayingCard(tableau[i].last.value, tableau[i].last.suit, true, key: UniqueKey());
                                newLast.currentPile = tableau[i].last.currentPile;
                                tableau[i].removeLast();
                                tableau[i].add(newLast);
                              }
                              return;
                            }
                          }
                        });
                      },
                      child: DragTarget(
                        onAcceptWithDetails: (DragTargetDetails data) {
                          PlayingCard droppedCard = data.data;

                          if(isValidTableauDrop(tableau[i].isNotEmpty ? tableau[i].last : null, droppedCard)) {
                            // print('Accepting tableau drop');
                            if(tableau[i].isNotEmpty) {
                              tableau[i].last.cardOnTopOfThisOne = droppedCard;
                            }
                            addCardFromDragSource(droppedCard, tableau[i], PlayingCard.DRAG_SOURCE_TABLEAUS[i]);
                          }
                        },
                        onWillAcceptWithDetails: (DragTargetDetails data) {
                          PlayingCard droppedCard = data.data;
                          // print('onWillAcceptWithDetails ${droppedCard.toString()}');

                          if(isValidTableauDrop(tableau[i].isNotEmpty ? tableau[i].last : null, droppedCard)) {
                            // print('Will accept tableau drop');
                            return true;
                          }

                          // print('Will not accept tableau drop');
                          return false;
                        },
                        builder: (context, candidateData, rejectedData) => SizedBox(
                          width: cardWidth,
                          height: cardHeight * 5,
                          //Draw tableau cards overlapping each other
                          child: Stack(
                            children: [
                              for(int j = 0; j < tableau[i].length; j++)
                                Positioned(
                                  left: 0,
                                  top: j * 20.0,
                                  child: tableau[i][j],
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              //Spacer
              const Row(
                children: [
                  SizedBox(height: 10)
                ],
              ),
            ],
          ),
        ),
      ),

    );
  }

  List<PlayingCard> shuffledDeck() {
    List<PlayingCard> deck = [];
    for (var suit in PlayingCard.suits) {
      for (var value in PlayingCard.values) {
        deck.add(PlayingCard(value, suit, false, key: UniqueKey()/*Key('$value$suit')*/));
      }
    }
    deck.shuffle();
    return deck;
  }

  bool suitColorMatches(String thisCardSuit, String otherCardSuit) {
    // print('suitColorMatches $thisCardSuit $otherCardSuit');
    if (thisCardSuit == PlayingCard.hearts || thisCardSuit == PlayingCard.diamonds) {
      // print('checking red');
      bool matches = otherCardSuit == PlayingCard.hearts || otherCardSuit == PlayingCard.diamonds;
      // print(matches);
      return matches;
    }
    // print('checking black');
    bool matches = otherCardSuit == PlayingCard.spades || otherCardSuit == PlayingCard.clubs;
    // print(matches);
    return matches;
  }

  bool isOneBelow(PlayingCard bottomCard, PlayingCard droppedCard) {
    int myValueIndex = PlayingCard.values.indexOf(bottomCard.value);
    int droppedValueIndex = PlayingCard.values.indexOf(droppedCard.value);
    // print('Comparing ${bottomCard.value} ${droppedCard.value}');
    return myValueIndex == droppedValueIndex + 1;
  }

  bool isOneAbove(PlayingCard bottomCard, PlayingCard droppedCard) {
    int myValueIndex = PlayingCard.values.indexOf(bottomCard.value);
    int droppedValueIndex = PlayingCard.values.indexOf(droppedCard.value);
    // print('Comparing ${bottomCard.value} $droppedCard.value');
    return myValueIndex + 1 == droppedValueIndex;
  }

  bool isValidTableauDrop(PlayingCard? bottomCard, PlayingCard droppedCard) {
    // print('isValidTableauDrop()');
    if(bottomCard == null) {
      // print('bottomCard is null, dropping ${droppedCard.value}');
      return droppedCard.value == 'K';
    }
    if(bottomCard == droppedCard) {
      // print('bottomCard == droppedCard');
      return false;
    }
    // print('isValidTableauDrop ${droppedCard.value} ${droppedCard.suit}(${droppedCard.currentPile}) -> ${bottomCard?.value} ${bottomCard?.suit}(${bottomCard?.currentPile})');

    bool suitColorMatch = suitColorMatches(bottomCard.suit, droppedCard.suit);
    bool oneBelow = isOneBelow(bottomCard, droppedCard);
    // print('suitColorMatch $suitColorMatch oneBelow $oneBelow');
    return !suitColorMatch && oneBelow;
  }

  bool isValidFoundationDrop(PlayingCard bottomCard, PlayingCard droppedCard) {
    // print('isValidFoundationDrop ${droppedCard.value} ${droppedCard.suit}(${droppedCard.currentPile}) -> ${bottomCard.value} ${bottomCard.suit}(${bottomCard.currentPile})');

    bool retVal = (bottomCard.suit == droppedCard.suit) && isOneAbove(bottomCard, droppedCard);
    // print(retVal);
    return retVal;
  }

  void removeCardFromDragSource(PlayingCard card) {
    // print('removeCardFromDragSource(${card.currentPile})');

    setState(() {
      // if(PlayingCard.dragSource == PlayingCard.DRAG_SOURCE_WASTE) {
      if(card.currentPile == PlayingCard.DRAG_SOURCE_WASTE) {
        // print('Removing ${waste.last.toString()} from waste');
        waste.removeLast();
      }
      for(int i = 0; i < 7; i++) {
        // if(PlayingCard.dragSource == PlayingCard.DRAG_SOURCE_TABLEAUS[i]) {
        if(card.currentPile == PlayingCard.DRAG_SOURCE_TABLEAUS[i]) {
          // print('Removing ${tableau[i].last.toStr()} from tableau $i');
          tableau[i].removeLast();

          if(tableau[i].isNotEmpty && !tableau[i].last.isFaceUp) {
            tableau[i].last.isFaceUp = true;
            //HACK Remove last card and recreate it with isFaceUp set to true. Seems like not managing state properly.
            PlayingCard newLast = PlayingCard(tableau[i].last.value, tableau[i].last.suit, true, key: UniqueKey());
            newLast.currentPile = tableau[i].last.currentPile;
            tableau[i].removeLast();
            tableau[i].add(newLast);
          }
        }
      }
    });
  }

  void addCardFromDragSource(PlayingCard card, List<PlayingCard> target, int newPile) {
    // print('addCardFromDragSource(${card.currentPile})');

    setState(() {
      if(card.currentPile == PlayingCard.DRAG_SOURCE_WASTE) {
        // print('Transferring card from waste');
        target.add(waste.removeLast());
      }
      for(int i = 0; i < 7; i++) {
        if(card.currentPile == PlayingCard.DRAG_SOURCE_TABLEAUS[i]) {
          // print('Transferring card from tableau $i');
          tableau[i].remove(card);
          target.add(card);

          if(card.cardOnTopOfThisOne != null) {
            addCardFromDragSource(card.cardOnTopOfThisOne!, target, newPile);
          }

          if(tableau[i].isNotEmpty && !tableau[i].last.isFaceUp) {
            tableau[i].last.isFaceUp = true;
            //HACK Remove last card and recreate it with isFaceUp set to true. Seems like not managing state properly.
            PlayingCard newLast = PlayingCard(tableau[i].last.value, tableau[i].last.suit, true, key: UniqueKey());
            newLast.currentPile = tableau[i].last.currentPile;
            tableau[i].removeLast();
            tableau[i].add(newLast);
          }
        }
      }
      for(int i = 0; i < 4; i++) {
        if(card.currentPile == PlayingCard.DRAG_SOURCE_FOUNDATIONS[i]) {
          // print('Transferring card from foundation $i');
          target.add(foundation[i].removeLast());
        }
      }
      target.last.currentPile = newPile;
    });
  }

  void resetGame() {
    setState(() {
      stock = shuffledDeck();
      waste.clear();
      foundation.clear();
      tableau.clear();

      for (int j = 0; j < 7; j++) {
        tableau.add([]);
      }

      //Deal cards to tableau
      for(int i = 0; i <= 6; i++) {
        for (int j = i; j < 7; j++) {
          stock[0].currentPile = PlayingCard.DRAG_SOURCE_TABLEAUS[j];
          stock[0].isFaceUp = j == i;
          tableau[j].add(stock[0]);
          stock.removeAt(0);
        }
      }

      for(int i = 0; i < 4; i++) {
        foundation.add([]);
        foundation[i].add(PlayingCard('', PlayingCard.suits[i], true, key: UniqueKey()/*Key(PlayingCard.suits[i])*/));
        foundation[i].last.currentPile = PlayingCard.DRAG_SOURCE_FOUNDATIONS[i];
      }
    });
  }
}
