//
//  PSGameOverScene.h
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PSViewController.h"

@interface PSGameOverScene : SKScene
@property (nonatomic, strong) PSViewController *viewController;
@property (nonatomic, strong) SKLabelNode *reasonLabel;
@end
