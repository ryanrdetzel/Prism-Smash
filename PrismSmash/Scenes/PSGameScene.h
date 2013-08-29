//
//  PSGameScene.h
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PSViewController.h"

@interface PSGameScene : SKScene

@property (nonatomic, strong) PSViewController *viewController;

-(void)loadLevel:(NSDictionary *)levelData;
-(void)updateMovesLeft:(NSInteger)movesLeft;
-(void)updateScore:(NSInteger)newScore percentComplete:(NSInteger)percent;

@end
