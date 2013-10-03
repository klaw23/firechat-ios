//
//  FireChat.m
//  Firechat
//
//  Created by Kevin Law on 9/13/13.
//  Copyright (c) 2013 Firebase. All rights reserved.
//

#import "FireChat.h"

#import <Firebase/Firebase.h>

#define kFirechatNS @"https://firechat-ios.firebaseio-demo.com/"

@interface FireChat ()

@property (nonatomic, weak) id<FireChatDelegate> delegate;

// Username of the client.
@property (nonatomic, strong) NSString *name;

// Array of chat messages.
@property (nonatomic, strong) NSMutableArray* chat;

// Firebase connection.
@property (nonatomic, strong) Firebase* firebase;

@end

@implementation FireChat

@synthesize delegate = delegate_;
@synthesize name = name_;
@synthesize chat;
@synthesize firebase;

- (id)initWithDelegate:(id<FireChatDelegate>)delegate name:(NSString *)name chatId:(NSString *)chatId {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
        self.name = name;
        
        self.chat = [[NSMutableArray alloc] init];
        
        // Initialize the root of our Firebase namespace.
        self.firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@",
                                                       kFirechatNS,
                                                       chatId]];
        
        
        [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
            // Add the chat message to the array.
            [self.chat addObject:snapshot.value];
            // Reload the table view so the new message will show up.
            [self.delegate reloadData];
        }];
    }
    
    return self;
}

- (void)sendChat:(NSString *)text {
    // This will also add the message to our local array self.chat because
    // the FEventTypeChildAdded event will be immediately fired.
    [[self.firebase childByAutoId] setValue:@{@"name" : self.name, @"message": text}
                                andPriority:[NSNumber numberWithDouble:[[NSDate date]
                                                                        timeIntervalSince1970]]];
}

@end
