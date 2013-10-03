//
//  FireChat.m
//  Firechat
//
//  Created by Kevin Law on 9/13/13.
//  Copyright (c) 2013 Firebase. All rights reserved.
//

#import "FireChat.h"

#import <Firebase/Firebase.h>

#define kFirechatNS @"https://firechat-ios.firebaseio-demo.com/chat"

@interface FireChat ()

@property (nonatomic, weak) id<FireChatDelegate> delegate;

// Username of the client.
@property (nonatomic, strong) NSString *name;

// Array of chat messages.
@property (nonatomic, strong) NSMutableArray* chat;

// Firebase connection.
@property (nonatomic, strong) Firebase* firebase;

// The chat room id once it's created.
@property (nonatomic, strong) NSString *roomId;

@end

@implementation FireChat

@synthesize delegate = delegate_;
@synthesize name = name_;
@synthesize chat;
@synthesize firebase;
@synthesize roomId = roomId_;

- (id)initWithDelegate:(id<FireChatDelegate>)delegate name:(NSString *)name {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
        self.name = name;
        
        self.chat = [[NSMutableArray alloc] init];
        
        // Initialize the root of our Firebase namespace.
        self.firebase = [[Firebase alloc] initWithUrl:kFirechatNS];
    }
    
    return self;
}

- (void)createRoomWithName:(NSString *)roomName
                completion:(void (^)(NSString *roomId))completion {
    Firebase *newRoomRef = [[self.firebase childByAppendingPath:@"room-metadata"] childByAutoId];

    NSString *roomId = newRoomRef.name;
    
    // TODO(kevin): Implement private room type.
    [newRoomRef setValue:@{@"id": roomId,
                           @"name": roomName,
                           @"type": @"public",
                           @"createdAt":
                               [NSNumber numberWithInt:(int)([[NSDate date] timeIntervalSince1970] *
                                                             1000)]}
     withCompletionBlock:^(NSError *error) {
         if (!error) {
             [self enterRoomWithId:roomId];
         }
         if (completion) {
             completion(roomId);
         }
     }];
}

- (void)enterRoomWithId:(NSString *)roomId {
    self.roomId = roomId;
    
    // TODO(kevin): The JS client does lots of things to handle presence. I'm ommiting those for now
    // and just listening for messages.
    Firebase *roomMessagesRef = [[self.firebase childByAppendingPath:@"room-messages"]
                                 childByAppendingPath:roomId];
    [roomMessagesRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        // Add the chat message to the array.
        [self.chat addObject:snapshot.value];
        // Reload the table view so the new message will show up.
        [self.delegate reloadData];
    }];
}

- (void)sendChat:(NSString *)text {
    Firebase *roomMessagesRef = [[self.firebase childByAppendingPath:@"room-messages"]
                                 childByAppendingPath:self.roomId];
    // This will also add the message to our local array self.chat because
    // the FEventTypeChildAdded event will be immediately fired.
    [[roomMessagesRef childByAutoId] setValue:@{@"name" : self.name, @"message": text}
                                  andPriority:[NSNumber
                                               numberWithDouble:[[NSDate date]
                                                                 timeIntervalSince1970] * 1000]];
}

@end
