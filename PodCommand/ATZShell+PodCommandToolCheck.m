//
//  ATZShell+PodCommandToolCheck.m
//  PodCommand
//
//  Created by kazaana_developer on 5/22/13.
//  Copyright (c) 2013 kinwah. All rights reserved.
//

#import "ATZShell+PodCommandToolCheck.h"

@implementation ATZShell (PodCommandToolCheck)
+ (BOOL)areCommandLineToolsAvailableFor:(NSString*)toolPath {
    BOOL areAvailable = YES;
    @try {
        [NSTask launchedTaskWithLaunchPath:toolPath arguments:@[]];
    }
    @catch (NSException *exception) {
        areAvailable = NO;
    }
    return areAvailable;
}
@end
