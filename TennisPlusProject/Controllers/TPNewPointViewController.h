//
//  TPNewPointViewController.h
//  TennisPlus
//
//  Created by Matthieu Rouif on 30/11/2013.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TPNewPointViewController : UIViewController <UICollisionBehaviorDelegate>
{
    PFObject *game;
    
    int serviceType;
    int server;
    int winner;
    int endingEvent;
}

typedef enum {
    FirstPlayerId                             = 1,
    SecondPlayerId                            = 2,
} PlayerId;

typedef enum {
    ServingTypeFirstServe                   = 1,
    ServingTypeSecondServe                  = 2,
    ServingTypeDoubleFault                  = 3,
} ServingType;

typedef enum {
    EndingEventWinnerShot                             = 1,
    EndingEventUnforcedError                          = 2,
    EndingEventDoubleFault                            = 3,
} EndingEvent;

@property (nonatomic, retain) PFObject * game;

-(IBAction)save:(id)sender;

-(IBAction)changeServiceType:(id)sender;
-(IBAction)unforcedErrorAction:(id)sender;
-(IBAction)winnerAction:(id)sender;

@end
