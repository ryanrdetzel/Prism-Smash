//
//  PSGameBoard.m
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import "PSGameBoard.h"
#import "PSGameScene.h"
#import "PSBlock.h"
#import "PSGameConstants.h"

@interface PSGameBoard()
@property (nonatomic, strong) PSGameScene *gameScene;
@property (nonatomic) BOOL gameIsActive;

@property (nonatomic, strong) NSMutableArray *blocks;
@end

@implementation PSGameBoard

-(id)init{
    self = [super init];
    
    self.gameScene = (PSGameScene *)self.scene;
    self.gameIsActive = NO;
    
    self.userInteractionEnabled = YES;
    
    return self;
}

-(BOOL)loadLevel:(NSDictionary *)levelData{
    /* Loads the level data into the gameboard */
    
    for (NSInteger col=0;col<kNumberOfCols;col++){
        for (NSInteger row=0;row<kNumberOfRows;row++){
            [self addBlockWithColor:@"red" row:row col:col];
        }
    }

    return NO;
}

-(PSBlock *)addBlockWithColor:(NSString *)colorName row:(int)row col:(int)col{
    PSBlock *block = [[PSBlock alloc] initWithGameBoard:self row:row col:col color:colorName];
    
    [self.blocks addObject:block];
    [self addChild:block];
    
    return block;
}

@end
