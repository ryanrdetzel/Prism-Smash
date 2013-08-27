//
//  PSViewController.m
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import "PSViewController.h"
#import "PSGameScene.h"
#import "PSGameOverScene.h"

@interface PSViewController()
@property (nonatomic, strong) PSGameScene *gameScene;
@property (nonatomic, strong) PSGameOverScene *gameOverScene;
@end

@implementation PSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    SKView * skView = (SKView *)self.view;
    
    // Create and configure the scene.
    self.gameScene = [PSGameScene sceneWithSize:skView.bounds.size];
    self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
    self.gameScene.viewController = self;
    
    [skView presentScene:self.gameScene];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)loadView {
    /* Since we don't have a storyboard */
    self.view = [[SKView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}

@end
