//
//  PodCommand.m
//  PodCommand
//
//  Created by kazaana_developer on 5/13/13.
//  Copyright (c) 2013 kinwah. All rights reserved.
//

#import "PodCommand.h"

@class IDEWorkspaceWindowController;

@interface NSObject()
+ (id)workspaceWindowControllers;
+ (id)lastActiveWorkspaceWindow;
@end

@interface PodCommand ()
{
    NSURL *_podFilePath;
    NSURL *_podFileLockPath;
}
- (NSURL *)projectRoot;
@end

@implementation PodCommand


+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] init];
    });
}

- (id)init
{
    if (self = [super init]) {
        // Create menu items, initialize UI, etc.

        // Sample Menu Item:
        NSMenuItem *viewMenuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
        if (viewMenuItem) {
            [[viewMenuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenu *podCommandSubMenu = [[NSMenu alloc]initWithTitle:@""];
            
            NSMenuItem *podCommand = [[NSMenuItem alloc] initWithTitle:@"Pod Command" action:nil keyEquivalent:@""];
            
            NSMenuItem *initPod = [[NSMenuItem alloc] initWithTitle:@"Init Pod" action:@selector(doMenuAction) keyEquivalent:@""];
            [initPod setState:NSOffState];
            NSMenuItem *updatePod = [[NSMenuItem alloc] initWithTitle:@"Update Pod" action:@selector(doMenuAction) keyEquivalent:@""];
            [updatePod setState:NSOffState];
            [initPod setTarget:self];
            [updatePod setTarget:self];
            
            [podCommandSubMenu addItem:initPod];
            [podCommandSubMenu addItem:updatePod];
            
            [[viewMenuItem submenu ] addItem:podCommand];
            
            [[viewMenuItem submenu ] setSubmenu:podCommandSubMenu forItem:podCommand];
            
            [initPod release];
            [updatePod release];
            [podCommand release];
        }
    }
    return self;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(doMenuAction)) {
        if (self.projectRoot) {
            _podFilePath= [self.projectRoot URLByAppendingPathComponent:@"Podfile"];
            _podFileLockPath= [self.projectRoot URLByAppendingPathComponent:@"Podfile.lock"];
            NSError *error;
            BOOL podFileExists = [_podFilePath checkResourceIsReachableAndReturnError:&error];
            BOOL podFileLockExists = [_podFileLockPath checkResourceIsReachableAndReturnError:&error];
            if ([[menuItem title] isEqualToString:@"Init Pod"]) {
                return podFileExists && !podFileLockExists;
            } else {
                return podFileExists && podFileLockExists;
            }
        }
		return NO;
	}
	return YES;
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Hello, %@",self.projectRoot] defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [alert runModal];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (NSURL *)projectRoot
{
    Class IDEWorkspaceWindowController = NSClassFromString(@"IDEWorkspaceWindow");
    NSURL *fileURL = (NSURL *)[[IDEWorkspaceWindowController lastActiveWorkspaceWindow] valueForKeyPath:@"windowController._workspace.representingFilePath._fileURL"];
    return [fileURL URLByDeletingLastPathComponent];
}

@end
