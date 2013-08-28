//
//  PSBlock.h
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PSGameBoard.h"

@interface PSBlock : SKSpriteNode

@property (nonatomic, readonly) NSInteger row;
@property (nonatomic, readonly) NSInteger col;
@property (nonatomic, strong) NSString *colorName;

-(id)initWithGameBoard:(PSGameBoard *)gameBoard row:(int)row col:(int)col color:(NSString *)color;

-(void)updateRow:(int)row col:(int)col;
-(void)remove;

@end
