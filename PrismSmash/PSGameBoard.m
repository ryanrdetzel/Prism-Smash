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

@property (nonatomic) NSInteger sequenceRun;

@end

@implementation PSGameBoard

-(id)init{
    self = [super init];
    
    self.gameScene = (PSGameScene *)self.scene;
    self.gameIsActive = NO;
    self.swapAllowed = YES;
    self.sequenceRun = 0;
    
    self.userInteractionEnabled = YES;
    
    return self;
}

-(NSMutableArray *)blocks{
    if (!_blocks) _blocks = [[NSMutableArray alloc] init];
    return _blocks;
}

-(void)clearLevel{
    /* Removes all blocks from the level and reset everything back to it's initial state*/
    
    [self removeAllChildren];
    [self.blocks removeAllObjects];
    
    self.gameIsActive = NO;
    self.swapAllowed = NO;
}


-(BOOL)loadLevel:(NSDictionary *)levelData{
    /* Loads the level data into the gameboard */
    
    [self clearLevel];
    
    NSArray *blocks = [levelData objectForKey:@"blocks"];
    
    for (NSInteger blockNumber=0;blockNumber<[blocks count];blockNumber++){
        // Since the blocks is just an array we need to calculate the row/col
        NSInteger row = blockNumber / kNumberOfRows;
        NSInteger col = blockNumber % kNumberOfRows;
        
        NSString *colorName = [blocks objectAtIndex:blockNumber];
        
        PSBlock *block = [self addBlockWithColor:colorName row:row col:col];
    }
    self.gameIsActive = YES;

    // In a properly designed level we shouldn't need this check.
    [self findSequences];
    
    return [self.blocks count];
}

-(PSBlock *)addBlockWithColor:(NSString *)colorName row:(int)row col:(int)col{
    PSBlock *block = [[PSBlock alloc] initWithGameBoard:self row:row col:col color:colorName];
    
    [self.blocks addObject:block];
    [self addChild:block];
    
    return block;
}

-(NSArray *)blocksAboveBlock:(PSBlock *)block{
    /*
     When we remove a block we need all of the blocks above the block being removed
     so we have this helper function to get all of those blocks for us
     */
    NSMutableArray *blocks = [[NSMutableArray alloc] init];
    
    for (PSBlock *_block in self.blocks){
        if (block.col == _block.col){
            if (_block.row > block.row){
                [blocks addObject:_block];
            }
        }
    }
    return blocks;
}

-(int)calcRow:(PSBlock *)block{
    /* Calculate the blocks new row based off it's current position */
    NSInteger blockY = block.position.y - kStartY;
    return blockY / kBlockHeight;
}

-(PSBlock *)blockAtRow:(int)row col:(int)col{
    NSString *name = [NSString stringWithFormat:@"%dx%d", row, col];
    PSBlock *block = (PSBlock *)[self childNodeWithName:name];
    return block;
}

-(void)addReplacmentBlocks:(NSArray *)blocks{
    /* For each block that's passed in replace it with a new block and add it to the top of the stack */
    
    for (PSBlock *block in blocks){
        NSInteger row = 0;
        NSInteger col = block.col;
        
        /* Since multiple blocks can be removed we have to find the first empty spot for this block. Start
         at the bottom and keep checking up until we find a spot for it */
        while ([self blockAtRow:row col:col]){
            row++;
        }
        
        NSArray *colors = @[@"red", @"blue", @"purple", @"yellow", @"orange", @"green"];
        [self addBlockWithColor:[colors objectAtIndex:arc4random() % [colors count]] row:row col:col];
    }
}

-(BOOL)removeBlock:(PSBlock *)block{
    /* Called for each block that is removed from the game */
    
    if (block.isBeingRemoved){
        return NO;
    }
    
    [block remove];
    
    [self.blocks removeObject:block];
    
    //Each block above this block needs to move down to fill the gap
    for (PSBlock *_block in [self blocksAboveBlock:block]){
        _block.moveDownBy += kBlockHeight;
    }
    
    return YES;
}

-(void)removeBlocks:(NSArray *)blocks{
    /* Mass remove blocks. This is called after a findSequences call */
    
    if (blocks == nil || [blocks count] == 0) return;
    
    [self addReplacmentBlocks:blocks];
    
    NSArray *sortedBlocks = [blocks sortedArrayUsingSelector:@selector(compare:)];
    
    for (PSBlock *block in sortedBlocks){
        [self removeBlock:block];
    }
    
    for (PSBlock *block in [self.blocks sortedArrayUsingSelector:@selector(compare:)]){
        if (block.moveDownBy > 0){
            SKAction *moveDown = [SKAction moveByX:0.0 y:-block.moveDownBy
                                          duration:kFallDuration];
            
            [block runAction:moveDown completion:^(){
                NSInteger new_row = [self calcRow:block];
                [block updateRow:new_row col:block.col];
            }];
            
            block.moveDownBy = 0; //Make sure we reset this
        }
    }
    
    /* Wait for all the blocks to fall into place and check for combos again */
    SKAction *doneAction = [SKAction waitForDuration:kFallDuration + 0.1];
    [self runAction:doneAction completion:^(){
        [self findSequences];
    }];
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
            // If we're reversing a swap don't bother checking for a match. If we didn't have this
            // The blocks would just continue to swap back and forth.
            if (reversing == NO){
                if ([self findSequences]){
                    //A swap was successull; it resulted in matche(s)
                    // Score? Subtract from moves?
                }else{
                    // No matches so swap the blocks back
                    [self swapBlock:block2 withBlock:block1 isReversing:YES];
                }
            }
        }];
        
        return YES;
    }
    return NO;
}

-(BOOL)findSequences{
    /*
     Check for blocks that make a sequence, 3, 4 or 5 same colors in a row and returns
     YES if any blocks matched and were removed.
     */
    
    if (!self.gameIsActive) return NO;
    
    NSMutableArray *currentRun = [[NSMutableArray alloc] init];
    NSMutableSet *blocksToRemove = [[NSMutableSet alloc] init];
    
    NSMutableSet *partOfHorizonalSequence = [[NSMutableSet alloc] init];
    NSMutableSet *partOfVerticalSequence = [[NSMutableSet alloc] init];
    
    for (PSBlock *block in [self.blocks sortedArrayUsingSelector:@selector(compare:)]){
        NSInteger row = block.row;
        NSInteger col = block.col;
        
        if ([partOfHorizonalSequence containsObject:block] == NO){
            
            NSInteger currentColumn = col + 1;
            
            [currentRun removeAllObjects];
            [currentRun addObject:block];
            
            while (currentColumn < kNumberOfCols){
                PSBlock *nextBlock = [self blockAtRow:row col:currentColumn];
                if ([block doesMatchBlock:nextBlock]){
                    [currentRun addObject:nextBlock];
                }else{
                    break;
                }
                currentColumn++;
            }
            
            if ([currentRun count] >= 3){
                [partOfHorizonalSequence addObjectsFromArray:currentRun];
                [blocksToRemove addObjectsFromArray:currentRun];
            }
        }
        
        if ([partOfVerticalSequence containsObject:block] == NO){
            
            /* Now check the column */
            NSInteger currentRow = row + 1; //start checking with the next row
            
            [currentRun removeAllObjects];
            [currentRun addObject:block];
            
            while (currentRow < kNumberOfRows){
                PSBlock *_block = [self blockAtRow:currentRow col:col];
                if ([block doesMatchBlock:_block]){
                    [currentRun addObject:_block];
                }else{
                    break;
                }
                currentRow++;
            }
            
            if ([currentRun count] >= 3){
                [partOfVerticalSequence addObjectsFromArray:currentRun];
                [blocksToRemove addObjectsFromArray:currentRun];
            }
        }
    }
    
    if ([blocksToRemove count] == 0){
        /* Turn user interaction back on */
        self.swapAllowed = YES;
        self.sequenceRun = 0;
    }else{
        [self removeBlocks:[blocksToRemove allObjects]];
        self.swapAllowed = NO;
    }
    return [blocksToRemove count];
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
