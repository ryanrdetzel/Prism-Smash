//
//  PSGameConstants.m
//  PrismSmash
//
//  Created by Ryan Detzel on 8/27/13.
//  Copyright (c) 2013 Ryan Detzel. All rights reserved.
//

#import "PSGameConstants.h"

/* Based off the block images */
NSInteger const kBlockWidth = 34;
NSInteger const kBlockHeight = 30;

NSInteger const kStartX = 0;
NSInteger const kStartY = 0;

NSInteger const kNumberOfRows = 9;
NSInteger const kNumberOfCols = 9;

float const kGameBoardWidth = kNumberOfCols * kBlockWidth;
float const kGameBoardHeight = kNumberOfRows * kBlockHeight;

float const kBlockSwapDuration = 0.15;
float const kFallDuration = 0.2;

float const kEarnedStarAlpha = 0.2;

NSString * const kFont1 = @"Arial-BoldMT";
NSString * const kFont2 = @"ArialMT";