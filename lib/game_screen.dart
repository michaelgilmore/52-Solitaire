import 'package:flutter/material.dart';
import 'package:gsolitaire/playing_card.dart';
import 'package:gsolitaire/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.title});

  final String title;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  //Debugging
  final bool showCardOnTopButton = false;

  final int BOTTOM_NAV_INDEX_HOME = 0;
  final int BOTTOM_NAV_INDEX_RESET = 1;
  final int BOTTOM_NAV_INDEX_TOOLS = 2;
  final int BOTTOM_NAV_INDEX_USE_CARD = 3;
  final int BOTTOM_NAV_INDEX_NEXT_CARD = 4;

  late List<PlayingCard> stock;
  late List<PlayingCard> savedDeck;
  List<PlayingCard> waste = [];
  List<List<PlayingCard>> foundation = [];
  List<List<PlayingCard>> tableau = [];

  final pileCountTextStyle = const TextStyle(color: Colors.white, fontSize: 10);

  int _currentBottomNavIndex = 0;

  late double screenWidth;
  late double screenHeight;

  late final prefs;

  bool replayLastGame = false;
  bool youWillWin = false;


  @override
  void initState() {
    // print('GameScreen initState()');
    super.initState();

    SharedPreferences.getInstance().then((value) {
       prefs = value;
    });

    _currentBottomNavIndex = BOTTOM_NAV_INDEX_HOME;

    stock = replayLastGame ? savedDeck.toList() : shuffledDeck();
    savedDeck = stock.toList();

    setUpGame();
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
    else if(_currentBottomNavIndex == BOTTOM_NAV_INDEX_NEXT_CARD) {
      flipNextStockCard();
    }
    else if(_currentBottomNavIndex == BOTTOM_NAV_INDEX_USE_CARD) {
      useCard();
    }
  }

  flipNextStockCard() {
    // print('flipNextStockCard()');

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
      cardHeight = 82;
      cardWidth = 51;
      centerFontSize = 13;
      cornerFontSize = 10;
      spaceBetweenCenterAndCorner = 2;
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
    for(int i = 0; i < foundation.length; i++) {
      if(foundation[i].isNotEmpty) {
        for (int j = 0; j < foundation[i].length; j++) {
          foundation[i][j].cardHeight = cardHeight;
          foundation[i][j].cardWidth = cardWidth;
          foundation[i][j].centerFontSize = centerFontSize;
          foundation[i][j].cornerFontSize = cornerFontSize;
          foundation[i][j].spaceBetweenCenterAndCorner =
              spaceBetweenCenterAndCorner;
        }
      }
    }

    //loop through all cards in tableau and set card height and width
    for(int i = 0; i < tableau.length; i++) {
      if(tableau[i].isNotEmpty) {
        for (int j = 0; j < tableau[i].length; j++) {
          tableau[i][j].cardHeight = cardHeight;
          tableau[i][j].cardWidth = cardWidth;
          tableau[i][j].centerFontSize = centerFontSize;
          tableau[i][j].cornerFontSize = cornerFontSize;
          tableau[i][j].spaceBetweenCenterAndCorner =
              spaceBetweenCenterAndCorner;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
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
              icon: Icon(Icons.recycling),
              label: 'Reset',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handyman),
              label: 'Tools',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pan_tool_alt),
              label: 'Use',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.skip_next),
              label: 'Next',
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
                visible: wonGame(),
                child: const Text('YOU WIN!', style: TextStyle(color: Colors.white, fontSize: 50)),
              ),

              //Stock, Waste, Foundation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //Stock
                  GestureDetector(
                      onTap: () => flipNextStockCard(),
                      child: Column(
                          children: [
                            stock.isNotEmpty ? stock[0] : Container(
                              height: cardHeight,
                              width: cardWidth,
                              //Add dashed gray border around stock pile
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, style: BorderStyle.solid, width: 1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            Text(stock.length.toString(), style: pileCountTextStyle),
                          ]
                      )
                  ),

                  //Waste
                  GestureDetector(
                      onDoubleTap: () {
                        useCard();
                      },
                      child: Column(
                          children: [
                            waste.isNotEmpty ? waste.last : SizedBox(height: cardHeight, width: cardWidth),
                            Text(waste.length.toString(), style: pileCountTextStyle),
                          ]
                      )
                  ),

                  SizedBox(width: spaceBetweenWasteAndFoundation),

                  //Foundation
                  for(int a = 0; a < foundation.length; a++)
                    DragTarget(
                      onAcceptWithDetails: (DragTargetDetails data) {
                        PlayingCard droppedCard = data.data;
                        // print('onAcceptWithDetails ${droppedCard.toStr()}');

                        if(foundation[a].isNotEmpty) {
                          if (isValidFoundationDrop(
                              foundation[a].last, droppedCard)) {
                            // print('Accepting foundation drop');
                            foundation[a].add(droppedCard);
                            removeCardFromDragSource(droppedCard);
                            foundation[a].last.currentPile = PlayingCard
                                .DRAG_SOURCE_FOUNDATIONS[a];
                          }
                        }
                      },
                      onWillAcceptWithDetails: (DragTargetDetails data) {
                        PlayingCard droppedCard = data.data;
                        // print('onWillAcceptWithDetails ${droppedCard.toStr()}');

                        if(foundation[a].isNotEmpty) {
                          if (isValidFoundationDrop(
                              foundation[a].last, droppedCard)) {
                            // print('Will accept foundation drop');
                            return true;
                          }
                        }

                        // print('Rejecting drop');
                        return false;
                      },
                      builder: (context, candidateData, rejectedData) => Column(
                        children: [
                          foundation[a].isNotEmpty ? foundation[a].last : Container(
                            height: cardHeight,
                            width: cardWidth,
                            //Add dashed gray border around foundation pile
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, style: BorderStyle.solid, width: 1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          Text((foundation[a].length).toString(), style: pileCountTextStyle),
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
                  for(int i = 0; i < tableau.length; i++)
                    GestureDetector(
                      onDoubleTap: () {
                        // print('Double tap on tableau $i card ${tableau[i].last.toStr()}');

                        setState(() {
                          if(tableau[i].isEmpty) {
                            return;
                          }

                          PlayingCard topCard = tableau[i].last;

                          if(topCard.value == PlayingCard.values[0]) {
                            for(int j = 0; j < foundation.length; j++) {
                              if(foundation[j].isEmpty) {
                                foundation[j].add(tableau[i].removeLast());
                                foundation[j].last.currentPile = PlayingCard.DRAG_SOURCE_FOUNDATIONS[j];
                                rebuildLastTableauCardFaceUp(i);
                                return;
                              }
                            }
                            return;
                          }

                          //Check each foundation pile to see if the top card can be moved there
                          for(int j = 0; j < foundation.length; j++) {
                            if(foundation[j].isNotEmpty) {
                              if (isValidFoundationDrop(
                                  foundation[j].last, topCard)) {
                                // print('Moving card to foundation');
                                foundation[j].add(tableau[i].removeLast());
                                foundation[j].last.currentPile =
                                PlayingCard.DRAG_SOURCE_FOUNDATIONS[j];

                                if (tableau[i].isNotEmpty &&
                                    !tableau[i].last.isFaceUp) {
                                  rebuildLastTableauCardFaceUp(i);
                                }
                                return;
                              }
                            }
                          }

                          //Check each tableau pile to see if the top card can be moved there
                          for(int j = 0; j < tableau.length; j++) {
                            if(j != i) {
                              if(isValidTableauDrop(tableau[j].isNotEmpty ? tableau[j].last : null, topCard)) {
                                // print('Moving card to tableau');
                                if(tableau[j].isNotEmpty) {
                                  tableau[j].last.cardOnTopOfThisOne = topCard;
                                }
                                tableau[j].add(tableau[i].removeLast());
                                tableau[j].last.currentPile = PlayingCard.DRAG_SOURCE_TABLEAUS[j];

                                if(tableau[i].isNotEmpty && !tableau[i].last.isFaceUp) {
                                  rebuildLastTableauCardFaceUp(i);
                                }
                                return;
                              }
                            }
                          }
                        });
                      },
                      child: DragTarget(
                        onAcceptWithDetails: (DragTargetDetails data) {
                          PlayingCard droppedCard = data.data;

                          if(isValidTableauDrop(tableau[i].isNotEmpty ? tableau[i].last : null, droppedCard)) {
                            // print('Accepting tableau drop ${droppedCard.toStr()}');

                            if(tableau[i].isNotEmpty) {
                              // print('Setting cardOnTopOfThisOne for ${tableau[i].last.toStr()} to ${droppedCard.toStr()}');
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

              Visibility(
                visible: showCardOnTopButton,
                child: ElevatedButton(
                  onPressed: () {
                    //Loop through all cards in all tableau piles and print their card on top
                    for(int i = 0; i < tableau.length; i++) {
                      if(tableau[i].isNotEmpty) {
                        //Loop through all cards in this tableau pile and print its card on top
                        for(int j = 0; j < tableau[i].length; j++) {
                          print('Tableau ${i+1} card ${tableau[i][j].toStr()} card on top of this one is ${tableau[i][j].cardOnTopOfThisOne?.toStr()}');
                        }
                      }
                    }
                  },
                  child: const Text('Print cards on top')
                ),
              )
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
      for(int i = 0; i < tableau.length; i++) {
        // if(PlayingCard.dragSource == PlayingCard.DRAG_SOURCE_TABLEAUS[i]) {
        if(card.currentPile == PlayingCard.DRAG_SOURCE_TABLEAUS[i]) {
          // print('Removing ${tableau[i].last.toStr()} from tableau $i');
          tableau[i].removeLast();

          if(tableau[i].isNotEmpty && !tableau[i].last.isFaceUp) {
            rebuildLastTableauCardFaceUp(i);
          }
        }
      }
    });
  }

  void rebuildLastTableauCardFaceUp(int i) {
    if(tableau[i].isEmpty) {
      return;
    }
    tableau[i].last.cardOnTopOfThisOne = null;
    //HACK Remove last card and recreate it with isFaceUp set to true. Seems like not managing state properly.
    PlayingCard newLast = PlayingCard(tableau[i].last.value, tableau[i].last.suit, true, key: UniqueKey());
    newLast.currentPile = tableau[i].last.currentPile;
    newLast.isFaceUp = true;
    tableau[i].removeLast();
    tableau[i].add(newLast);
  }

  void addCardFromDragSource(PlayingCard card, List<PlayingCard> target, int newPile) {
    // print('addCardFromDragSource(${card.currentPile})');

    setState(() {
      if(card.currentPile == PlayingCard.DRAG_SOURCE_WASTE) {
        // print('Transferring card from waste');
        target.add(waste.removeLast());
        target.last.currentPile = newPile;
      }
      for(int i = 0; i < tableau.length; i++) {
        if(card.currentPile == PlayingCard.DRAG_SOURCE_TABLEAUS[i]) {
          // print('Transferring card from tableau ${i+1} to $newPile');

          // if(newPile > 0 && tableau[newPile - 1].isNotEmpty) {
          //   tableau[newPile - 1].last.cardOnTopOfThisOne = card;
          // }

          tableau[i].remove(card);
          target.add(card);
          target.last.currentPile = newPile;

          if(card.cardOnTopOfThisOne != null) {
            // print('Adding card on top of this one ${card.cardOnTopOfThisOne!.toStr()}');
            addCardFromDragSource(card.cardOnTopOfThisOne!, target, newPile);
          }
          else {
            // print('No card on top of ${card.toStr()}');
          }

          if(tableau[i].isNotEmpty && !tableau[i].last.isFaceUp) {
            rebuildLastTableauCardFaceUp(i);
          }
        }
      }
      for(int i = 0; i < foundation.length; i++) {
        if(card.currentPile == PlayingCard.DRAG_SOURCE_FOUNDATIONS[i]) {
          // print('Transferring card from foundation ${i+1} to $newPile');
          target.add(foundation[i].removeLast());
        }
        target.last.currentPile = newPile;
      }
    });
  }

  bool wonGame() {
    // print('wonGame()');

    //Determine if you just won
    bool youJustWon = stock.isEmpty && waste.isEmpty && foundation[0].length == 14 && foundation[1].length == 14 && foundation[2].length == 14 && foundation[3].length == 14;
    bool returnValue = youWillWin || youJustWon;
    if(returnValue) {
      int numGamesWon = prefs.getInt('num_games_won') ?? 0;
      prefs.setInt('num_games_won', numGamesWon + 1);
      setState(() {});
      youWillWin = false;
    }
    return returnValue;
  }

  void setReplayLastGame(bool replayGame) {
    replayLastGame = replayGame;
  }

  void resetGame() async {
    // print('resetGame()');

    youWillWin = false;

    //show dialog box asking if you want to start a new game or replay the last game
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Game'),
          content: const Text('Would you like to start a new game or replay the last game?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                replayLastGame = false;
              },
              child: const Text('New Game'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                replayLastGame = true;
              },
              child: const Text('Replay Last Game'),
            ),
          ],
        );
      },
    );

    stock = replayLastGame ? savedDeck.toList() : shuffledDeck();
    savedDeck = stock.toList();

    //loop through all stock cards and set isFaceUp to false
    for(int i = 0; i < stock.length; i++) {
      stock[i].isFaceUp = false;
      stock[i].cardOnTopOfThisOne = null;
      stock[i].currentPile = PlayingCard.DRAG_SOURCE_STOCK;
    }

    waste.clear();
    foundation.clear();
    tableau.clear();

    setUpGame();

    setState(() {});

    final num_games_played = prefs.getInt('num_games_played') ?? 0;
    await prefs.setInt('num_games_played', num_games_played + 1);
  }

  void setUpGame() {
    for (int j = 0; j < 7; j++) {
      tableau.add([]);
    }

    //Deal cards to tableau
    for(int i = 0; i <= (tableau.length-1); i++) {
      for (int j = i; j < tableau.length; j++) {
        stock[0].currentPile = PlayingCard.DRAG_SOURCE_TABLEAUS[j];
        stock[0].cardOnTopOfThisOne = null;
        stock[0].isFaceUp = j == i;
        tableau[j].add(stock[0]);
        stock.removeAt(0);
      }
    }

    for(int i = 0; i < 4; i++) {
      foundation.add([]);
    }
  }

  void checkForWin() {
    if(waste.isEmpty) {
      if(stock.isEmpty) {
        //If all cards in all piles of tableau are face up, set you have won
        bool allFaceUp = true;
        for(int i = 0; i < tableau.length; i++) {
          if(tableau[i].isNotEmpty) {
            for(PlayingCard card in tableau[i]) {
              if(!card.isFaceUp) {
                // print('Not all cards are face up, tableau $i card ${card.toStr()}');
                allFaceUp = false;
                break;
              }
            }
            if(allFaceUp == false) {
              break;
            }
          }
        }
        if(allFaceUp) {
          setState(() {
            youWillWin = true;
          });
        }
      }
      return;
    }
  }

  void useCard() {
    // print('useCard()');

    setState(() {
      if(waste.isEmpty) {
        checkForWin();
        return;
      }

      //Check each foundation pile to see if the top card can be moved there
      for(int i = 0; i < foundation.length; i++) {
        if (foundation[i].isEmpty) {
          if (waste.last.value == PlayingCard.values[0]) {
            foundation[i].add(waste.removeLast());
            foundation[i].last.currentPile =
            PlayingCard.DRAG_SOURCE_FOUNDATIONS[i];
            return;
          }
        }
        else if (isValidFoundationDrop(foundation[i].last, waste.last)) {
          // print('Moving card to foundation');
          foundation[i].last.cardOnTopOfThisOne = waste.last;
          foundation[i].add(waste.removeLast());
          foundation[i].last.currentPile =
          PlayingCard.DRAG_SOURCE_FOUNDATIONS[i];
          return;
        }
      }

      //Check each tableau pile to see if the top card can be moved there
      for(int i = 0; i < tableau.length; i++) {
        if(isValidTableauDrop(tableau[i].isNotEmpty ? tableau[i].last : null, waste.last)) {
          // print('Moving card to tableau');
          if(tableau[i].isNotEmpty) {
            tableau[i].last.cardOnTopOfThisOne = waste.last;
          }
          tableau[i].add(waste.removeLast());
          tableau[i].last.currentPile = PlayingCard.DRAG_SOURCE_TABLEAUS[i];
          return;
        }
      }

      checkForWin();
    });
  }
}
