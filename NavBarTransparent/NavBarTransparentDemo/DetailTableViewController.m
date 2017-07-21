//
//  DetailTableViewController.m
//  NavBarTransparentDemo
//
//  Created by 范亚龙 on 2017/7/20.
//  Copyright © 2017年 fay_fan. All rights reserved.
//

#import "DetailTableViewController.h"
#import "UINavigationController+NavBarTransparent.h"

@interface DetailTableViewController ()

@end

@implementation DetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarBgAlpha = arc4random()%2 == 1 ? [NSNumber numberWithFloat:0.0] : [NSNumber numberWithFloat:1.0];

    self.navBackgroundColor = [UIColor randomColor];
    self.navBarTintColor = [UIColor randomColor];
    self.navTitleColor = [UIColor randomColor];
    self.tableView.backgroundColor = [UIColor randomColor];
    
}
- (void)dealloc{
    NSLog(@"dealoc >>>>");
}
- (IBAction)backToRootVC:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
