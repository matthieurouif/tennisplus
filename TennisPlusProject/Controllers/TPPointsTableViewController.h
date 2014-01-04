//
//  TPPointsTableViewController.h
//  TennisPlus
//
//  Created by Matthieu Rouif on 30/11/2013.
//
//

#import <Parse/Parse.h>

@interface TPPointsTableViewController : PFQueryTableViewController
{
    PFObject * match;
}

@property (nonatomic, retain) PFObject * match;

@end
