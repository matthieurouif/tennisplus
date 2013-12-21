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
    IBOutlet UISegmentedControl *serverSegmentControl;
    IBOutlet UISegmentedControl *serverTypeSegmentControl;
    IBOutlet UISegmentedControl *eventSegmentControl;

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
-(IBAction)serviceTypeWasDefined:(id)sender;

@end
