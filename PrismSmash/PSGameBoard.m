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
@property (nonatomic, strong) PSBlock *selectedBlock;
@property (nonatomic) BOOL swapAllowed;

@end

@implementation PSGameBoard

-(id)init{
    self = [super init];
    
    self.gameScene = (PSGameScene *)self.scene;
    self.gameIsActive = NO;
    self.swapAllowed = YES;
    
    self.userInteractionEnabled = YES;
    
    return self;
}

-(BOOL)loadLevel:(NSDictionary *)levelData{
    /* Loads the level data into the gameboard */
    
    for (NSInteger col=0;col<kNumberOfCols;col++){
        for (NSInteger row=0;row<kNumberOfRows;row++){
            NSArray *colors = @[@"red", @"blue", @"purple", @"yellow", @"orange", @"green"];
            [self addBlockWithColor:[colors objectAtIndex:arc4random() % [colors count]] row:row col:col];
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


-(BOOL)swapBlock:(PSBlock *)block1 withBlock:(PSBlock *)block2 isReversing:(BOOL)reversing{
    
    /*
     Attempts to swap the blocks. If you're allowed to swap them return YES otherwise NO.
     If we swap and no new matches are found we swap the blocks back
     */
    
    if ([block1 isAdjacentToBlock:block2]){
        self.swapAllowed = NO;
        
        SKAction *move1 = [SKAction moveTo:block2.position duration:kBlockSwapDuration];
        SKAction *move2 = [SKAction moveTo:block1.position duration:kBlockSwapDuration];
        
        [block1 runAction:move1];
        [block2 runAction:move2];
        
        /* Have to set their positions so the call to findSequences works correctly */
        NSInteger row = block1.row;
        NSInteger col = block1.col;
        
        [block1 updateRow:block2.row col:block2.col];
        [block2 updateRow:row col:col];
        
        // We want the swap animation to finish before checking if there is a match.
        
        SKAction *doneAction = [SKAction waitForDuration:kBlockSwapDuration + 0.1];
        [self runAction:doneAction completion:^(){
            self.swapAllowed = YES;
            // If we're reversing a swap don't bother checking for a match
            if (reversing == NO){
                //Check for a match after they have completed their animation
                [self swapBlock:block2 withBlock:block1 isReversing:YES];
            }
        }];
        
        return YES;
    }
    return NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *aTouch = [touches anyObject];
    CGPoint point = [aTouch locationInNode:self];
    
    for (SKNode *node in [self nodesAtPoint:point]){
        if ([node isKindOfClass:[PSBlock class]]){
            self.selectedBlock = (PSBlock *)node;
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.swapAllowed) return;
    
    UITouch *aTouch = [touches anyObject];
    CGPoint point = [aTouch locationInNode:self];
    
    for (SKNode *node in [self nodesAtPoint:point]){
        if ([node isKindOfClass:[PSBlock class]]){
            if ((PSBlock *)node != self.selectedBlock){
                [self swapBlock:self.selectedBlock withBlock:(PSBlock *)node isReversing:NO];
                break;
            }
        }
    }
}

@end
