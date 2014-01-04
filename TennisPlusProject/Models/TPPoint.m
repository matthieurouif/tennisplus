//
//  TPPoint.m
//  TennisPlus
//
//  Created by Matthieu Rouif on 03/01/2014.
//
//

#import "TPPoint.h"
#import <Parse/PFObject+Subclass.h>

@implementation TPPoint

@dynamic winner,server,servingType,endingEvent;
@dynamic p1PointBefore,p2PointBefore,p1GameBefore,p2GameBefore,p1SetBefore,p2SetBefore;

+ (NSString *)parseClassName {
    return @"TPPoint";
}

-(int)addingOnePointFrom:(int)previousScore and:(int)otherPlayerPreviousScore{
    switch (previousScore) {
        case 0:
            return 15;
            break;
        case 15:
            return 30;
            break;
        case 30:
            return 40;
            break;
        case 40:{
            if(otherPlayerPreviousScore == 50)
                return 40;
            else
                return 50;
        }
        default:
            return -1;
            break;
    }
    return -1;
}

- (TPPoint *)resultingScore
{

    TPPoint *temporaryFollowingPoint = [TPPoint object];

    //if no winning return nil
    if(self.winner < 1 || self.winner > 2)
        return nil;
    
    //game ends with player one winning in the following condition : player1 wins the points he has 40 or 50 points and has more than 10 points
    if(self.winner == FirstPlayerId && self.p1PointBefore >= 40 && (self.p1PointBefore - self.p2PointBefore) >= 10){
        temporaryFollowingPoint.p1PointBefore = 0;
        temporaryFollowingPoint.p2PointBefore = 0;
        
        //set ends if player one has more than one point
        if((self.p1GameBefore >= 5 && (self.p1GameBefore - self.p2GameBefore) > 1) || (self.p1GameBefore == 6)){
            temporaryFollowingPoint.p1GameBefore = 0;
            temporaryFollowingPoint.p2GameBefore = 0;
            temporaryFollowingPoint.p1SetBefore = 1+self.p1SetBefore;
            temporaryFollowingPoint.p2SetBefore = self.p2SetBefore;
        }
        else{
            temporaryFollowingPoint.p1GameBefore = self.p1GameBefore + 1;
            temporaryFollowingPoint.p2GameBefore = self.p2GameBefore;
            temporaryFollowingPoint.p1SetBefore = self.p1SetBefore;
            temporaryFollowingPoint.p2SetBefore = self.p2SetBefore;
        }
    }
    //changing game and potentially set because player 2 won the game
    else if(self.winner == SecondPlayerId && self.p2PointBefore >= 40 && (self.p2PointBefore - self.p1PointBefore) >= 10){
        temporaryFollowingPoint.p1PointBefore = 0;
        temporaryFollowingPoint.p2PointBefore = 0;
        
        //set ends if player one has more than one point
        if((self.p2GameBefore >= 5 && (self.p2GameBefore - self.p1GameBefore) > 1) || (self.p2GameBefore == 6)){
            temporaryFollowingPoint.p1GameBefore = 0;
            temporaryFollowingPoint.p2GameBefore = 0;
            temporaryFollowingPoint.p1SetBefore = self.p1SetBefore;
            temporaryFollowingPoint.p2SetBefore = 1+self.p2SetBefore;
        }
        else{
            temporaryFollowingPoint.p1GameBefore = self.p1GameBefore;
            temporaryFollowingPoint.p2GameBefore = self.p2GameBefore + 1;
            temporaryFollowingPoint.p1SetBefore = self.p1SetBefore;
            temporaryFollowingPoint.p2SetBefore = self.p2SetBefore;
        }
    }
    //not changing game nor set
    else{
        temporaryFollowingPoint.p1GameBefore = self.p1GameBefore;
        temporaryFollowingPoint.p2GameBefore = self.p2GameBefore;
        temporaryFollowingPoint.p1SetBefore = self.p1SetBefore;
        temporaryFollowingPoint.p2SetBefore = self.p2SetBefore;

        if(self.winner == FirstPlayerId){
            temporaryFollowingPoint.p1PointBefore = [self addingOnePointFrom:self.p1PointBefore and:self.p2PointBefore];
            if(self.p2PointBefore == 50)
                temporaryFollowingPoint.p2PointBefore = 40;
            else
                temporaryFollowingPoint.p2PointBefore = self.p2PointBefore;
        }
        else if(self.winner == SecondPlayerId){
            temporaryFollowingPoint.p2PointBefore = [self addingOnePointFrom:self.p2PointBefore and:self.p1PointBefore];
            if(self.p1PointBefore == 50)
                temporaryFollowingPoint.p1PointBefore = 40;
            else
                temporaryFollowingPoint.p1PointBefore = self.p1PointBefore;
        }
    }
    return temporaryFollowingPoint;
}

-(void)incrementMatchCounters{
    
    [self[@"match"] incrementKey:@"pointsCount"];

    NSString *keyToIncrementWinner;
    NSString *keyToIncrementService;
    
    if(self.winner == FirstPlayerId){
        keyToIncrementWinner = @"WinP1";
    }
    else if(self.winner == SecondPlayerId){
        keyToIncrementWinner = @"WinP2";
    }
    
    switch (self.server){
        case FirstPlayerId:{
            keyToIncrementService = @"ServiceP1";
        }
            break;
        case SecondPlayerId:{
            keyToIncrementService = @"ServiceP2";
        }
            break;
    }
    
    
    switch (self.servingType){
        case ServingTypeFirstServe:{
            keyToIncrementService = [keyToIncrementService stringByAppendingString:@"1st"];
        }
            break;
        case ServingTypeSecondServe:{
            keyToIncrementService = [keyToIncrementService stringByAppendingString:@"2nd"];
        }
            break;
        case ServingTypeDoubleFault:{
            keyToIncrementService = [keyToIncrementService stringByAppendingString:@"Double"];
            
            //also increment the edingEvent
            keyToIncrementWinner = [keyToIncrementWinner stringByAppendingString:@"DoubleFault"];
        }
            break;
    }
    
    
    switch (self.endingEvent){
        case EndingEventWinnerShot:{
            keyToIncrementWinner = [keyToIncrementWinner stringByAppendingString:@"WinnerShot"];
        }
            break;
        case EndingEventUnforcedError:{
            keyToIncrementWinner = [keyToIncrementWinner stringByAppendingString:@"UnforcedError"];
        }
            break;
    }
    
    [self[@"match"] incrementKey:keyToIncrementWinner];
    [self[@"match"] incrementKey:keyToIncrementService];
}

+ (TPPoint *)startingPoint
{
    TPPoint *startingPoint = [TPPoint object];
    startingPoint.p1PointBefore = startingPoint.p2PointBefore = startingPoint.p1GameBefore = startingPoint.p2GameBefore = startingPoint.p1SetBefore = startingPoint.p2SetBefore = 0;
    
    //getting a server randomly
    startingPoint.server = rand() % 2 + 1;
    
    return startingPoint;
}


- (NSString *)readablePlayer1PointScore{
    if(self.p1PointBefore == 50)
        return @"Ad";
    return [NSString stringWithFormat:@"%d",self.p1PointBefore];
}

- (NSString *)readablePlayer2PointScore{
    if(self.p2PointBefore == 50)
        return @"Ad";
    return [NSString stringWithFormat:@"%d",self.p2PointBefore];
}

- (NSString *)audiblePlayer1PointScore{
    if(self.p1PointBefore == 50)
        return @"Avantage";
    return [NSString stringWithFormat:@"%d",self.p1PointBefore];
}

- (NSString *)audiblePlayer2PointScore{
    if(self.p1PointBefore == 50)
        return @"Avantage";
    return [NSString stringWithFormat:@"%d",self.p2PointBefore];
}

@end
