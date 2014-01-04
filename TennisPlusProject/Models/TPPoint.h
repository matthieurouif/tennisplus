//
//  TPPoint.h
//  TennisPlus
//
//  Created by Matthieu Rouif on 03/01/2014.
//
//

#import <Parse/Parse.h>

@interface TPPoint : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property int winner;
@property int server;
@property int servingType;
@property int endingEvent;

@property int p1PointBefore;
@property int p2PointBefore;
@property int p1GameBefore;
@property int p2GameBefore;
@property int p1SetBefore;
@property int p2SetBefore;


typedef enum {
    FirstPlayerId                               = 1,
    SecondPlayerId                              = 2,
} PlayerId;

typedef enum {
    ServingTypeFirstServe                       = 1,
    ServingTypeSecondServe                      = 2,
    ServingTypeDoubleFault                      = 3,
} ServingType;

typedef enum {
    EndingEventForcedError                      = 0,
    EndingEventWinnerShot                       = 1,
    EndingEventUnforcedError                    = 2,
    EndingEventDoubleFault                      = 3,
} EndingEvent;


- (TPPoint *)resultingScore;
+ (TPPoint *)startingPoint;
- (void)incrementMatchCounters;

- (NSString *)readablePlayer1PointScore;
- (NSString *)readablePlayer2PointScore;

- (NSString *)audiblePlayer1PointScore;
- (NSString *)audiblePlayer2PointScore;



@end




