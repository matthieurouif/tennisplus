//
//  TPNewPointViewController.m
//  TennisPlus
//
//  Created by Matthieu Rouif on 30/11/2013.
//
//

#import "TPNewPointViewController.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "APLPositionToBoundsMapping.h"

@interface TPNewPointViewController ()

@property (nonatomic, strong) UIDynamicAnimator     *animator;
@property (nonatomic, strong) UIAttachmentBehavior  *attachmentBehavior;
@property (nonatomic, strong) IBOutlet UIButton     *firstPlayerWinButton;
@property (nonatomic, strong) IBOutlet UIButton     *secondPlayerWinButton;

@end

@implementation TPNewPointViewController

@synthesize game;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_firstPlayerWinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _firstPlayerWinButton.titleLabel.textAlignment = _secondPlayerWinButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_secondPlayerWinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    eventSegmentControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    serverTypeSegmentControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    serverSegmentControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    
    // Do any additional setup after loading the view from its nib.
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.firstPlayerWinButton]];
    // Creates collision boundaries from the bounds of the dynamic animator's
    // reference view (self.view).
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionDelegate = self;
    [animator addBehavior:collisionBehavior];
    
    self.animator = animator;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//| ----------------------------------------------------------------------------
//  IBAction for the Pan Gesture Recognizer that has been configured to track
//  touches in self.view.
//
- (IBAction)handleAttachmentGesture:(UIPanGestureRecognizer*)gesture
{
    [self.attachmentBehavior setAnchorPoint:[gesture locationInView:self.view]];
    
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        //All fingers are lifted.
        //[self.animator removeAllBehaviors];
    }
}


-(IBAction)serviceTypeWasDefined:(id)sender
{
    //if we have a double fault
    if(serverTypeSegmentControl.selectedSegmentIndex == 2){
        switch (serverSegmentControl.selectedSegmentIndex)
        {
                //if we don't know the server, we can't record the point
            case UISegmentedControlNoSegment:{
                //restor the SegmentControl
                serverTypeSegmentControl.selectedSegmentIndex = UISegmentedControlNoSegment;
                [[[UIAlertView alloc] initWithTitle:@"No server assigned" message:@"Assign a server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
                break;
            case 0:{
                //if first player was serving, player 2 wins
                [self save:_secondPlayerWinButton];
            }
                break;
            case 1:{
                //if first player was serving, player 2 wins
                [self save:_firstPlayerWinButton];
            }
                break;
            
        }
    }
    
}

-(IBAction)addAttachment:(id)sender
{
    //remove the attachment behaviour
    [self.animator removeBehavior:self.attachmentBehavior];
    
    UIButton * senderButton = (UIButton *)sender;
    [self.view bringSubviewToFront:senderButton];

    CGPoint roundCenterPoint = CGPointMake(senderButton.center.x, senderButton.center.y);
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:senderButton attachedToAnchor:roundCenterPoint];
    [attachmentBehavior setFrequency:2.0];
    [attachmentBehavior setDamping:0.3];
    [self.animator addBehavior:attachmentBehavior];
    self.attachmentBehavior = attachmentBehavior;
    
    /*APLPositionToBoundsMapping *buttonBoundsDynamicItem = [[APLPositionToBoundsMapping alloc] initWithTarget:sender];
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[buttonBoundsDynamicItem] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.angle = M_PI_4;
    pushBehavior.magnitude = 2.0;
    [animator addBehavior:pushBehavior];
    [pushBehavior setActive:TRUE];*/
    
}


-(IBAction)save:(id)sender
{
    PFObject * point = [PFObject objectWithClassName:@"Point"];
    point[@"game"] = game;
    [game incrementKey:@"pointsCount"];
    NSString *keyToIncrementWinner;
    NSString *keyToIncrementService;
    
    if(sender == _firstPlayerWinButton){
        point[@"winning"] = [NSNumber numberWithInt:FirstPlayerId];
        keyToIncrementWinner = @"WinP1";
    }
    else if(sender == _secondPlayerWinButton){
        point[@"winning"] = [NSNumber numberWithInt:SecondPlayerId];
        keyToIncrementWinner = @"WinP2";
    }
    
    switch (serverSegmentControl.selectedSegmentIndex)
    {
        case 0:{
            point[@"serving"] = [NSNumber numberWithInt:FirstPlayerId];
            keyToIncrementService = @"ServiceP1";
        }
            break;
        case 1:
        {
            point[@"serving"] = [NSNumber numberWithInt:SecondPlayerId];
            keyToIncrementService = @"ServiceP2";
        }
            break;
    }
    
    
    switch (serverTypeSegmentControl.selectedSegmentIndex)
    {
        case 0:{
            point[@"servingType"] = [NSNumber numberWithInt:ServingTypeFirstServe];
            keyToIncrementService = [keyToIncrementService stringByAppendingString:@"1st"];
        }
            break;
        case 1:{
            point[@"servingType"] = [NSNumber numberWithInt:ServingTypeSecondServe];
            keyToIncrementService = [keyToIncrementService stringByAppendingString:@"2nd"];
        }
            break;
        case 2:{
            point[@"servingType"] = [NSNumber numberWithInt:ServingTypeDoubleFault];
            keyToIncrementService = [keyToIncrementService stringByAppendingString:@"Double"];
            
            //also increment the edingEvent
            keyToIncrementWinner = [keyToIncrementWinner stringByAppendingString:@"DoubleFault"];
            point[@"endingEvent"] = [NSNumber numberWithInt:EndingEventDoubleFault];
        }
            break;
    }
    
    
    switch (eventSegmentControl.selectedSegmentIndex)
    {
        case 0:{
            keyToIncrementWinner = [keyToIncrementWinner stringByAppendingString:@"WinnerShot"];
            point[@"endingEvent"] = [NSNumber numberWithInt:EndingEventWinnerShot];
        }
            break;
        case 1:{
            point[@"endingEvent"] = [NSNumber numberWithInt:EndingEventUnforcedError];
            keyToIncrementWinner = [keyToIncrementWinner stringByAppendingString:@"UnforcedError"];
        }
            break;
    }
    
    [game incrementKey:keyToIncrementWinner];
    [game incrementKey:keyToIncrementService];
            
    eventSegmentControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    serverTypeSegmentControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";

    [point saveEventually:^(BOOL succeeded, NSError *error) {
        [hud hide:YES];
    }];
    [game saveInBackground];
    }

@end
