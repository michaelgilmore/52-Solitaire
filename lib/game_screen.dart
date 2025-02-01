import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gsolitaire/playing_card.dart';
import 'package:gsolitaire/quote.dart';
import 'package:gsolitaire/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/weather.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static TextEditingController weatherKeyController = TextEditingController();
  static TextEditingController latitudeController = TextEditingController();
  static TextEditingController longitudeController = TextEditingController();

  static late List<PlayingCard> savedDeck;

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
  List<PlayingCard> waste = [];
  List<List<PlayingCard>> foundation = [];
  List<List<PlayingCard>> tableau = [];

  late final TextStyle pileCountTextStyle;

  int _currentBottomNavIndex = 0;

  late double screenWidth;
  late double screenHeight;

  late final prefs;

  bool replayLastGame = false;
  bool youWillWin = false;

  Color appBarBackgroundColor = Colors.indigoAccent;
  Color appForegroundColor = Colors.white;
  Color appBackgroundColor = Colors.grey[600]!;
  Color bottomNavBackgroundColor = Colors.indigoAccent;

  late Quote quote;

  WeatherFactory? weatherFactory;
  Weather? _weather;

  @override
  void initState() {
    // print('GameScreen initState()');
    super.initState();

    SharedPreferences.getInstance().then((value) {
       prefs = value;

       if (GameScreen.weatherKeyController.text.isEmpty) {
         GameScreen.weatherKeyController.text =
             prefs.getString('weatherKey') ?? '';
         // print('weatherKey: ${GameScreen.weatherKeyController.text}');
       }
       if (GameScreen.latitudeController.text.isEmpty) {
         GameScreen.latitudeController.text = prefs.getString('lat') ?? '';
         // print('lat: ${GameScreen.latitudeController.text}');
       }
       if (GameScreen.longitudeController.text.isEmpty) {
         GameScreen.longitudeController.text = prefs.getString('long') ?? '';
         // print('long: ${GameScreen.longitudeController.text}');
       }

       if(GameScreen.weatherKeyController.text.isNotEmpty
           && GameScreen.latitudeController.text.isNotEmpty
           && GameScreen.longitudeController.text.isNotEmpty
       ) {
         initializeWeather();
       }
    });

    _currentBottomNavIndex = BOTTOM_NAV_INDEX_HOME;

    stock = replayLastGame ? GameScreen.savedDeck.toList() : shuffledDeck();
    GameScreen.savedDeck = stock.toList();

    pileCountTextStyle = TextStyle(color: appForegroundColor, fontSize: 10);

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

    appBarBackgroundColor = Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_BAR] ?? Colors.blue;
    appForegroundColor = Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_FOREGROUND] ?? Colors.white;
    appBackgroundColor = Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_BACKGROUND] ?? Colors.grey;
    bottomNavBackgroundColor = Settings.colorMapNotifier.value[Settings.COLOR_AREA_BOTTOM_NAV] ?? Colors.blue;

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

    if(_weather == null
        && GameScreen.weatherKeyController.text.isNotEmpty
        && GameScreen.latitudeController.text.isNotEmpty
        && GameScreen.longitudeController.text.isNotEmpty
    ) {
      initializeWeather();
    }

    double? temp = 0;
    double? lowTemp = 0;//degrees F
    double? highTemp = 0;//degrees F
    double? maxWind = 0;//mph
    String? windDirection = '';
    double? totalPrecip = 0;//inches
    String? area = '';

    if(_weather != null) {
      if(_weather!.temperature != null) {
        temp = _weather!.temperature?.fahrenheit;
      }
      if(_weather!.tempMin != null) {
        lowTemp = _weather!.tempMin?.fahrenheit;
      }
      if(_weather!.tempMax != null) {
        highTemp = _weather!.tempMax?.fahrenheit;
      }
      maxWind = _weather!.windGust;
      if(_weather!.windDegree != null) {
        if(_weather!.windDegree! > 337) windDirection = 'N';
        else if(_weather!.windDegree! > 292) windDirection = 'NW';
        else if(_weather!.windDegree! > 247) windDirection = 'W';
        else if(_weather!.windDegree! > 202) windDirection = 'SW';
        else if(_weather!.windDegree! > 157) windDirection = 'S';
        else if(_weather!.windDegree! > 112) windDirection = 'SE';
        else if(_weather!.windDegree! > 67) windDirection = 'E';
        else if(_weather!.windDegree! > 22) windDirection = 'NE';
        else windDirection = 'N';
      }
      // totalPrecip = (_weather!.rainLast3Hours ?? 0) + (_weather!.snowLast3Hours ?? 0);
      area = _weather!.areaName ?? '';
    }

    return ValueListenableBuilder(
        valueListenable: Settings.colorMapNotifier,
        builder: (context, colorMap, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: appBarBackgroundColor,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      //Add logo image
                      Image.asset(
                          'assets/images/52!-logo.png', width: 40, height: 40),
                      const SizedBox(width: 6),
                      Text('Solitaire', style: TextStyle(color: appForegroundColor)),
                    ],
                  ),
                  Row(
                    children: [
                      Visibility(
                        visible: _weather != null,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("http://openweathermap.org/img/wn/${_weather?.weatherIcon}@2x.png"),
                            ),
                          ),
                        ),
                      ),
                      Text('$area\n${temp?.toStringAsFixed(0)}-${maxWind?.toStringAsFixed(0)}$windDirection',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 10, color: appForegroundColor)),
                    ],
                  ),
                ],
              ),
            ),
            backgroundColor: appBackgroundColor,
            bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Colors.red,
                currentIndex: _currentBottomNavIndex,
                onTap: _onBottomNavItemTapped,
                unselectedItemColor: Colors.lightBlueAccent,
                selectedItemColor: Colors.lightBlue,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home, color: appForegroundColor),
                    label: 'Home',
                    backgroundColor: bottomNavBackgroundColor,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.recycling, color: appForegroundColor),
                    label: 'Reset',
                    backgroundColor: bottomNavBackgroundColor,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.handyman, color: appForegroundColor),
                    label: 'Tools',
                    backgroundColor: bottomNavBackgroundColor,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.pan_tool_alt, color: appForegroundColor),
                    label: 'Use',
                    backgroundColor: bottomNavBackgroundColor,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.skip_next, color: appForegroundColor),
                    label: 'Next',
                    backgroundColor: bottomNavBackgroundColor,
                  ),
                ]
            ),
            body: Padding(
              padding: EdgeInsets.all(surroundingPadding),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [

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
                                          border: Border.all(color: Colors.grey,
                                              style: BorderStyle.solid,
                                              width: 1),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      Text(stock.length.toString(),
                                          style: pileCountTextStyle),
                                    ]
                                )
                            ),

                            //Waste
                            GestureDetector(
                                // onDoubleTap: () {
                                //   useCard();
                                // },
                                onTap: () {
                                  useCard();
                                  if(checkForWin()) {
                                    showYouWinDialog(context);
                                  }
                                },
                                child: Column(
                                    children: [
                                      waste.isNotEmpty ? waste.last : SizedBox(
                                          height: cardHeight, width: cardWidth),
                                      Text(waste.length.toString(),
                                          style: pileCountTextStyle),
                                    ]
                                )
                            ),

                            SizedBox(width: spaceBetweenWasteAndFoundation),

                            //Foundation
                            for(int j = 0; j < foundation.length; j++)
                              DragTarget(
                                onAcceptWithDetails: (DragTargetDetails data) {
                                  PlayingCard droppedCard = data.data;
                                  // print('onAcceptWithDetails ${droppedCard.toStr()}');

                                  if(foundation[j].isEmpty) {
                                    if(droppedCard.value == PlayingCard.values[0]/*Ace*/) {
                                      int i = droppedCard.currentPile - 1;
                                      moveFromTableauToFoundation(i, j);
                                    }
                                  }
                                  if (foundation[j].isNotEmpty) {
                                    if (isValidFoundationDrop(
                                        foundation[j].last, droppedCard)) {
                                      int i = droppedCard.currentPile - 1;
                                      moveFromTableauToFoundation(i, j);
                                    }
                                  }

                                  if(checkForWin()) {
                                    showYouWinDialog(context);
                                  }
                                },
                                onWillAcceptWithDetails: (DragTargetDetails data) {
                                  PlayingCard droppedCard = data.data;
                                  // print('onWillAcceptWithDetails ${droppedCard.toStr()}');

                                  if(foundation[j].isEmpty) {
                                    if(droppedCard.value == PlayingCard.values[0]/*Ace*/) {
                                      // print('Will accept foundation drop');
                                      return true;
                                    }
                                  }
                                  if (foundation[j].isNotEmpty) {
                                    if (isValidFoundationDrop(
                                        foundation[j].last, droppedCard)) {
                                      // print('Will accept foundation drop');
                                      return true;
                                    }
                                  }

                                  // print('Rejecting drop');
                                  return false;
                                },
                                builder: (context, candidateData, rejectedData) =>
                                    Column(
                                      children: [
                                        foundation[j].isNotEmpty ? foundation[j]
                                            .last : Container(
                                          height: cardHeight,
                                          width: cardWidth,
                                          //Add dashed gray border around foundation pile
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey,
                                                style: BorderStyle.solid,
                                                width: 1),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        Text((foundation[j].length).toString(),
                                            style: pileCountTextStyle),
                                      ],
                                    ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 50),

                        //Tableau
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for(int i = 0; i < tableau.length; i++)
                              GestureDetector(
                                onTap: () {
                                  // print('Double tap on tableau $i card ${tableau[i].last.toStr()}');

                                  setState(() {
                                    if (tableau[i].isEmpty) {
                                      return;
                                    }

                                    PlayingCard topCard = tableau[i].last;

                                    if (topCard.value == PlayingCard.values[0]/*Ace*/) {
                                      for (int j = 0; j < foundation.length; j++) {
                                        if (foundation[j].isEmpty) {
                                          // print('Moving ace from tableau $i to foundation $j');
                                          moveFromTableauToFoundation(i, j);
                                          return;
                                        }
                                      }
                                      return;
                                    }

                                    //Check each foundation pile to see if the top card can be moved there
                                    for (int j = 0; j < foundation.length; j++) {
                                      if (foundation[j].isNotEmpty) {
                                        if (isValidFoundationDrop(
                                            foundation[j].last, topCard)) {
                                          // print('Moving card from tableau $i to foundation $j');
                                          moveFromTableauToFoundation(i, j);
                                          return;
                                        }
                                      }
                                    }

                                    //Check each tableau pile to see if the top card can be moved there
                                    for (int j = 0; j < tableau.length; j++) {
                                      if (j != i) {
                                        if (isValidTableauDrop(tableau[j].isNotEmpty
                                            ? tableau[j].last
                                            : null, topCard)) {
                                          // print('Moving card to tableau');
                                          if (tableau[j].isNotEmpty) {
                                            tableau[j].last.cardOnTopOfThisOne =
                                                topCard;
                                          }
                                          tableau[j].add(tableau[i].removeLast());
                                          tableau[j].last.currentPile =
                                          PlayingCard.DRAG_SOURCE_TABLEAUS[j];

                                          if (tableau[i].isNotEmpty &&
                                              !tableau[i].last.isFaceUp) {
                                            rebuildLastTableauCardFaceUp(i);
                                          }
                                          return;
                                        }
                                      }
                                    }
                                  });

                                  if(checkForWin()) {
                                    showYouWinDialog(context);
                                  }
                                },
                                child: DragTarget(
                                  onAcceptWithDetails: (DragTargetDetails data) {
                                    // print('Dragging to tableau');

                                    PlayingCard droppedCard = data.data;

                                    if (isValidTableauDrop(tableau[i].isNotEmpty
                                        ? tableau[i].last
                                        : null, droppedCard)) {
                                      // print('Valid tableau drop ${droppedCard.toStr()}');

                                      if (tableau[i].isNotEmpty) {
                                        // print('Setting cardOnTopOfThisOne for ${tableau[i].last.toStr()} to ${droppedCard.toStr()}');
                                        tableau[i].last.cardOnTopOfThisOne =
                                            droppedCard;
                                      }

                                      addCardFromDragSource(droppedCard, tableau[i],
                                          PlayingCard.DRAG_SOURCE_TABLEAUS[i]);
                                    }
                                    else {
                                      // print('Not a valid tableau drop');
                                    }

                                    if(checkForWin()) {
                                      showYouWinDialog(context);
                                    }
                                  },
                                  onWillAcceptWithDetails: (
                                      DragTargetDetails data) {
                                    PlayingCard droppedCard = data.data;
                                    // print('onWillAcceptWithDetails ${droppedCard.toString()}');

                                    if (isValidTableauDrop(tableau[i].isNotEmpty
                                        ? tableau[i].last
                                        : null, droppedCard)) {
                                      // print('Will accept tableau drop');
                                      return true;
                                    }

                                    // print('Will not accept tableau drop');
                                    return false;
                                  },
                                  builder: (context, candidateData, rejectedData) =>
                                      SizedBox(
                                        width: cardWidth,
                                        height: cardHeight * 5,
                                        //Draw tableau cards overlapping each other
                                        child: Stack(
                                          children: [
                                            for(int j = 0; j <
                                                tableau[i].length; j++)
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

                        const SizedBox(height: 10),

                        //Debugging: Show cards on top button
                        if (kDebugMode)
                          Visibility(
                            visible: showCardOnTopButton,
                            child: ElevatedButton(
                                onPressed: () {
                                  //Loop through all card in the foundation piles and print their card on top
                                  for (int i = 0; i < foundation.length; i++) {
                                    if (foundation[i].isNotEmpty) {
                                      //Loop through all cards in this foundation pile and print its card on top
                                      for (int j = 0; j < foundation[i].length; j++) {
                                          print('Foundation ${i + 1} card ${foundation[i][j]
                                            .toStr()} card on top of this one is ${foundation[i][j]
                                            .cardOnTopOfThisOne?.toStr()}');
                                        }
                                    }
                                  }
                                  //Loop through all cards in all tableau piles and print their card on top
                                  for (int i = 0; i < tableau.length; i++) {
                                    if (tableau[i].isNotEmpty) {
                                      //Loop through all cards in this tableau pile and print its card on top
                                      for (int j = 0; j < tableau[i].length; j++) {
                                        if (kDebugMode) {
                                          print('Tableau ${i + 1} card ${tableau[i][j]
                                            .toStr()} card on top of this one is ${tableau[i][j]
                                            .cardOnTopOfThisOne?.toStr()}');
                                        }
                                      }
                                    }
                                  }
                                },
                                child: const Text('Print cards on top')
                              ),
                            )
                      ],
                    ),
                    //Quote
                    Text(quote.quote, style: TextStyle(fontSize: 14, color: appForegroundColor)),
                    Text('- ${quote.author}', style: TextStyle(fontSize: 8, fontStyle: FontStyle.italic, color: appForegroundColor)),
                  ],
                ),
              ),
            ),

          );
        }
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

    if(!droppedCard.isFaceUp) {
      print('Cannot drop a card that is face down');
      return false;
    }

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

    if(droppedCard.cardOnTopOfThisOne != null) {
      print('Cannot drop card with other cards on top of it. '
          '${droppedCard.toStr()} has '
          '${droppedCard.cardOnTopOfThisOne?.toStr()} on it.');
      return false;
    }
    if(!droppedCard.isFaceUp) {
      print('Cannot drop a card that is face down');
      return false;
    }

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
    newLast.cardOnTopOfThisOne = null;
    tableau[i].removeLast();
    tableau[i].add(newLast);
  }

  void addCardFromDragSource(PlayingCard card, List<PlayingCard> targetPile, int newPileNumber) {
    // print('addCardFromDragSource(${card.currentPile})');

    setState(() {
      if(card.currentPile == PlayingCard.DRAG_SOURCE_WASTE) {
        // print('Transferring card from waste');
        targetPile.add(waste.removeLast());
        targetPile.last.currentPile = newPileNumber;
      }
      for(int i = 0; i < tableau.length; i++) {
        if(card.currentPile == PlayingCard.DRAG_SOURCE_TABLEAUS[i]) {
          // print('Transferring card from tableau ${i+1} to $newPileNumber');

          // if(newPile > 0 && tableau[newPile - 1].isNotEmpty) {
          //   tableau[newPile - 1].last.cardOnTopOfThisOne = card;
          // }

          tableau[i].remove(card);
          targetPile.add(card);
          targetPile.last.currentPile = newPileNumber;

          if(card.cardOnTopOfThisOne != null) {
            // print('Adding card on top of this one ${card.cardOnTopOfThisOne!.toStr()}');
            addCardFromDragSource(card.cardOnTopOfThisOne!, targetPile, newPileNumber);
          }
          else {
            // print('No card on top of ${card.toStr()}');
          }

          if(tableau[i].isNotEmpty) {
            if(!tableau[i].last.isFaceUp) {
              rebuildLastTableauCardFaceUp(i);
            }

            tableau[i].last.cardOnTopOfThisOne = null;
          }
        }
      }
      for(int i = 0; i < foundation.length; i++) {
        if(card.currentPile == PlayingCard.DRAG_SOURCE_FOUNDATIONS[i]) {
          // print('Transferring card from foundation ${i+1} to $newPile');
          targetPile.add(foundation[i].removeLast());
        }
        targetPile.last.currentPile = newPileNumber;
      }
    });
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

    stock = replayLastGame ? GameScreen.savedDeck.toList() : shuffledDeck();
    GameScreen.savedDeck = stock.toList();

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

    quote = Quote();

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

  bool checkForWin() {
    // print('checkForWin()');

    if(waste.isNotEmpty) return false;
    if(stock.isNotEmpty) return false;
    if(tableau.any((pile) => pile.isNotEmpty && !pile.first.isFaceUp)) {
      //loop through all tableau piles and print card with its isFaceUp value
      // for(List<PlayingCard> eachPile in tableau) {
        // print('${eachPile.first.toStr()} isFaceUp: ${eachPile.first.isFaceUp}');
      // }

      return false;
    }

    return true;
  }

  void useCard() {
    // print('useCard()');

    setState(() {
      if(waste.isEmpty) {
        if(checkForWin()) {
          showYouWinDialog(context);
        }
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

      if(checkForWin()) {
        showYouWinDialog(context);
      }
    });
  }

  void moveFromTableauToFoundation(int i, int j) {
    // print('moveFromTableauToFoundation($i, $j)');

    PlayingCard droppedCard = tableau[i].last;
    foundation[j].add(droppedCard);
    removeCardFromDragSource(droppedCard);

    //Clean up the new card's connections
    // print('Dragging to foundation $j');
    // print('Previous pile ${droppedCard.currentPile}');
    if(tableau[droppedCard.currentPile-1].isNotEmpty) {
      PlayingCard cardUnder = tableau[droppedCard.currentPile - 1].last;
      // print('Card under was ${cardUnder.toStr()}');
      cardUnder.cardOnTopOfThisOne = null;
      foundation[j].last.currentPile = PlayingCard
          .DRAG_SOURCE_FOUNDATIONS[j];
    }
  }

  void showYouWinDialog(BuildContext context) {

    int numGamesWon = prefs.getInt('num_games_won') ?? 0;
    prefs.setInt('num_games_won', numGamesWon + 1);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Win'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
            content: const SizedBox(
              height: 150,
              width: 100,
              child: Center(
                child: Text('You Win!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Colors.green
                    )
                )
              )
            ),
          );
        });
  }

  void initializeWeather() {
    // print('weather api key: (${GameScreen.weatherKeyController.text.trim()})');

    weatherFactory ??= WeatherFactory(GameScreen.weatherKeyController.text.trim());
    if(weatherFactory != null) {
      double? lat = double.tryParse(GameScreen.latitudeController.text.trim());
      double? long = double.tryParse(GameScreen.longitudeController.text.trim());
      if (lat != null && long != null) {
        weatherFactory?.currentWeatherByLocation(lat, long).then((w) {
          setState(() {
            _weather = w;
          });
        });
      }
    }
  }
}
