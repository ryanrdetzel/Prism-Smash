//
//  PSBlock.m
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import "PSBlock.h"
#import "PSGameConstants.h"

@interface PSBlock()
@property (nonatomic, strong) PSGameBoard *gameBoard;
@property (nonatomic, readwrite) NSInteger row;
@property (nonatomic, readwrite) NSInteger col;
@property (nonatomic, readwrite) BOOL removing;
@property (nonatomic, readwrite) NSInteger pointsEarned;
@end

@implementation PSBlock

-(id)initWithGameBoard:(PSGameBoard *)gameBoard row:(int)row col:(int)col color:(NSString *)color{
    self = [super initWithColor:[SKColor grayColor] size:CGSizeMake(kBlockWidth, kBlockHeight)];
    
    self.position = CGPointMake(kBlockWidth / 2 + kStartX + (col * kBlockWidth),
                                kBlockHeight / 2 + kStartY + (row * kBlockHeight));
    
    self.colorName = color;
    self.gameBoard = gameBoard;
    self.removing = NO;
    self.moveDownBy = 0;
    self.pointsEarned = 50;
    self.possibleMove = NO;
    
    self.texture = [SKTexture textureWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-block", color]]];
    
    [self updateRow:row col:col];
    
    return self;
}

-(BOOL)isAdjacentToBlock:(PSBlock *)block{
    /* Returns YES if the block is adjacent to the block passed in. */
    if (self == block) return NO;
    
    NSInteger row1 = self.row;
    NSInteger col1 = self.col;
    
    NSInteger row2 = block.row;
    NSInteger col2 = block.col;
    
    if (row1 == row2){
        if (col2+1 == col1 || col2-1 == col1){
            return YES;
        }
    }
    if (col1 == col2){
        if (row2 + 1 == row1 || row2 - 1 == row1){
            return YES;
        }
    }
    return NO;
}

-(BOOL)doesMatchBlock:(PSBlock *)block1 andBlock:(PSBlock *)block2{
    return ([self doesMatchBlock:block1] && [self doesMatchBlock:block2]);
}

-(BOOL)doesMatchBlock:(PSBlock *)block{
    return [self.colorName isEqualToString:block.colorName];
}

-(void)updateRow:(int)row col:(int)col{
    self.row = row;
    self.col = col;
    self.name = [NSString stringWithFormat:@"%dx%d", row, col];
}

-(void)remove{
    self.removing = YES;
    self.name = @"removing";
    
    SKAction *shrink = [SKAction fadeAlphaTo:0 duration:0.4];
    [self runAction:shrink completion:^(){
        [self removeFromParent];
    }];
}

-(NSComparisonResult)compare:(PSBlock *)block1{
    
    NSInteger num1 = (block1.row * 10) + block1.col;
    NSInteger num2 = (self.row * 10) + self.col;
    
    if (num1 > num2){
        return NSOrderedAscending;
    }
    else if (num2 > num1){
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%d,%d %@", self.row, self.col, self.colorName];
}

@end
