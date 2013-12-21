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
    PFObject * game;
}

@property (nonatomic, retain) PFObject * game;

@end
