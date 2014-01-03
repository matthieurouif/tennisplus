//
//  TPGamesViewController.m
//  TennisPlus
//
//  Created by Matthieu Rouif on 29/11/2013.
//
//

#import "TPGamesTableViewController.h"
#import "MBProgressHUD.h"
#import "TPPointsTableViewController.h"

@interface TPGamesTableViewController ()

@end

@implementation TPGamesTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // The className to query on
        self.parseClassName = @"Game";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 15;
        
    }
    return self;
}

-(void)addGame:(id)sender
{
    TPPointsTableViewController * pointsTableViewController = [[TPPointsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:pointsTableViewController animated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self signUp:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGame:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
}




- (void)signUp:(id)sender
{
    if (![PFUser currentUser])  // No user logged in
    {
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setFields: PFSignUpFieldsDefault];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,300,60)];
        label.numberOfLines = 2;
        label.text = @"Tennis+";
        label.textAlignment = NSTextAlignmentCenter;
        [signUpViewController.signUpView setLogo:label];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self.navigationController presentViewController:signUpViewController animated:YES completion:NULL];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 142.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count)
    {
        PFObject *aGame = [self.objects objectAtIndex:indexPath.row];
        TPPointsTableViewController * pointsTableViewController = [[TPPointsTableViewController alloc] initWithStyle:UITableViewStylePlain];
        pointsTableViewController.game = aGame;
        [self.navigationController pushViewController:pointsTableViewController animated:YES];

    }
    else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self loadObjects];
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"userCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    PFObject *aGame = [self.objects objectAtIndex:indexPath.row];
    cell.detailTextLabel.numberOfLines = 7;
    
    NSNumber *ServiceP11st = [aGame objectForKey:@"ServiceP11st"];
    NSNumber *ServiceP12nd = [aGame objectForKey:@"ServiceP12nd"];
    NSNumber *ServiceP1Double = [aGame objectForKey:@"ServiceP1Double"];
    NSNumber *ServiceP1Unknown = [aGame objectForKey:@"ServiceP1"];

    NSNumber *ServiceP21st = [aGame objectForKey:@"ServiceP21st"];
    NSNumber *ServiceP22nd = [aGame objectForKey:@"ServiceP22nd"];
    NSNumber *ServiceP2Double = [aGame objectForKey:@"ServiceP2Double"];
    NSNumber *ServiceP2Unknown = [aGame objectForKey:@"ServiceP2"];

    NSNumber *pointP1Winner = [aGame objectForKey:@"WinP1WinnerShot"];
    NSNumber *pointP1UnforcedError = [aGame objectForKey:@"WinP2UnforcedError"];
    NSNumber *pointP1DoubleFault = [aGame objectForKey:@"WinP2DoubleFault"];
    NSNumber *pointP1ForcedError = [aGame objectForKey:@"WinP1"];

    NSNumber *pointP2Winner = [aGame objectForKey:@"WinP2WinnerShot"];
    NSNumber *pointP2UnforcedError = [aGame objectForKey:@"WinP1UnforcedError"];
    NSNumber *pointP2DoubleFault = [aGame objectForKey:@"WinP1DoubleFault"];
    NSNumber *pointP2ForcedError = [aGame objectForKey:@"WinP2"];

    NSNumber  *pointsCount = [aGame objectForKey:@"pointsCount"];
    CGFloat   player1ServiceCount = ServiceP11st.intValue + ServiceP12nd.intValue + ServiceP1Double.intValue + ServiceP1Unknown.intValue;
    CGFloat   player2ServiceCount = ServiceP21st.intValue + ServiceP22nd.intValue + ServiceP2Double.intValue + ServiceP2Unknown.intValue;
    CGFloat   player1PointsCount = pointP1Winner.intValue + pointP2UnforcedError.intValue + pointP2DoubleFault.intValue + pointP1ForcedError.intValue;
    CGFloat   player2PointsCount = pointP2Winner.intValue + pointP1UnforcedError.intValue + pointP1DoubleFault.intValue + pointP2ForcedError.intValue;

    NSString *player1ServiceInformation = [NSString stringWithFormat:@"P1(%.f services) : 1st %.f%% Double %.f%%",
                                           player1ServiceCount,
                                           100*ServiceP11st.floatValue/player1ServiceCount,
                                           100*ServiceP1Double.floatValue/player1ServiceCount];
    
    NSString *player2ServiceInformation = [NSString stringWithFormat:@"P2(%.f services): 1st %.f%% Double %.f%%",
                                           player2ServiceCount,
                                           100*ServiceP21st.floatValue/player2ServiceCount,
                                           100*ServiceP2Double.floatValue/player2ServiceCount];
    
    NSString *player1PointInformation = [NSString stringWithFormat:@"P1(%.f%% of points): Winners %.f%%\nErrors: Unforced Errors %.f%%, Double %.f%%",
                                         100*player1PointsCount/pointsCount.floatValue,
                                         100*pointP1Winner.floatValue/pointsCount.floatValue,
                                         100*pointP1UnforcedError.floatValue/pointsCount.floatValue,
                                         100*pointP1DoubleFault.floatValue/pointsCount.floatValue];
    
    NSString *player2PointInformation = [NSString stringWithFormat:@"P2(%.f%% of points): Winners %.f%%\nErrors: Unforced Errors %.f%%, Double %.f%%",
                                         100*player2PointsCount/pointsCount.floatValue,
                                         100*pointP2Winner.floatValue/pointsCount.floatValue,
                                         100*pointP2UnforcedError.floatValue/pointsCount.floatValue,
                                         100*pointP2DoubleFault.floatValue/pointsCount.floatValue];

    cell.textLabel.text = [NSString stringWithFormat:@"%@ vs %@,(%.f points)",[PFUser currentUser].username, aGame[@"player2Name"],pointsCount.floatValue];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@\n\n%@\n%@",
                                 player1PointInformation,
                                 player1ServiceInformation,
                                 player2PointInformation,
                                 player2ServiceInformation];
    
    return cell;
}



#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query orderByDescending:@"createdAt"];
    //use the cache
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


#pragma mark -
#pragma mark PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [user saveEventually:^(BOOL succeeded, NSError *error)
     {
         if(error)
         {
             [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
         }
     }];
    
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

@end

