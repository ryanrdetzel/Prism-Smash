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
@property (nonatomic, readonly) PSGameScene *gameScene;
@property (nonatomic) BOOL gameIsActive;

@property (nonatomic, strong) NSMutableArray *blocks;
@property (nonatomic, strong) PSBlock *selectedBlock;
@property (nonatomic) BOOL swapAllowed;

@property (nonatomic, strong) NSString *levelName;

@property (nonatomic) NSInteger sequenceRun;
@property (nonatomic) NSInteger score;

@property (nonatomic) NSInteger movesPerformed;
@property (nonatomic) NSInteger movesAllowed;

@property (nonatomic) NSInteger targetScore1;
@property (nonatomic) NSInteger targetScore2;
@property (nonatomic) NSInteger targetScore3;

@property (nonatomic, strong) SKAction *blockFallSound;
@property (nonatomic, strong) SKAction *sequence0Sound;
@property (nonatomic, strong) SKAction *sequence1Sound;
@property (nonatomic, strong) SKAction *sequence2Sound;
@property (nonatomic, strong) SKAction *sequence3Sound;
@property (nonatomic, strong) SKAction *sequence4Sound;
@property (nonatomic, strong) SKAction *sequence5Sound;

@end

@implementation PSGameBoard

-(id)init{
    self = [super init];
    
    self.gameIsActive = NO;
    self.swapAllowed = YES;
    self.sequenceRun = 0;
    self.score = 0;
    self.movesAllowed = 0;
    self.movesPerformed = 0;
    
    self.blockFallSound = [SKAction playSoundFileNamed:@"blockFall.caf" waitForCompletion:NO];
    
    self.sequence0Sound = [SKAction playSoundFileNamed:@"sequence0.caf" waitForCompletion:NO];
    self.sequence1Sound = [SKAction playSoundFileNamed:@"sequence1.caf" waitForCompletion:NO];
    self.sequence2Sound = [SKAction playSoundFileNamed:@"sequence2.caf" waitForCompletion:NO];
    self.sequence3Sound = [SKAction playSoundFileNamed:@"sequence3.caf" waitForCompletion:NO];
    self.sequence4Sound = [SKAction playSoundFileNamed:@"sequence4.caf" waitForCompletion:NO];
    self.sequence5Sound = [SKAction playSoundFileNamed:@"sequence5.caf" waitForCompletion:NO];

    self.userInteractionEnabled = YES;
    
    return self;
}

-(PSGameScene *)gameScene{
    return (PSGameScene *)self.scene;
}

-(NSString *)levelName{
    if (!_levelName) _levelName = @"";
    return _levelName;
}

-(void)setMovesPerformed:(NSInteger)movesPerformed{
    _movesPerformed = movesPerformed;
    [self.gameScene updateMovesLeft:self.movesAllowed - _movesPerformed];
}

-(void)setScore:(NSInteger)newScore{
    _score = newScore;
    float percent = (((float)newScore / self.targetScore3) * 100);
    [self.gameScene updateScore:newScore percentComplete:percent];
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
    self.sequenceRun = 0;
    self.score = 0;
    self.movesAllowed = 0;
    self.movesPerformed = 0;
}


-(BOOL)loadLevel:(NSDictionary *)levelData{
    /* Loads the level data into the gameboard */
    
    [self clearLevel];
    
    self.movesAllowed = [[levelData objectForKey:@"movesAllowed"] integerValue];
    self.targetScore1 = [[levelData objectForKey:@"targetScore1"] integerValue];
    self.targetScore2 = [[levelData objectForKey:@"targetScore2"] integerValue];
    self.targetScore3 = [[levelData objectForKey:@"targetScore3"] integerValue];
    self.levelName = [levelData objectForKey:@"name"];
    
    self.movesPerformed = 0;

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
    
    float fallOffset = 0.01;
    
    for (PSBlock *block in [self.blocks sortedArrayUsingSelector:@selector(compare:)]){
        if (block.moveDownBy > 0){
            SKAction *moveDown = [SKAction moveByX:0.0 y:-block.moveDownBy
                                          duration:kFallDuration + fallOffset];
            
            [block runAction:moveDown completion:^(){
                NSInteger new_row = [self calcRow:block];
                [block updateRow:new_row col:block.col];
                [self runAction:self.blockFallSound];
            }];
            fallOffset += 0.01;
            block.moveDownBy = 0; //Make sure we reset this
        }
    }
    
    /* Wait for all the blocks to fall into place and check for combos again */
    SKAction *doneAction = [SKAction waitForDuration:kFallDuration + 0.1 + fallOffset];
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
                    self.movesPerformed++;
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
                [self scoreRun:currentRun];
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
                [self scoreRun:currentRun];
            }
        }
    }
    
    if ([blocksToRemove count] == 0){
        /* Turn user interaction back on */
        self.swapAllowed = YES;
        self.sequenceRun = 0;
        
        [self checkGameStatus];
    }else{
        [self removeBlocks:[blocksToRemove allObjects]];
        self.swapAllowed = NO;
    }
    return [blocksToRemove count];
}

-(void)saveGameScore{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userLevelData = [[NSMutableDictionary alloc] initWithDictionary:[defaults dictionaryForKey:self.levelName]];
    
    if (userLevelData == nil){
        userLevelData = [[NSMutableDictionary alloc] init];
    }
    
    NSNumber *previousStarsCollected = [userLevelData objectForKey:@"starsCollected"];
    NSNumber *highScore = [userLevelData objectForKey:@"highScore"];
    
    NSInteger starsCollected = 0;
    
    if (previousStarsCollected == nil){
        previousStarsCollected = @0;
    }
    if (highScore == nil){
        highScore = @0;
    }
    
    if (self.score >= self.targetScore3){
        starsCollected = 3;
    }
    else if (self.score >= self.targetScore2){
        starsCollected = 2;
    }
    else if (self.score >= self.targetScore1){
        starsCollected = 1;
    }
    
    if (starsCollected > [previousStarsCollected integerValue]){
        [userLevelData setObject:[NSNumber numberWithInt:starsCollected] forKey:@"starsCollected"];
    }
    if (self.score > [highScore integerValue]){
        [userLevelData setObject:[NSNumber numberWithInt:self.score] forKey:@"highScore"];
    }
    
    [defaults setObject:userLevelData forKey:self.levelName];
    [defaults synchronize];

}

-(void)gameOverWithReason:(NSString *)reason{
    self.gameIsActive = NO;
    self.swapAllowed = NO;
    
    [self saveGameScore];
    [self.gameScene showGameOverSceneWithReason:reason];
}

-(void)checkGameStatus{
    if (self.movesPerformed >= self.movesAllowed){
        [self gameOverWithReason:@"Your ran out of moves"];
    }
}

-(CGPoint)findCenterPoint:(NSArray *)blocks{
    /* Assuming they're in a line get the average position which is the center */
    NSInteger x = 0, y = 0;
    for (PSBlock *block in blocks){
        x += block.position.x;
        y += block.position.y;
    }
    
    return CGPointMake(x / [blocks count], y / [blocks count]);
}

-(void)scoreRun:(NSMutableArray *)currentRunBlocks{
    /* Based off the run calculate the score */
    
    NSInteger multiplier = 1;
    NSInteger pointsScoredFromRun = 0;
    
    if ([currentRunBlocks count] == 4){
        multiplier = kRunFourMultiplier;
        [self runAction:self.sequence5Sound];
    }else if ([currentRunBlocks count] == 5){
        multiplier = kRunFiveMultiplier;
        [self runAction:self.sequence5Sound];
    }else{
        if (self.sequenceRun == 0){
            [self runAction:self.sequence0Sound];
        }else if (self.sequenceRun == 1){
            [self runAction:self.sequence1Sound];
        }else if (self.sequenceRun == 2){
            [self runAction:self.sequence2Sound];
        }else if (self.sequenceRun == 3){
            [self runAction:self.sequence3Sound];
        }else if (self.sequenceRun == 4){
            [self runAction:self.sequence4Sound];
        }else{
            [self runAction:self.sequence5Sound];
        }
    }
    
    for (PSBlock *block in currentRunBlocks){
        pointsScoredFromRun += block.pointsEarned;
    }
    
    pointsScoredFromRun *= (multiplier + self.sequenceRun);
    self.score += pointsScoredFromRun;
    
    [self displayPoints:pointsScoredFromRun at:[self findCenterPoint:currentRunBlocks]];
    
    self.sequenceRun++;
}

-(void)displayPoints:(NSInteger)value at:(CGPoint)position{
    /*
     When points are awarded we need to display them to the users so they can see that
     */
    
    SKLabelNode *points = [[SKLabelNode alloc] initWithFontNamed:kFont1];
    
    // Format them correctly with a comma for thousands
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:value]];
    
    points.text = formatted;
    points.fontSize = 24;
    points.zPosition = 3; // show them on top of all other layers
    points.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    points.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    points.fontColor = [SKColor whiteColor];
    points.name = @"points";
    
    // We want the points on the scene not on the board so we have to convert the point
    [self.scene addChild:points];
    CGPoint p = [self convertPoint:position toNode:points.parent];
    
    points.position = p;
    
    SKAction *moveUp = [SKAction moveByX:0 y:30 duration:kPointsDisplayDuration];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:kPointsDisplayDuration];
    SKAction *enlarge = [SKAction scaleBy:1.5 duration:kPointsDisplayDuration];
    
    SKAction *sq = [SKAction group:@[moveUp, fadeOut, enlarge]];
    
    [points runAction:sq completion:^(){
        [points removeFromParent];
    }];
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
