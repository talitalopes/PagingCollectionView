//
//  CarrouselCollectionView.m
//  ARCarousel-Demo
//
//  Created by Talita on 15/05/14.
//  Copyright (c) 2014 Ares. All rights reserved.
//

#import "CarrouselCollectionView.h"

/**
 *  Configure Item for carousel
 *
 *  @param ITEM_WIDTH
 *  @param ITEM_HEIGHT
 *
 */
#define ITEM_WIDTH 180
#define ITEM_HEIGHT 40

// The size the Center item will increase
#define PERCENT_MAIN_ITEM 0

#define ITEM_SIZE CGSizeMake(ITEM_WIDTH,ITEM_HEIGHT)


@interface CarrouselCollectionView()

/**
 *  Page Configure
 */
@property (assign,nonatomic) NSInteger count;
@property (assign,nonatomic) NSInteger centerItem;
@property (strong,nonatomic) NSArray *infData;
@property (assign,nonatomic) CGFloat pageWidth;

@property (assign,nonatomic) NSUInteger loopPointLeft;
@property (assign,nonatomic) NSUInteger loopPointRight;

@property (strong,nonatomic) UICollectionViewCell *previousCell;
@property (strong,nonatomic) UICollectionViewCell *nextCell;

@property (strong,nonatomic) UIPanGestureRecognizer *panGesture;

@property (assign,nonatomic) CGRect carouselFrame;

// Global Variable for Pan Gesture
@property (assign,nonatomic) CGPoint oldOffset;


@end

@implementation CarrouselCollectionView

- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:ITEM_SIZE];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumLineSpacing:0];
    
    self = [super initWithFrame:frame collectionViewLayout:flowLayout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        self.allowsSelection = YES;
        [self registerClass:[ReuseCell class] forCellWithReuseIdentifier:@"ReuseCell"];
        
        self.data = data;
        [self setupCarousel];
    }
    return self;
}

- (void)setupCarousel {
    if (!self.data) {
        return;
    }
    
    // Method for infinity loop
    [self configInfinityLoop];
    
    // Config gesture
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(customPan:)];
    self.panGestureRecognizer.enabled = NO;
    
    [self addGestureRecognizer:self.panGesture];
    [self addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)configInfinityLoop {
    self.count = [self.data count];
    
    if (self.count < 3) {
        @throw [NSException exceptionWithName:@"Invalid Data for Carousel" reason:@"Data for carousel should more than 3 item!!!" userInfo:nil];
    }
    
    self.centerItem = 2;
    
    NSMutableArray *buildArray = [NSMutableArray arrayWithArray:self.data];
    [buildArray insertObject:self.data[self.count-2] atIndex:0];
    [buildArray insertObject:[self.data lastObject] atIndex:1];
    [buildArray addObject:self.data[0]];
    [buildArray addObject:self.data[1]];
    
    self.infData = [NSArray arrayWithArray:buildArray];
    
    self.count += 4;
    self.loopPointLeft = 1;
    self.loopPointRight = self.count - 2;
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"data"]) {
        
        [self configInfinityLoop];
        [self reloadData];
    }
}

#pragma mark - Action

- (IBAction)customPan:(UIPanGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        self.oldOffset = self.contentOffset;
        
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [sender translationInView:self];
        CGPoint offset;
        offset.x = (self.oldOffset.x - translation.x);
        [self setContentOffset:offset animated:NO];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGPoint translation = [sender translationInView:self];
        
        self.previousCell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.centerItem inSection:0]];
        
        if (translation.x > 0) {
            
            if ((0 < self.centerItem) && (self.centerItem <= (self.count - 1))) {
                self.centerItem -= 1;
                
            }
        } else {
            
            if ((0 <= self.centerItem) && (self.centerItem < self.count - 1)) {
                self.centerItem += 1;
            }
        }
        
        [self scrollToCenterItem];
    }
    
}

- (void)scrollToCenterItem {
    
    CGPoint nextOffset;
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.centerItem inSection:0]];
    self.nextCell = cell;
    
    // Method for the next offset
    nextOffset.x = CGRectGetMinX(cell.frame) - (CGRectGetWidth(self.frame)/2 - (ITEM_WIDTH/2));
    
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
        
        // Move to next offset
        [self setContentOffset:nextOffset];
        
        // Setup Emphrasing Center Item
        self.previousCell.frame = CGRectInset(self.previousCell.frame, PERCENT_MAIN_ITEM, PERCENT_MAIN_ITEM);
        self.previousCell.layer.zPosition = 0;
        self.previousCell.layer.cornerRadius = 0;
        
        self.nextCell.frame = CGRectInset(self.nextCell.frame, -PERCENT_MAIN_ITEM, -PERCENT_MAIN_ITEM);
        self.nextCell.layer.zPosition = 1000;
        self.nextCell.layer.cornerRadius = 10;
    } completion:^(BOOL finished) {
        
        // Infinity loop carousel
        if (self.centerItem == self.loopPointRight) {
            
            self.centerItem = 2;
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.centerItem inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
        
        if (self.centerItem == self.loopPointLeft) {
            
            self.centerItem = self.loopPointRight - 1;
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.centerItem inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
        
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"delegate: %@", self.delegate);
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == self.centerItem) {
        return;
    }
    
    if (indexPath.item < self.centerItem) {
        self.centerItem -= 1;
    }
    
    if (indexPath.item > self.centerItem) {
        self.centerItem += 1;
    }
    
    [self scrollToCenterItem];
    
    if ([self.carrouselDelegate respondsToSelector:@selector(changeToPage:)]) {
        [self.carrouselDelegate changeToPage:self.centerItem];
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ReuseCell *cell = [self dequeueReusableCellWithReuseIdentifier:@"ReuseCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[ReuseCell alloc] init];
    }
    
    NSLog(@"%@", cell.gestureRecognizers);
    cell.item.text = self.infData[indexPath.row];
    cell.item.backgroundColor = (indexPath.row % 2) ? [UIColor lightGrayColor] : [UIColor grayColor];
    
    cell.layer.zPosition = 0;
    cell.layer.cornerRadius = 0;
    
    if (indexPath.row == self.centerItem) {
        cell.frame = CGRectInset(cell.frame, -PERCENT_MAIN_ITEM, -PERCENT_MAIN_ITEM);
        cell.layer.zPosition = 1000;
        cell.layer.cornerRadius = 10;
        self.previousCell = cell;
    }
    
    return cell;
}


- (void)reloadData {
    [super reloadData];
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.centerItem inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}


@end
