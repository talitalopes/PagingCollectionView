//
//  ViewController.m
//  PagingCollectionView
//
//  Created by Talita Gomes on 5/15/14.
//
//

#import "ViewController.h"

@interface ViewController ()

@property (strong,nonatomic) CarrouselCollectionView *carousel;
@property (strong,nonatomic) NSArray *data;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.data = @[@"Jogos Passados", @"Time que sigo", @"Jogos Futuros"];
    
    self.carousel = [[CarrouselCollectionView alloc] initWithFrame:CGRectMake(0, 64, 320, 40) andData:self.data];
    self.carousel.carrouselDelegate = self;
    [self.view addSubview:self.carousel];

    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
