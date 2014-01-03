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
@property (nonatomic, strong) IBOutlet UIButton     *serviceStateButton;

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
    
    [_firstPlayerWinButton setTintColor:[UIColor whiteColor]];
    _firstPlayerWinButton.titleLabel.textAlignment = _secondPlayerWinButton.titleLabel.textAlignment = _serviceStateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_secondPlayerWinButton setTintColor:[UIColor whiteColor]];
    [_serviceStateButton setTintColor:[UIColor whiteColor]];

    [_firstPlayerWinButton setBackgroundColor:[UIColor redColor]];
    [_secondPlayerWinButton setBackgroundColor:[UIColor blueColor]];
    [_serviceStateButton setBackgroundColor:[UIColor orangeColor]];

    
    serviceType = 0;
    [self updateServiceTypeDisplay];
    // Do any additional setup after loading the view from its nib.
    /*UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.firstPlayerWinButton]];
    // Creates collision boundaries from the bounds of the dynamic animator's
    // reference view (self.view).
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionDelegate = self;
    [animator addBehavior:collisionBehavior];
    
    self.animator = animator;*/

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
    
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        //All fingers are lifted.
        //[self.animator removeAllBehaviors];
    }
}


-(IBAction)unforcedErrorAction:(id)sender
{
    endingEvent = EndingEventUnforcedError;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Unforced Error";
}

-(IBAction)winnerAction:(id)sender
{
    endingEvent = EndingEventWinnerShot;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Winner";
}

-(void)updateServiceTypeDisplay
{
    switch (serviceType) {
        case ServingTypeFirstServe:
            [_serviceStateButton setTitle:NSLocalizedString(@"1st Serve", @"Description of first service state") forState:UIControlStateNormal];
            break;
        case ServingTypeSecondServe:
            [_serviceStateButton setTitle:NSLocalizedString(@"2nd Serve", @"Description of second service state") forState:UIControlStateNormal];
            break;
        case ServingTypeDoubleFault:
            [_serviceStateButton setTitle:NSLocalizedString(@"Double Fault", @"Description of double fault service state") forState:UIControlStateNormal];
            break;
        default:
            [_serviceStateButton setTitle:NSLocalizedString(@"Ready", @"Description of ready service state") forState:UIControlStateNormal];
            break;
    }
    
    if(serviceType == ServingTypeDoubleFault){
        switch (server)
        {
                //if we don't know the server, we can't record the point
            case -1:{
                //restor the SegmentControl
                serviceType = UISegmentedControlNoSegment;
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

-(IBAction)changeServiceType:(id)sender
{
    //if we have a double fault
    serviceType += 1;
    [self updateServiceTypeDisplay];
    
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
    
    switch (server)
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
    
    
    switch (serviceType)
    {
        case ServingTypeFirstServe:{
            point[@"servingType"] = [NSNumber numberWithInt:ServingTypeFirstServe];
            keyToIncrementService = [keyToIncrementService stringByAppendingString:@"1st"];
        }
            break;
        case ServingTypeSecondServe:{
            point[@"servingType"] = [NSNumber numberWithInt:ServingTypeSecondServe];
            keyToIncrementService = [keyToIncrementService stringByAppendingString:@"2nd"];
        }
            break;
        case ServingTypeDoubleFault:{
            point[@"servingType"] = [NSNumber numberWithInt:ServingTypeDoubleFault];
            keyToIncrementService = [keyToIncrementService stringByAppendingString:@"Double"];
            
            //also increment the edingEvent
            keyToIncrementWinner = [keyToIncrementWinner stringByAppendingString:@"DoubleFault"];
            point[@"endingEvent"] = [NSNumber numberWithInt:EndingEventDoubleFault];
        }
            break;
    }
    
    
    switch (endingEvent)
    {
        case EndingEventWinnerShot:{
            keyToIncrementWinner = [keyToIncrementWinner stringByAppendingString:@"WinnerShot"];
            point[@"endingEvent"] = [NSNumber numberWithInt:EndingEventWinnerShot];
        }
            break;
        case EndingEventUnforcedError:{
            point[@"endingEvent"] = [NSNumber numberWithInt:EndingEventUnforcedError];
            keyToIncrementWinner = [keyToIncrementWinner stringByAppendingString:@"UnforcedError"];
        }
            break;
    }
    
    [game incrementKey:keyToIncrementWinner];
    [game incrementKey:keyToIncrementService];
            
    endingEvent = 0;
    serviceType = 0;
    [self updateServiceTypeDisplay];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";

    [point saveEventually:^(BOOL succeeded, NSError *error) {
        [hud hide:YES];
    }];
    [game saveInBackground];
    }

@end
