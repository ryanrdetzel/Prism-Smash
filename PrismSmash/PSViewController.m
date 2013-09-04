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
@property (nonatomic, strong) NSMutableArray *levelData;
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
    
    //Lets load our first level into the scene/board
    [self.gameScene loadLevel:[self.levelData objectAtIndex:1]];
    
    [skView presentScene:self.gameScene];
}

-(PSGameOverScene *)gameOverScene{
    if (!_gameOverScene){
        _gameOverScene = [PSGameOverScene sceneWithSize:self.view.bounds.size];
        _gameOverScene.viewController = self;
        _gameOverScene.scaleMode = SKSceneScaleModeAspectFill;
    }
    return _gameOverScene;
}

-(void)updateLevelAccomplishments:(NSMutableDictionary *)levelData{
    //Get the information about this level like stars earned and high score and update the level data
}

-(NSMutableArray *)levelData{
    /* Get all of the Level files from the bundle and use those to build out level array */
    if (!_levelData){
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSError *error;
        NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:&error];
        
        NSMutableArray *levels = [[NSMutableArray alloc] init];
        for (NSString *file in directoryContents){
            if ([file rangeOfString:@"Level"].location != NSNotFound) {
                NSString *filePath = [[NSBundle mainBundle] pathForResource:[file stringByReplacingOccurrencesOfString:@".plist" withString:@""] ofType:@"plist"];
                NSMutableDictionary *levelData = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
                
                [self updateLevelAccomplishments:levelData];
                
                [levels addObject:levelData];
            }
        }
        
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"levelNumber" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        _levelData = [[NSMutableArray alloc] initWithArray:[levels sortedArrayUsingDescriptors:sortDescriptors]];
    }
    return _levelData;
}

-(void)showGameScene{
    SKView * skView = (SKView *)self.view;

    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:1];
    [skView presentScene:self.gameScene transition:doors];
}

-(void)showGameOverScene:(NSString *)reason{
    SKView * skView = (SKView *)self.view;

    SKTransition *doors = [SKTransition doorsCloseVerticalWithDuration:1];
    [skView presentScene:self.gameOverScene transition:doors];
    self.gameOverScene.reasonLabel.text = reason;
}

- (BOOL)shouldAutorotate{
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
