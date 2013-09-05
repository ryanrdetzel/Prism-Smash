//
//  PSAppDelegate.m
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import "PSAppDelegate.h"
#import "PSViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation PSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[PSViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    AVAudioSession* session = [AVAudioSession sharedInstance];
    BOOL otherAudioIsPlaying = session.otherAudioPlaying;
    
    if (otherAudioIsPlaying) {
        [session setCategory: AVAudioSessionCategoryAmbient error: nil];
    } else {
        [session setCategory: AVAudioSessionCategorySoloAmbient error: nil];
    }
    
    return YES;
}

@end
