# 52!Solitaire

A Solitaire game made with Flutter. This is for me to avoid ads and to be able 
to do some analysis of the games I play. This is also a great test bed for 
functionality that I may want to implement in other projects.

## Installing on the phone

1. Turn on Wireless Debugging in settings on the phone.
2. In Android Studio, using the search at the top right, search for "Pair Devices Using Wi-Fi".
3. Back on the phone click "Pair device with QR code".
4. Scan the QR code on the computer screen.
NOTE: This may not work if you have updates to install in Android Studio.


## Release Notes

# v1.6 1/29/2025
- Move You Win message to a popup so it doesn't push the quote off the screen.
- Move quotes to a cloud API so they can be changed after release.
- Pull in weather information.
- Change doubleTap to single tap for moving from tableau.
- Added 130 more quotes.

# v1.5 1/27/2025
- Add motivational quotes.
- Set back arrow on Settings page to use foreground color.
- Added feature to double-click on bottom card to move stack. REQUIRES REFACTORING, MOVING TO BACKLOG.
- Fixed issue of moving card between tableau piles makes it not possible to move either the
  moved card or the bottom card to foundation. CANNOT REPRODUCE...
- Changed waste pile click move to single click instead of double click.

# v1.4 1/26/2025
- Added 52! logo image.
- Added color chooser.
- Fixed drag to foundation issue where it was staying connected to the tableau it was dragged from.



