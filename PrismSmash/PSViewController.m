//
//  PSViewController.m
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import "PSViewController.h"
#import "PSMyScene.h"

@implementation PSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [PSMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
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
