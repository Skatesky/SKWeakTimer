//
//  SKWeakTimer.m
//  SKWeakTimer
//
//  Created by zhanghuabing on 2018/10/17.
//

#import "SKWeakTimer.h"

typedef void(^SKTimerBlock)(NSTimer *timer);

@interface SKTimerBlockParam : NSObject

@property (copy, nonatomic) void (^callBack)(NSTimer *timer);

@end


@implementation SKTimerBlockParam

@end

/// 封装和转发原始消息
@interface SKTimerObject : NSObject

@property (weak, nonatomic) id target;  /// 原始的target

@property (assign, nonatomic) SEL selector; /// 原始的方法

@property (strong, nonatomic) NSRunLoopMode selectorRunLoopMode;    /// selector的运行mode环境

@end

@implementation SKTimerObject

- (void)fire:(NSTimer *)timer {
    if (!self.target || !self.selector) {
        [timer invalidate];
        return;
    }
    
    NSRunLoopMode runLoopMode = NSDefaultRunLoopMode;
    if (self.selectorRunLoopMode) {
        runLoopMode = self.selectorRunLoopMode;
    }
    // 执行在当前线程需要与timer的mode一致，因此需要指定mode
    NSMethodSignature *signature = [self.target methodSignatureForSelector:self.selector];
    
    NSInvocation *invocation =
    [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self.target];
    [invocation setSelector:self.selector];
    
    NSUInteger numberOfArguments = signature.numberOfArguments;
    if (numberOfArguments == 2) {   // 不带参数
        [invocation invoke];
    } else if (numberOfArguments == 3) {    // 带有一个参数
        [invocation setArgument:&timer atIndex:2];
        [invocation invoke];
    } else { // 参数过多，不合法
        NSLog(@"warning: NSTimer's selector arguments invalid!");
        [invocation invoke];
    }
    
    // !!! 注意 performSelector: 相关方法的执行默认是在当前线程的NSDefaultRunLoopMode下
    // invocation 不涉及这些，当前线程的当前mode !!! 验证下
    
    // 这个方法调用时不严谨的，因为传入进来的selector不一定带有参数，虽然这里也不会有什么问题
    // 如果参数是NSTimer(系统方法都是NSTimer，即便selector参数不是此类型)，则这里入参就不正确
//    [self.target performSelector:self.selector withObject:timer.userInfo afterDelay:0.0f inModes:@[runLoopMode]];
}

- (void)fireWithBlock:(NSTimer *)timer {
    SKTimerBlockParam *param = timer.userInfo;
    if (param.callBack) {
        param.callBack(timer);
    }
}

@end



@interface SKWeakTimer ()


@end

@implementation SKWeakTimer

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     target:(id)target
                                   selector:(SEL)selector
                                   userInfo:(nullable id)userInfo
                                    repeats:(BOOL)repeats {
    return [self scheduledTimerWithTimeInterval:interval
                                         target:target
                                       selector:selector
                                       userInfo:userInfo
                                        repeats:repeats
                                         inMode:NSDefaultRunLoopMode];
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     target:(id)target
                                   selector:(SEL)selector
                                   userInfo:(nullable id)userInfo
                                    repeats:(BOOL)repeats
                                     inMode:(NSRunLoopMode)mode {
    SKTimerObject *timerObject = [[SKTimerObject alloc] init];
    timerObject.target = target;
    timerObject.selector = selector;
    timerObject.selectorRunLoopMode = mode;
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:interval
                                             target:timerObject
                                           selector:@selector(fire:)
                                           userInfo:userInfo
                                            repeats:repeats];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:mode];

    return timer;
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                    repeats:(BOOL)repeats
                                      block:(void (^)(NSTimer *timer))block {
    return [self scheduledTimerWithTimeInterval:interval repeats:repeats inMode:NSDefaultRunLoopMode block:block];
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                    repeats:(BOOL)repeats
                                     inMode:(NSRunLoopMode)mode
                                      block:(void (^)(NSTimer *timer))block {
    SKTimerBlockParam *param = [[SKTimerBlockParam alloc] init];
    param.callBack = block;
    
    SKTimerObject *timerObject = [[SKTimerObject alloc] init];
    timerObject.selectorRunLoopMode = mode;
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:interval
                                             target:timerObject
                                           selector:@selector(fireWithBlock:)
                                           userInfo:param
                                            repeats:repeats];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:mode];
    
    return timer;
}

@end
