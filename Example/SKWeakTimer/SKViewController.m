//
//  SKViewController.m
//  SKWeakTimer
//
//  Created by zhanghuabing on 10/17/2018.
//  Copyright (c) 2018 zhanghuabing. All rights reserved.
//

#import "SKViewController.h"
#import "SKWeakTimer.h"
#import "SKTimerTest.h"

@interface SKViewController ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation SKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer *timer) {
        NSLog(@"====");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fire:(NSTimer *)timer {
    NSLog(@"fire timer");
}

@end
