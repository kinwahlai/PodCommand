//
//  ATZShell+PodCommandToolCheck.h
//  PodCommand
//
//  Created by kazaana_developer on 5/22/13.
//  Copyright (c) 2013 kinwah. All rights reserved.
//

#import "ATZShell.h"

@interface ATZShell (PodCommandToolCheck)
+ (BOOL)areCommandLineToolsAvailableFor:(NSString*)toolPath;
@end
