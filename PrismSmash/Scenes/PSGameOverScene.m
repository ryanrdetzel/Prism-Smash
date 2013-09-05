//
//  PSGameOverScene.m
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import "PSGameOverScene.h"
#import "PSGameConstants.h"

@interface PSGameOverScene()
@property (nonatomic, weak) SKLabelNode *gameOverLabel;
@property (nonatomic, strong) SKAction *gameOverSound;
@end

@implementation PSGameOverScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];
        self.userInteractionEnabled = YES;
        
        self.gameOverSound = [SKAction playSoundFileNamed:@"levelOver.caf" waitForCompletion:NO];
        
        [self addChild:self.gameOverLabel];
        [self addChild:self.reasonLabel];
    }
    return self;
}

-(void)didMoveToView:(SKView *)view{
    [self runAction:self.gameOverSound];
}

-(SKLabelNode *)gameOverLabel{
    if (!_gameOverLabel){
        _gameOverLabel = [SKLabelNode labelNodeWithFontNamed:kFont1];
        _gameOverLabel.text = @"Game Over";
        _gameOverLabel.position = CGPointMake(self.frame.size.width / 2,
                                              self.frame.size.height / 2);
    }
    return _gameOverLabel;
}

-(SKLabelNode *)reasonLabel{
    if (!_reasonLabel){
        _reasonLabel = [SKLabelNode labelNodeWithFontNamed:kFont1];
        _reasonLabel.fontSize = 16;
        CGPoint position = self.gameOverLabel.position;
        position.y -= 30;
        _reasonLabel.position = position;
    }
    return _reasonLabel;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.viewController showGameScene];
}

@end
