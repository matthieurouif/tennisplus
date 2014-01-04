//
//  TPPointsTableViewController.m
//  TennisPlus
//
//  Created by Matthieu Rouif on 30/11/2013.
//
//

#import "TPPointsTableViewController.h"
#import "MBProgressHUD.h"
#import "TPNewPointViewController.h"
#import "TPPoint.h"

@implementation TPPointsTableViewController

@synthesize match;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // The className to query on
        self.parseClassName = [TPPoint parseClassName];
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 50;
        
    }
    return self;
}

-(void)addPoint:(id)sender
{
    TPNewPointViewController * newPointViewController = [[TPNewPointViewController alloc] initWithNibName:@"TPNewPointViewController" bundle:nil];
    if(self.objects.count > 0)
        newPointViewController.previousPoint = [self.objects objectAtIndex:0];
    
    newPointViewController.match = self.match;
    [self.navigationController pushViewController:newPointViewController animated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPoint:)];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem,addButton];

    NSNumber  *pointsCount = [match objectForKey:@"pointsCount"];
    self.title = [NSString stringWithFormat:@"%d points",pointsCount.intValue];


}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSNumber  *pointsCount = [match objectForKey:@"pointsCount"];
    self.title = [NSString stringWithFormat:@"%d points",pointsCount.intValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count)
    {

    }
    else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //should make sure we calculate the counter right
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
    
    TPPoint *aPoint = [self.objects objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"starting score: %@-%@ (%d/%d)",[aPoint readablePlayer1PointScore],[aPoint readablePlayer2PointScore],aPoint.p1GameBefore,aPoint.p2GameBefore];
    
    NSString *description;
    switch (aPoint.endingEvent) {
        case EndingEventForcedError:
            description = @"Faute provoquée";
            break;
        case EndingEventWinnerShot:
            description = @"Point gagnant";
            break;
        case EndingEventUnforcedError:
            description = @"Faute directe";
            break;
        case EndingEventDoubleFault:
            description = @"Double faute";
            break;
        default:
            break;
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Player %d wins on %@",aPoint.winner,description];
    
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
    
    if (match) {
        [query whereKey:@"match" equalTo:self.match];
    }
    else{
        self.match = [PFObject objectWithClassName:@"TPMatch"];
        match[@"player1"] = [PFUser currentUser];
        [match saveEventually];
        [query setLimit:0];
        return query;
    }
    
    [query orderByDescending:@"createdAt"];
    //use the cache
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
