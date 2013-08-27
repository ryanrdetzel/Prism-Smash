//
//  PSGameBoard.h
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class PSGameScene;

@interface PSGameBoard : SKNode

-(id)init;
-(BOOL)loadLevel:(NSDictionary *)levelData;

@end
