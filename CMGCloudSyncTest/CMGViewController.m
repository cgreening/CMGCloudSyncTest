//
//  CMGViewController.m
//  CMGCloudSyncTest
//
//  Created by Chris Greening on 13/02/2014.
//  Copyright (c) 2014 Chris Greening. All rights reserved.
//

#import "CMGViewController.h"

@interface CMGViewController ()

@end

@implementation CMGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUbiquitousKeyValueStore *defaultStore = [NSUbiquitousKeyValueStore defaultStore];
    // register to observe notifications from the store
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector (storeDidChange:)
     name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
     object: defaultStore];
    // get changes that might have happened while this
    // instance of your app wasn't running
    [defaultStore synchronize];
    
    self.string1TextField.text = [defaultStore stringForKey:@"string1Value"];
    self.string2TextField.text = [defaultStore stringForKey:@"string2Value"];
}

-(void) storeDidChange:(NSNotification *) notification {
    NSNumber *reason = notification.userInfo[NSUbiquitousKeyValueStoreChangeReasonKey];
    if(!reason) return;
    
    // get the reason code
    NSInteger reasonCode = [notification.userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] intValue];
    switch(reasonCode) {
        case NSUbiquitousKeyValueStoreAccountChange:
        case NSUbiquitousKeyValueStoreServerChange:
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            // update the changed values
            if([notification.userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] containsObject:@"string1Value"]) {
                self.string1TextField.text = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"string1Value"];
            }
            if([notification.userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] containsObject:@"string2Value"]) {
                self.string2TextField.text = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"string2Value"];
            }
            break;
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            NSLog(@"Run out of space!");
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if(textField == self.string1TextField) {
        [[NSUbiquitousKeyValueStore defaultStore] setString:self.string1TextField.text forKey:@"string1Value"];
    }
    if(textField == self.string2TextField) {
        [[NSUbiquitousKeyValueStore defaultStore] setString:self.string2TextField.text forKey:@"string2Value"];
    }
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    return YES;
}


@end
