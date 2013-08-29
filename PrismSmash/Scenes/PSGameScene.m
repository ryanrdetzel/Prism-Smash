//
//  PSGameScene.m
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import "PSGameScene.h"
#import "PSGameBoard.h"
#import "PSGameConstants.h"

@interface PSGameScene()
@property (nonatomic, strong) PSGameBoard *gameBoard;

@property (nonatomic, strong) SKLabelNode *levelLabel;
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, strong) SKLabelNode *movesLeftLabel;

@property (nonatomic, strong) SKSpriteNode *earnedStar1;
@property (nonatomic, strong) SKSpriteNode *earnedStar2;
@property (nonatomic, strong) SKSpriteNode *earnedStar3;

@end

@implementation PSGameScene

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        background.position = CGPointMake(160, 284);
        [self addChild:background];
        
        SKCropNode *maskNode = [[SKCropNode alloc] init];
        SKSpriteNode *gameboardMask = [[SKSpriteNode alloc] initWithImageNamed:@"gameboard-mask"];
        gameboardMask.anchorPoint = CGPointZero;
        maskNode.maskNode = gameboardMask;
        
        self.gameBoard = [[PSGameBoard alloc] init];
        
        [maskNode addChild:self.gameBoard];
        [self addChild:maskNode];
        
        [self setupInterface];
        
        // Keep these here since we rely on some things being added to the node.
        maskNode.position = CGPointMake(0,self.earnedStar1.position.y - kGameBoardHeight - 30);
        self.gameBoard.position = CGPointMake((maskNode.maskNode.calculateAccumulatedFrame.size.width-kGameBoardWidth)/2, 0);
        
    }
    return self;
}

-(void)setupInterface{
    /* Setup labels and their titles */
    SKLabelNode *scoreTitle = [SKLabelNode labelNodeWithFontNamed:kFont1];
    scoreTitle.text = @"score";
    scoreTitle.fontColor = [SKColor whiteColor];
    scoreTitle.fontSize = 14;
    scoreTitle.position = CGPointMake(280, 35);
    
    self.scoreLabel = [[SKLabelNode alloc] initWithFontNamed:kFont1];
    self.scoreLabel.fontColor = [SKColor whiteColor];
    self.scoreLabel.position = CGPointMake(280, 15);
    self.scoreLabel.text = @"0";
    self.scoreLabel.fontSize = 18;
    self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    
    SKLabelNode *movesLeftTitle = [SKLabelNode labelNodeWithFontNamed:kFont1];
    movesLeftTitle.text = @"moves";
    movesLeftTitle.fontColor = [SKColor whiteColor];
    movesLeftTitle.fontSize = 14;
    movesLeftTitle.position = CGPointMake(40, 35);
    
    self.movesLeftLabel = [[SKLabelNode alloc] initWithFontNamed:kFont1];
    self.movesLeftLabel.fontColor = [SKColor whiteColor];
    self.movesLeftLabel.fontSize = 18;
    self.movesLeftLabel.position = CGPointMake(40, 15);
    self.movesLeftLabel.text = @"0";
    self.movesLeftLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    
    self.levelLabel = [[SKLabelNode alloc] initWithFontNamed:kFont1];
    self.levelLabel.fontSize = 18;
    self.levelLabel.fontColor = [SKColor whiteColor];
    self.levelLabel.position = CGPointMake(160, 430);
    self.levelLabel.text = @"-";
    self.levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    
    [self addChild:scoreTitle];
    [self addChild:self.scoreLabel];

    [self addChild:movesLeftTitle];
    [self addChild:self.movesLeftLabel];
    
    [self addChild:self.levelLabel];
    
    /* Setup the stars */
    
    SKTexture *starTexture = [SKTexture textureWithImageNamed:@"star"];
    
    self.earnedStar2 = [SKSpriteNode spriteNodeWithTexture:starTexture];
    CGPoint pos = self.levelLabel.position;
    pos.y -= 20;
    self.earnedStar2.alpha = kEarnedStarAlpha;
    self.earnedStar2.position = pos;
    
    self.earnedStar1 = [SKSpriteNode spriteNodeWithTexture:starTexture];
    pos = self.earnedStar2.position;
    pos.x -= 35;
    self.earnedStar1.position = pos;
    self.earnedStar1.alpha = kEarnedStarAlpha;
    
    self.earnedStar3 = [SKSpriteNode spriteNodeWithTexture:starTexture];
    pos = self.earnedStar2.position;
    pos.x += 35;
    self.earnedStar3.position = pos;
    self.earnedStar3.alpha = kEarnedStarAlpha;
    
    [self addChild:self.earnedStar1];
    [self addChild:self.earnedStar2];
    [self addChild:self.earnedStar3];
}

-(void)updateMovesLeft:(NSInteger)movesLeft{
    self.movesLeftLabel.text = [NSString stringWithFormat:@"%d", movesLeft];
}

-(void)resetScene{
    // Reset any labels or graphics back to their original starting points

    self.levelLabel.text = @"-";
    self.scoreLabel.text = @"0";
    self.movesLeftLabel.text = @"0";
    
    self.earnedStar1.alpha = self.earnedStar2.alpha = self.earnedStar3.alpha = kEarnedStarAlpha;
}

-(void)loadLevel:(NSDictionary *)levelData{
    /* Setup the scene and load the leve into the gameboard */
    if ([self.gameBoard loadLevel:levelData]){
        [self resetScene];
        
        self.levelLabel.text = [levelData objectForKey:@"name"];
        [self updateMovesLeft:[[levelData objectForKey:@"movesAllowed"] integerValue]];
    }
}

@end
