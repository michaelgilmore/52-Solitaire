import 'package:flutter/material.dart';
import 'package:gsolitaire/playing_card.dart';

void main() {
  runApp(const GSolitaireApp());
}

class GSolitaireApp extends StatelessWidget {
  const GSolitaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GSolitaire',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: const MainScreen(title: '52! Solitaire'), //8*10^67
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  late List<PlayingCard> stock;
  List<PlayingCard> waste = [];
  List<List<PlayingCard>> foundation = [];
  List<List<PlayingCard>> tableau = [];

  @override
  void initState() {
    super.initState();

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

    // waste.last.currentPile = PlayingCard.DRAG_SOURCE_WASTE;

    //Debugging: loop through each card in each tableau and print currentPile
    for(int i = 0; i < 7; i++) {
      for(int j = 0; j < tableau[i].length; j++) {
        print('Tableau $i card $j (${tableau[i][j].toStr()}) currentPile: ${tableau[i][j].currentPile}');
      }
    }

    for(int i = 0; i < 4; i++) {
      foundation.add([]);
      foundation[i].add(PlayingCard('', PlayingCard.suits[i], true, key: Key(PlayingCard.suits[i])));
    }

    foundation[0].last.currentPile = PlayingCard.DRAG_SOURCE_FOUNDATION_HEARTS;
    foundation[1].last.currentPile = PlayingCard.DRAG_SOURCE_FOUNDATION_DIAMONDS;
    foundation[2].last.currentPile = PlayingCard.DRAG_SOURCE_FOUNDATION_CLUBS;
    foundation[3].last.currentPile = PlayingCard.DRAG_SOURCE_FOUNDATION_SPADES;
  }

  @override
  Widget build(BuildContext context) {

    // checkTopCardIsFaceUp();

    double surroundingPadding = MediaQuery.of(context).size.width < 600 ? 25 : 50;
    double spaceBetweenWasteAndFoundation = MediaQuery.of(context).size.width < 600 ? 50 : 100;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body:
        Padding(
          padding: EdgeInsets.all(surroundingPadding),
          child: SingleChildScrollView(
            child: Column(
              children: [

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
                            waste.isNotEmpty ? waste.last : SizedBox(height: PlayingCard.cardHeight, width: PlayingCard.cardWidth),
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
                            Text((foundation[a].length - 1).toString()),//TODO: Don't have empty be a card.
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
                    // SizedBox(height: 2*PlayingCard.cardHeight, width: 1),
                    for(int i = 0; i < 7; i++)
                      GestureDetector(
                        onDoubleTap: () {
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
                                  tableau[i].last.value = tableau[i].last.value;
                                  //print('Set tableau $i last card(${tableau[i].last.toStr()}) to face up');
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
                            width: PlayingCard.cardWidth,
                            height: PlayingCard.cardHeight * 2.5,
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
                    SizedBox(height: 50)
                  ],
                ),

                //Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: () {
                      setState(() {
                        for(int i = 0; i < 7; i++) {
                          if(tableau[i].isNotEmpty) {
                            tableau[i].last.isFaceUp = true;
                            //print('Tableau $i top card(${tableau[i].last.toStr()}) ${tableau[i].last.isFaceUp}');
                          }
                        }
                      });
                    }, child: const Text('Show Face Up')),
                    ElevatedButton(onPressed: () {
                      checkTopCardIsFaceUp();
                    }, child: const Text('Refresh'))
                  ]
                ),
            
                Text('${MediaQuery.of(context).size.width.toStringAsFixed(0)} x ${MediaQuery.of(context).size.height.toStringAsFixed(0)}'),
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
        deck.add(PlayingCard(value, suit, false, key: Key('$value$suit')));
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
    // print('removeCardFromDragSource(${PlayingCard.dragSource})');

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
            tableau[i].last.value = tableau[i].last.value;
            //print('Set tableau $i last card(${tableau[i].last
            //    .toStr()}) to face up');
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
          print('Transferring card from tableau $i');
          tableau[i].remove(card);
          target.add(card);

          if(card.cardOnTopOfThisOne != null) {
            addCardFromDragSource(card.cardOnTopOfThisOne!, target, newPile);
          }

          if(tableau[i].isNotEmpty && !tableau[i].last.isFaceUp) {
            PlayingCard newTopCard = tableau[i].last;
            newTopCard.isFaceUp = true;
            print('Set tableau $i last card(${tableau[i].last.toStr()}) to face up');
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

  void checkTopCardIsFaceUp() {
    print('checkTopCardIsFaceUp()');
    setState(() {
      for(int i = 0; i < 7; i++) {
        if(tableau[i].isNotEmpty) {
          if(!tableau[i].last.isFaceUp) {
            tableau[i].last.isFaceUp = true;
            print('Set tableau $i last card(${tableau[i].last.toStr()}) to face up');
          }
        }
      }
    });
    print('checkTopCardIsFaceUp() done');
  }
}
