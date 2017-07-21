//
//  UINavigationController+NavBarTransparent.h
//  NavBarTransparentDemo
//
//  Created by fay_fan on 2017/7/20.
//  Copyright © 2017年 fay_fan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DefaultColor)

+ (UIColor *)defaultNavBarTintColor;

+ (UIColor *)randomColor;

@end

@interface UINavigationController (NavBarTransparent)<UINavigationBarDelegate>


@end


@interface UIViewController (NavBarTransparent)

/**
 nav alpha 0-1
 */
@property (nonatomic, strong)NSNumber *navBarBgAlpha;

/**
 nav item Color
 */
@property (nonatomic, strong)UIColor *navBarTintColor;

/**
 nav background Color
 */
@property (nonatomic, strong)UIColor *navBackgroundColor;


/**
 nav title color
 */
@property (nonatomic, strong)UIColor *navTitleColor;

@end
