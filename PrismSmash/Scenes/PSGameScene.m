//
//  PSGameScene.m
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import "PSGameScene.h"
#import "PSGameBoard.h"

@interface PSGameScene()
@property (nonatomic, strong) PSGameBoard *gameBoard;
@end

@implementation PSGameScene

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        background.position = CGPointMake(160, 284);
        [self addChild:background];
        
        self.gameBoard = [[PSGameBoard alloc] init];
        
        [self addChild:self.gameBoard];
        
        [self.gameBoard loadLevel:@{}];
        
        //We need to add the blocks first so we get an accurate size of the gameboard
        self.gameBoard.position = CGPointMake(
                                              (self.calculateAccumulatedFrame.size.width -self.gameBoard.calculateAccumulatedFrame.size.width) / 2,
                                              (self.calculateAccumulatedFrame.size.height -self.gameBoard.calculateAccumulatedFrame.size.height) / 2);
    }
    return self;
}

@end
