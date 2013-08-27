//
//  PSGameBoard.m
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import "PSGameBoard.h"
#import "PSGameScene.h"

@interface PSGameBoard()
@property (nonatomic, strong) PSGameScene *gameScene;
@property (nonatomic) BOOL gameIsActive;
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
    return NO;
}

@end
