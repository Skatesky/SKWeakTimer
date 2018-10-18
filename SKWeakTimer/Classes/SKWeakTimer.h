//
//  SKWeakTimer.h
//  SKWeakTimer
//
//  Created by zhanghuabing on 2018/10/17.
//

#import <Foundation/Foundation.h>

@interface SKWeakTimer : NSObject

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     target:(id)target
                                   selector:(SEL)selector
                                   userInfo:(nullable id)userInfo
                                    repeats:(BOOL)repeats;

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     target:(id)target
                                   selector:(SEL)selector
                                   userInfo:(nullable id)userInfo
                                    repeats:(BOOL)repeats
                                     inMode:(NSRunLoopMode)mode;

/// iOS 10.0 之后，NSTimer 提供了block 的方式
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                    repeats:(BOOL)repeats
                                      block:(void (^)(NSTimer *timer))block;

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                    repeats:(BOOL)repeats
                                     inMode:(NSRunLoopMode)mode
                                      block:(void (^)(NSTimer *timer))block;

@end
