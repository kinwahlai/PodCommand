//
//  PodCommand.m
//  PodCommand
//
//Copyright (C) 2013 Kin Wah Lai
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//of the Software, and to permit persons to whom the Software is furnished to do
//so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//

#import "PodCommand.h"
#import "ATZShell+PodCommandToolCheck.h"
#import "ATZShell.h"

static NSString *const POD = @"/usr/bin/pod";
static NSString *const PODCOMMAND = @"Pod Command";
static NSString *const INITPOD = @"Init Pod";
static NSString *const UPDATEPOD = @"Update Pod";
static NSString *const PODFILE = @"Podfile";
static NSString *const PODFILELOCK = @"Podfile.lock";
static NSString *const INSTALL = @"install";
static NSString *const UPDATE = @"update";

@class IDEWorkspaceWindowController;

@interface NSObject()
+ (id)workspaceWindowControllers;
+ (id)lastActiveWorkspaceWindow;
@end

@interface PodCommand ()
{

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
            
            NSMenuItem *podCommand = [[NSMenuItem alloc] initWithTitle:PODCOMMAND action:nil keyEquivalent:@""];
            
            NSMenuItem *initPod = [[NSMenuItem alloc] initWithTitle:INITPOD action:@selector(performInitPod:) keyEquivalent:@""];
            [initPod setState:NSOffState];
            NSMenuItem *updatePod = [[NSMenuItem alloc] initWithTitle:UPDATEPOD action:@selector(performUpdatePod:) keyEquivalent:@""];
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

- (BOOL)shouldEnable:(NSMenuItem *)menuItem
{
    if (self.projectRoot) {
        NSURL *_podFilePath= [self.projectRoot URLByAppendingPathComponent:PODFILE];
        NSURL *_podFileLockPath= [self.projectRoot URLByAppendingPathComponent:PODFILELOCK];
        NSError *error;
        BOOL toolAvailable = [ATZShell areCommandLineToolsAvailableFor:POD];
        BOOL podFileExists = [_podFilePath checkResourceIsReachableAndReturnError:&error];
        BOOL podFileLockExists = [_podFileLockPath checkResourceIsReachableAndReturnError:&error];
        if ([[menuItem title] isEqualToString:INITPOD]) {
            return podFileExists && !podFileLockExists && toolAvailable;
        } else {
            return podFileExists && podFileLockExists && toolAvailable;
        }
        [_podFileLockPath release];
        [_podFilePath release];
    }
    return NO;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.parentItem && [menuItem.parentItem.title isEqualToString:PODCOMMAND]) {
        return [self shouldEnable:menuItem];
    }
	
	return NO;
}

// Sample Action, for menu item:
- (void)performInitPod:(id)sender
{
    ATZShell *shell = [ATZShell new];
    [shell executeCommand:POD withArguments:@[INSTALL] inWorkingDirectory:[self.projectRoot path]completion:^(NSString *output, NSError *error) {
        if (error) {
            NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"%@",[error localizedDescription]] defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
            [alert runModal];
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Pod install completed"] defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please close the project and start using the workspace"];
            [alert runModal];
        }
        [shell release];
    }];

}

- (void)performUpdatePod:(id)sender
{
    ATZShell *shell = [ATZShell new];
    [shell executeCommand:POD withArguments:@[UPDATE] inWorkingDirectory:[self.projectRoot path]completion:^(NSString *output, NSError *error) {
        if (error) {
            NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"%@",[error localizedDescription]] defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
            [alert runModal];
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Pod update completed"] defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
            [alert runModal];
        }
        [shell release];
    }];
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
