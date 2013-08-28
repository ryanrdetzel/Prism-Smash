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
@end

@implementation PSBlock

-(id)initWithGameBoard:(PSGameBoard *)gameBoard row:(int)row col:(int)col color:(NSString *)color{
    self = [super initWithColor:[SKColor grayColor] size:CGSizeMake(kBlockWidth, kBlockHeight)];
    
    self.position = CGPointMake(kBlockWidth / 2 + kStartX + (col * kBlockWidth),
                                kBlockHeight / 2 + kStartY + (row * kBlockHeight));
    
    self.colorName = color;
    self.gameBoard = gameBoard;
    self.removing = NO;
    
    self.texture = [SKTexture textureWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-block.png", color]]];
    
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

-(void)updateRow:(int)row col:(int)col{
    self.row = row;
    self.col = col;
    self.name = [NSString stringWithFormat:@"%dx%d", row, col];
}

-(void)remove{
    self.removing = YES;
    
    SKAction *shrink = [SKAction fadeAlphaTo:0 duration:0.4];
    [self runAction:shrink completion:^(){
        [self removeFromParent];
    }];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%d,%d %@", self.row, self.col, self.colorName];
}

@end
