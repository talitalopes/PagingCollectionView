//
//  ReuseCell.m
//  ARCarousel-Demo
//
//  Created by Talita on 15/05/14.
//  Copyright (c) 2014 Ares. All rights reserved.
//

#import "ReuseCell.h"

@implementation ReuseCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"ReuseCell" owner:self options:nil];
        UIView* mainView = (UIView*)[nibViews objectAtIndex:0];
        [self addSubview:mainView];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"oi");
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
