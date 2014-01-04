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
@property (nonatomic, strong) IBOutlet UIButton     *firstServiceStateButton;
@property (nonatomic, strong) IBOutlet UIButton     *secondServiceStateButton;


-(void)newCurrentPoint;

@end

@implementation TPNewPointViewController


@synthesize match;

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
    _firstPlayerWinButton.titleLabel.textAlignment = _secondPlayerWinButton.titleLabel.textAlignment = _firstServiceStateButton.titleLabel.textAlignment = _secondServiceStateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _firstPlayerWinButton.titleLabel.numberOfLines = _secondPlayerWinButton.titleLabel.numberOfLines = 0;
    [_secondPlayerWinButton setTintColor:[UIColor whiteColor]];
    [_firstServiceStateButton setTintColor:[UIColor whiteColor]];
    [_secondServiceStateButton setTintColor:[UIColor whiteColor]];

    [_firstPlayerWinButton setBackgroundColor:[UIColor redColor]];
    [_secondPlayerWinButton setBackgroundColor:[UIColor blueColor]];
    [_secondServiceStateButton setBackgroundColor:[UIColor orangeColor]];
    [_firstServiceStateButton setBackgroundColor:[UIColor orangeColor]];

    
    _currentPoint.servingType = 0;
    [self newCurrentPoint];
    _currentPoint[@"match"] = self.match;
    
    [self updateServiceTypeDisplay];
    [self updateScore];
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
- (IBAction)handleFirstButtonAttachmentGesture:(UIPanGestureRecognizer*)gesture
{
    _currentPoint.winner = FirstPlayerId;
    
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [gesture velocityInView:self.view];
        if(velocity.x < -200)
        {
            [self unforcedErrorAction:nil];
        }
        else if (velocity.x > 200)
        {
            [self winnerAction:nil];
        }
        //[self.animator removeAllBehaviors];
        [self save:nil];
    }
    
}

- (IBAction)handleSecondButtonAttachmentGesture:(UIPanGestureRecognizer*)gesture
{
    _currentPoint.winner = SecondPlayerId;
    
    if(gesture.state == UIGestureRecognizerStateEnded){
        CGPoint velocity = [gesture velocityInView:self.view];
        if(velocity.x < -200)
        {
            [self unforcedErrorAction:nil];
        }
        else if (velocity.x > 200)
        {
            [self winnerAction:nil];
        }
        //[self.animator removeAllBehaviors];
        [self save:nil];
    }
}



-(IBAction)unforcedErrorAction:(id)sender
{
    _currentPoint.endingEvent = EndingEventUnforcedError;
}

-(IBAction)winnerAction:(id)sender
{
    _currentPoint.endingEvent = EndingEventWinnerShot;
}

-(IBAction)forcedErrorAction:(id)sender
{
    if(sender == _firstPlayerWinButton)
        _currentPoint.winner = FirstPlayerId;
    else if(sender == _secondPlayerWinButton)
        _currentPoint.winner = SecondPlayerId;
    
    _currentPoint.endingEvent = EndingEventForcedError;
    [self save:nil];
}


-(void)updateServiceTypeDisplay
{
    NSString *serviceDescription;
    switch (_currentPoint.servingType) {
        case ServingTypeFirstServe:
            serviceDescription = NSLocalizedString(@"1st Serve", @"Description of first service state");
            break;
        case ServingTypeSecondServe:
            serviceDescription =  NSLocalizedString(@"2nd Serve", @"Description of second service state");
            break;
        case ServingTypeDoubleFault:
            serviceDescription = NSLocalizedString(@"Double Fault", @"Description of double fault service state");
            break;
        default:
            serviceDescription = NSLocalizedString(@"Ready", @"Description of ready service state");
            break;
    }
    
    [_firstServiceStateButton setTitle:serviceDescription forState:UIControlStateNormal];
    [_secondServiceStateButton setTitle:serviceDescription forState:UIControlStateNormal];

    if(_currentPoint.servingType == ServingTypeDoubleFault){
        switch (_currentPoint.server)
        {
                //if we don't know the server, we can't record the point
            case -1:{
                //restor the SegmentControl
                _currentPoint.servingType = UISegmentedControlNoSegment;
                [[[UIAlertView alloc] initWithTitle:@"No server assigned" message:@"Assign a server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
                break;
            case FirstPlayerId:{
                //if first player was serving, player 2 wins
                _currentPoint.winner = SecondPlayerId;
                [self save:nil];
            }
                break;
            case SecondPlayerId:{
                //if first player was serving, player 2 wins
                _currentPoint.winner = FirstPlayerId;
                [self save:nil];
            }
                break;
                
        }
    }
}

-(void)updateScore{
    
    if(_currentPoint.server == FirstPlayerId){
        _firstServiceStateButton.hidden = NO;
        _secondServiceStateButton.hidden = YES;
    }
    else{
        _firstServiceStateButton.hidden = YES;
        _secondServiceStateButton.hidden = NO;
    }


    
    
    NSMutableAttributedString *firstPlayerButtonAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"player 1\n%@\n%d",[_currentPoint readablePlayer1PointScore],_currentPoint.p1GameBefore]];
    [firstPlayerButtonAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:100] range:[firstPlayerButtonAttributedString.string rangeOfString:[_currentPoint readablePlayer1PointScore]]];
    [_firstPlayerWinButton setAttributedTitle:firstPlayerButtonAttributedString forState:UIControlStateNormal];
    
    NSMutableAttributedString *secondPlayerButtonAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d\n%@\nplayer 2",_currentPoint.p2GameBefore,[_currentPoint readablePlayer2PointScore]]];
    [secondPlayerButtonAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:100] range:[secondPlayerButtonAttributedString.string rangeOfString:[_currentPoint readablePlayer2PointScore]]];
    [_secondPlayerWinButton setAttributedTitle:secondPlayerButtonAttributedString forState:UIControlStateNormal];
    
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
    NSString *audibleText;
    
    if((_currentPoint.p1GameBefore + _currentPoint.p2GameBefore) != (_previousPoint.p1GameBefore + _previousPoint.p2GameBefore))
    {
        audibleText = (_currentPoint.server == FirstPlayerId)?
        [NSString stringWithFormat:@"%d %d",_currentPoint.p1GameBefore,_currentPoint.p2GameBefore]:
        [NSString stringWithFormat:@"%d %d",_currentPoint.p2GameBefore,_currentPoint.p1GameBefore];
    }
    else
    {
        audibleText = (_currentPoint.server == FirstPlayerId)?
        [NSString stringWithFormat:@"%@ %@",[_currentPoint audiblePlayer1PointScore],[_currentPoint audiblePlayer2PointScore]]:
        [NSString stringWithFormat:@"%@ %@",[_currentPoint audiblePlayer2PointScore],[_currentPoint audiblePlayer1PointScore]];
    }
    
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:audibleText];
    [utterance setRate:0.4f];
    [synthesizer speakUtterance:utterance];
    
}

-(IBAction)changeServiceType:(id)sender
{
    //if we have a double fault
    _currentPoint.servingType += 1;
    [self updateServiceTypeDisplay];
    
}

-(IBAction)deleteLastPoint:(id)sender
{
    _currentPoint = [TPPoint object];
    _currentPoint.p1PointBefore = _previousPoint.p1PointBefore;
    _currentPoint.p2PointBefore = _previousPoint.p2PointBefore;
    _currentPoint.p1GameBefore = _previousPoint.p1GameBefore;
    _currentPoint.p2GameBefore = _previousPoint.p2GameBefore;
    _currentPoint.p1SetBefore = _previousPoint.p1SetBefore;
    _currentPoint.p2SetBefore = _previousPoint.p2PointBefore;
    _currentPoint.server = _previousPoint.server;
    
    [_previousPoint deleteEventually];
    
    [self updateServiceTypeDisplay];
    [self updateScore];

    //should be able to delte more than one point
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

-(void)newCurrentPoint
{
    if(_previousPoint)
    {
        _currentPoint = [TPPoint object];
        TPPoint *tempPoint = [_previousPoint resultingScore];
        _currentPoint.p1PointBefore = tempPoint.p1PointBefore;
        _currentPoint.p2PointBefore = tempPoint.p2PointBefore;
        _currentPoint.p1GameBefore = tempPoint.p1GameBefore;
        _currentPoint.p2GameBefore = tempPoint.p2GameBefore;
        _currentPoint.p1SetBefore = tempPoint.p1SetBefore;
        _currentPoint.p2SetBefore = tempPoint.p2PointBefore;
        _currentPoint.server = _previousPoint.server;
    }
    else
    {
        _currentPoint = [TPPoint startingPoint];
    }
}

-(IBAction)save:(id)sender
{
    [_currentPoint incrementMatchCounters];
    _previousPoint = _currentPoint;
    [self newCurrentPoint];
    
    _currentPoint[@"match"] = self.match;

    //if a game was won change server
    if ((_currentPoint.p1GameBefore + _currentPoint.p2GameBefore) > (_previousPoint.p1GameBefore + _previousPoint.p2GameBefore))
    {
        //as FirstPlayerId + SecondPlayerId = 3;
        _currentPoint.server = 3 - _previousPoint.server;
    }
        
    [self updateServiceTypeDisplay];
    [self updateScore];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = [NSString stringWithFormat:@"Loading"];

    [_previousPoint saveEventually:^(BOOL succeeded, NSError *error) {
        [hud hide:YES];
    }];
    [match saveInBackground];
}

@end
