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
@end

@implementation PSBlock

-(id)initWithGameBoard:(PSGameBoard *)gameBoard row:(int)row col:(int)col color:(NSString *)color{
    self = [super initWithColor:[SKColor grayColor] size:CGSizeMake(kBlockWidth, kBlockHeight)];
    
    self.position = CGPointMake(kBlockWidth / 2 + kStartX + (col * kBlockWidth),
                                kBlockHeight / 2 + kStartY + (row * kBlockHeight));
    
    self.colorName = color;
    self.gameBoard = gameBoard;
    
    self.texture = [SKTexture textureWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-block.png", color]]];
    
    [self updateRow:row col:col];
    
    return self;
}

-(void)updateRow:(int)row col:(int)col{
    self.row = row;
    self.col = col;
    self.name = [NSString stringWithFormat:@"%dx%d", row, col];
}

-(void)remove{
    // Add some animation or something when the block is removed.
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%d,%d %@", self.row, self.col, self.colorName];
}

@end
