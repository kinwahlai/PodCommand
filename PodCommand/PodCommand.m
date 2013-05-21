//
//  PodCommand.m
//  PodCommand
//
//  Created by kazaana_developer on 5/13/13.
//  Copyright (c) 2013 kinwah. All rights reserved.
//

#import "PodCommand.h"

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
            NSMenu *podCommandSubMenu = [[NSMenu alloc]initWithTitle:@"aaaa"];
            
            NSMenuItem *podCommand = [[NSMenuItem alloc] initWithTitle:@"Pod Command" action:nil keyEquivalent:@""];
            
            NSMenuItem *initPod = [[NSMenuItem alloc] initWithTitle:@"Init Pod" action:@selector(doMenuAction) keyEquivalent:@""];
            NSMenuItem *updatePod = [[NSMenuItem alloc] initWithTitle:@"Update Pod" action:@selector(doMenuAction) keyEquivalent:@""];
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

// Sample Action, for menu item:
- (void)doMenuAction
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Hello, World" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [alert runModal];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
