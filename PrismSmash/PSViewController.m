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
#import "PSGameConstants.h"

@interface PSViewController()
@property (nonatomic, strong) PSGameScene *gameScene;
@property (nonatomic, strong) PSGameOverScene *gameOverScene;
@property (nonatomic, strong) NSMutableArray *levelData;

@property (nonatomic, weak) UIButton *levelsButton;
@property (nonatomic, strong) UITableView *levelSelectTableView;
@property (nonatomic) NSInteger currentLevel;
@end

@implementation PSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.levelsButton];
    [self.view addSubview:self.levelSelectTableView];

    SKView * skView = (SKView *)self.view;
    
    // Create and configure the scene.
    self.gameScene = [PSGameScene sceneWithSize:skView.bounds.size];
    self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
    self.gameScene.viewController = self;
    
    //Lets load our first level into the scene/board
    [skView presentScene:self.gameScene];
}

-(void)viewDidAppear:(BOOL)animated{
    [self showLevelMenu];
}

-(UIButton *)levelsButton{
    if (!_levelsButton){
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        self.levelsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.levelsButton.frame = CGRectMake(148, screenBounds.size.height - 40, 25, 25);
        [self.levelsButton setImage:[UIImage imageNamed:@"home"] forState:UIControlStateNormal];
        [self.levelsButton addTarget:self action:@selector(showLevelMenu) forControlEvents:UIControlEventTouchUpInside];
    }
    return _levelsButton;
}

-(UITableView *)levelSelectTableView{
    if (!_levelSelectTableView){
        _levelSelectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320,
                                                                              self.view.frame.size.height)];
        _levelSelectTableView.backgroundColor = [UIColor blackColor];
        _levelSelectTableView.alpha = 0.85;
        _levelSelectTableView.dataSource = self;
        _levelSelectTableView.delegate = self;
        
        _levelSelectTableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    }
    
    return _levelSelectTableView;
}

-(PSGameOverScene *)gameOverScene{
    if (!_gameOverScene){
        _gameOverScene = [PSGameOverScene sceneWithSize:self.view.bounds.size];
        _gameOverScene.viewController = self;
        _gameOverScene.scaleMode = SKSceneScaleModeAspectFill;
    }
    return _gameOverScene;
}

-(void)updateLevelDataWithUserScores:(NSMutableDictionary *)levelData{
    /* Get information like stars obtained and high scores from the local storage 
       and load it into the levelData dictionary
     */
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userLevelData = [defaults objectForKey:[levelData objectForKey:@"name"]];
    NSNumber *stars = [NSNumber numberWithInt:0];
    NSNumber *highScore = [NSNumber numberWithInt:0];
    
    if (userLevelData){
        stars = [userLevelData objectForKey:@"starsCollected"];
        highScore = [userLevelData objectForKey:@"highScore"];
        if (stars == nil){
            stars = @0;
        }
        if (highScore == nil){
            highScore = @0;
        }
    }
    [levelData setObject:stars forKey:@"starsCollected"];
    [levelData setObject:highScore forKey:@"highScore"];
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
                
                [self updateLevelDataWithUserScores:levelData];
                
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
    self.levelsButton.hidden = NO;

    [self showLevelMenu];
}

-(void)showGameOverScene:(NSString *)reason{
    SKView * skView = (SKView *)self.view;

    SKTransition *doors = [SKTransition doorsCloseVerticalWithDuration:1];
    [skView presentScene:self.gameOverScene transition:doors];
    self.gameOverScene.reasonLabel.text = reason;
    self.levelsButton.hidden = YES;
    
    //Refreshes the stats for this level
    [self updateLevelDataWithUserScores:[self.levelData objectAtIndex:self.currentLevel]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.currentLevel = indexPath.row;
    [self.gameScene loadLevel:[self.levelData objectAtIndex:self.currentLevel]];
    
    [UIView animateWithDuration:0.7 animations:^{
        CGRect frame = tableView.frame;
        frame.origin.y += frame.size.height;
        tableView.frame = frame;
        self.gameScene.paused = NO;
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.levelData count];
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}

#pragma mark Level View

-(void)showLevelMenu{
    self.gameScene.paused = YES;
    [self.levelSelectTableView reloadData];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.levelSelectTableView.frame;
        frame.origin.y = 0;
        self.levelSelectTableView.frame = frame;
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *labelName;
    UIImageView *star1, *star2, *star3;
    
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.backgroundColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        labelName = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 170, 35)];
        labelName.font = [UIFont fontWithName:kFont1 size:14];
        labelName.textColor = [SKColor whiteColor];
        
        star1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star"]];
        [star1 setCenter:CGPointMake(190 + 40, labelName.center.y)];
        
        star2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star"]];
        [star2 setCenter:CGPointMake(190 + 70, labelName.center.y)];
        
        star3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star"]];
        [star3 setCenter:CGPointMake(190 + 100, labelName.center.y)];
        
        labelName.tag = 20;
        star1.tag = 21;
        star2.tag = 22;
        star3.tag = 23;
        
        [cell.contentView addSubview:labelName];
        [cell.contentView addSubview:star1];
        [cell.contentView addSubview:star2];
        [cell.contentView addSubview:star3];
        
    }else{
        labelName = (UILabel *)[cell.contentView viewWithTag:20];
        star1 = (UIImageView *)[cell.contentView viewWithTag:21];
        star2 = (UIImageView *)[cell.contentView viewWithTag:22];
        star3 = (UIImageView *)[cell.contentView viewWithTag:23];
    }
    
    labelName.text = [[self.levelData objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    NSInteger starsCollected = [[[self.levelData objectAtIndex:indexPath.row] objectForKey:@"starsCollected"] integerValue];
    
    star1.alpha = star2.alpha = star3.alpha = 0.2;
    
    if (starsCollected == 3){
        star1.alpha = star2.alpha = star3.alpha = 1;
    }else if (starsCollected == 2){
        star1.alpha = star2.alpha = 1;
    }
    else if (starsCollected == 1){
        star1.alpha = 1;
    }
    
    return cell;
}

#pragma mark View Controller Helpers

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
