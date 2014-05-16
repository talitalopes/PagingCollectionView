//
//  CarrouselCollectionView.h
//  ARCarousel-Demo
//
//  Created by Talita on 15/05/14.
//  Copyright (c) 2014 Ares. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReuseCell.h"

@protocol CarrouselDelegate <NSObject>

@optional
- (void)changeToPage:(NSInteger)pageIndex;

@end

@interface CarrouselCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>

- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data;

@property (strong, nonatomic) id<CarrouselDelegate> carrouselDelegate;
@property (nonatomic, strong) NSArray *data;

@end
