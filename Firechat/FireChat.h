//
//  FireChat.h
//  Firechat
//
//  Created by Kevin Law on 9/13/13.
//  Copyright (c) 2013 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FireChatDelegate;

@interface FireChat : NSObject

// Array of chat messages.
@property (readonly, nonatomic, strong) NSMutableArray* chat;

// Initialize the object with a delegate, username, and chat room id.
- (id)initWithDelegate:(id<FireChatDelegate>)delegate
                  name:(NSString *)name
                chatId:(NSString *)chatId;

// Sends a chat message.
- (void)sendChat:(NSString *)text;

@end


@protocol FireChatDelegate

// Called when views need to refresh data.
- (void)reloadData;

@end
