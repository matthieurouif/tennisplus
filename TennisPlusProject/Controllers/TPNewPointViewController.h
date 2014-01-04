//
//  TPNewPointViewController.h
//  TennisPlus
//
//  Created by Matthieu Rouif on 30/11/2013.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TPPoint.h"
#import <AVFoundation/AVFoundation.h>

@interface TPNewPointViewController : UIViewController <UICollisionBehaviorDelegate>

@property (nonatomic, retain) PFObject *match;
@property (nonatomic, retain) TPPoint *currentPoint;
@property (nonatomic, retain) TPPoint *previousPoint;

-(IBAction)save:(id)sender;

-(IBAction)changeServiceType:(id)sender;
-(IBAction)deleteLastPoint:(id)sender;
-(IBAction)unforcedErrorAction:(id)sender;
-(IBAction)winnerAction:(id)sender;

@end
