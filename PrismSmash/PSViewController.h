//
//  PSViewController.h
//  PrismSmash
//

//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface PSViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

-(void)showGameOverScene:(NSString *)reason;
-(void)showGameScene;
-(void)updateLevelDataWithUserScores:(NSMutableDictionary *)levelData;

@end
