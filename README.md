# Tennis Plus

Tennis Plus is a quantified seld app for tennis player. It helps you track your progress when playing with partners with really simple user interface. Best usage is to put the iPhone in an armband and start playing.

Process is quite simple, you create a match an record points with gesture. Text to voice announces the score. The goal is to keep track of double-faults in service and force error to work on it on the long term

You can get the [source code](https://github.com/matthieurouif/tennisplus).

## Gestures

Start touch from the player who last hitted the ball:
Swipe toward the player side : unforced error
Swipe left or right : forced error
Swipe towards the other player side : winner
Single Tap : service fault
Double Tap : double fault

## iOS Setup

TennisPlus requires Xcode 5 and iOS 7.
It's based on the parse platform

## Findings

The weight of the iPhone is a problem when playing tennis. Especially when serving because the right arm is more used and player needs to focus more. One solution might be to have the receiver keep track of the points.

Knowing that unforced error are track already has a huge impact on players game. Even the other player not having track of his errors

Having to keep track of all point decrease the overall pleasure of playing tennis on the short term.

Text to voice was a real plus in the user experience to be sure the right gesture was done. It was a huge gain

When keeping track of the point, it's easier to start from the last plauer that hit the ball and declare what happened. The other way around (starting from who won the point requires more thinking)
