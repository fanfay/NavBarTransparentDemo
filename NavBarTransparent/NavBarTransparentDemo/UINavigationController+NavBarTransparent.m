//
//  UINavigationController+NavBarTransparent.m
//  NavBarTransparentDemo
//
//  Created by fay_fan on 2017/7/20.
//  Copyright © 2017年 fay_fan. All rights reserved.
//

#import "UINavigationController+NavBarTransparent.h"
#import <objc/runtime.h>

@implementation UIColor (DefaultColor)

+ (UIColor *)defaultNavBarTintColor{
    
    return [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1.0];
    
}
+ (UIColor *)randomColor{
    
    int R = (arc4random() % 256) ;
    int G = (arc4random() % 256) ;
    int B = (arc4random() % 256) ;
    
    return [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1];
}

@end


@implementation UINavigationController (NavBarTransparent)

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return self.topViewController.preferredStatusBarStyle || UIStatusBarStyleDefault;
    
}

- (void)viewDidLoad{
    
    [UINavigationController swizzle];
    
    [super viewDidLoad];
}

+ (void)swizzle{

    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        Method originalMethod1 = class_getInstanceMethod([self class], NSSelectorFromString(@"_updateInteractiveTransition:"));
        Method swizzledMethod1 = class_getInstanceMethod([self class], @selector(fay_updateInteractiveTransition:));
        method_exchangeImplementations(originalMethod1, swizzledMethod1);
        
        Method originalMethod2 = class_getInstanceMethod([self class], @selector(popToViewController:animated:));
        Method swizzledMethod2 = class_getInstanceMethod([self class], @selector(fay_popToViewController:animated:));
        method_exchangeImplementations(originalMethod2, swizzledMethod2);

        Method originalMethod3 = class_getInstanceMethod([self class], @selector(popToRootViewControllerAnimated:));
        Method swizzledMethod3 = class_getInstanceMethod([self class], @selector(fay_popToRootViewControllerAnimated:));
        method_exchangeImplementations(originalMethod3, swizzledMethod3);
        
    });
    
}

- (nullable NSArray<__kindof UIViewController *> *)fay_popToViewController:(UIViewController *)desVC animated:(BOOL)animated{
    
    [self setNeedsNavigationBackground:[desVC.navBarBgAlpha floatValue] bgColor:nil];
    self.navigationBar.tintColor = desVC.navBarTintColor;
    self.navigationBar.barTintColor = desVC.navBackgroundColor;

    return [self fay_popToViewController:desVC animated:animated];
    
}
- (nullable NSArray<__kindof UIViewController *> *)fay_popToRootViewControllerAnimated:(BOOL)animated{
    
    [self setNeedsNavigationBackground:[self.viewControllers.firstObject.navBarBgAlpha floatValue] bgColor:nil];
    self.navigationBar.tintColor = self.viewControllers.firstObject.navBarTintColor;
    self.navigationBar.barTintColor = self.viewControllers.firstObject.navBackgroundColor;

    return [self fay_popToViewController:self.viewControllers.firstObject animated:animated];

    
}
- (void)fay_updateInteractiveTransition:(CGFloat) percentComplete{
    
    NSLog(@"percentComplete:--->%lf",percentComplete);

    if (self.topViewController && self.topViewController.transitionCoordinator) {
        
        UIViewController *fromVC = [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toVC = [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        
        // Bg Alpha
        CGFloat fromAlpha = fromVC.navBarBgAlpha  ? [fromVC.navBarBgAlpha floatValue] : 0;
        CGFloat toAlpha = toVC.navBarBgAlpha ? [toVC.navBarBgAlpha floatValue] : 0;
        CGFloat newAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete;
        
        // Background Color
        UIColor *fromBgColor = fromVC.navBackgroundColor;
        UIColor *toBgColor = toVC.navBackgroundColor;
        UIColor *newBgColor = [self averageColor:fromBgColor toColor:toBgColor percent:percentComplete];
        self.navigationBar.barTintColor = newBgColor;
        [self setNeedsNavigationBackground:newAlpha bgColor:newBgColor];

        
        // Tint Color
        UIColor *fromColor = fromVC.navBarTintColor ? fromVC.navBarTintColor : [UIColor blueColor];
        UIColor *toColor = toVC.navBarTintColor ? toVC.navBarTintColor : [UIColor blueColor];
        UIColor *newColor = [self averageColor:fromColor toColor:toColor percent:percentComplete];
        self.navigationBar.tintColor = newColor;

        [self fay_updateInteractiveTransition:percentComplete];
        
    }else{
        
        [self fay_updateInteractiveTransition:percentComplete];
        
    }
}

#pragma mark --private method

- (UIColor *)averageColor:(UIColor *)fromColor toColor:(UIColor *)toColor percent:(CGFloat)percent{
    CGFloat fromRed = 0;
    CGFloat fromGreen = 0;
    CGFloat fromBlue = 0;
    CGFloat fromAlpha = 0;
    [fromColor getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed = 0;
    CGFloat toGreen = 0;
    CGFloat toBlue = 0;
    CGFloat toAlpha = 0;
    [toColor getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat nowRed = fromRed + (toRed - fromRed) * percent;
    CGFloat nowGreen = fromGreen + (toGreen - fromGreen) * percent;
    CGFloat nowBlue = fromBlue + (toBlue - fromBlue) * percent;
    CGFloat nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percent;
    
    return [UIColor colorWithRed:nowRed green:nowGreen blue:nowBlue alpha:nowAlpha];

}

- (void)setNeedsNavigationBackground:(CGFloat)alpha bgColor:(UIColor *)bgColor{
    
    UIView *barBackgroundView = self.navigationBar.subviews[0];
    
    UIView *shadowView = [barBackgroundView valueForKey:@"_shadowView"];
    if (shadowView) {
        shadowView.alpha = alpha;
        shadowView.hidden = alpha == 0;
    }
    
    if (self.navigationBar.translucent) {
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
//        UIVisualEffectView
            UIView *backgroundEffectView = [barBackgroundView valueForKey:@"_backgroundEffectView"];
            UIImage *image = self.navigationBar.backIndicatorImage;
            if (backgroundEffectView && !image) {
                backgroundEffectView.alpha = alpha;
            }
            
            UIView *visualEffectFilterView = [backgroundEffectView.subviews lastObject];

            if (visualEffectFilterView && bgColor) {
                visualEffectFilterView.backgroundColor = bgColor;
            }
            return;
        }else{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIView *adaptiveBackdrop = [barBackgroundView valueForKey:@"_adaptiveBackdrop"];
                UIView *backdropEffectView = [adaptiveBackdrop valueForKey:@"_backdropEffectView"];
                
                if (backdropEffectView) {
                    backdropEffectView.backgroundColor= [UIColor redColor];
                    backdropEffectView.alpha = alpha;
                    return;
                }
            });
        }
        
    }
    barBackgroundView.alpha = alpha;

}

- (void)dealInteractionChanges:(id <UIViewControllerTransitionCoordinatorContext>) context{
    
    NSLog(@"dealInteractionChanges");
    if (context.cancelled) {
        
        NSLog(@"context.cancelled");
        
        NSTimeInterval cancelDuration = MAX(context.transitionDuration * context.percentComplete, 0.1);

        [UIView animateWithDuration:cancelDuration animations:^{
            [self animations:context TransitinKey:UITransitionContextFromViewControllerKey];
        }];
        
        
    }else{
        
        NSLog(@"context.complated");
        NSTimeInterval finishDuration = MAX(context.transitionDuration * (1-context.percentComplete), 0.1);
        [UIView animateWithDuration:finishDuration animations:^{
            [self animations:context TransitinKey:UITransitionContextToViewControllerKey];
        }];
        
    }
}

- (void)animations:(id<UIViewControllerTransitionCoordinatorContext>)context TransitinKey:(UITransitionContextViewControllerKey)key{
    
    UIViewController *currentVC = [context viewControllerForKey:key];
    CGFloat nowAlpha = currentVC.navBarBgAlpha ? [currentVC.navBarBgAlpha floatValue] : 0;
    [self setNeedsNavigationBackground:nowAlpha bgColor:nil];
    self.navigationBar.tintColor = currentVC.navBarTintColor;
    self.navigationBar.barTintColor = currentVC.navBackgroundColor;

}

#pragma mark -- UINavigationBarDelegate

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    
    
    NSLog(@"shouldPushItem");
    
    UIViewController *topVC = self.topViewController;
    id<UIViewControllerTransitionCoordinator> tc = topVC.transitionCoordinator;
    if (tc && tc.initiallyInteractive) {
        
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
            [tc notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                [self dealInteractionChanges:context];
            }];

        }else{
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            
            [tc notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                [self dealInteractionChanges:context];
            }];
            
#pragma clang diagnostic pop
            
        }
        
        return YES;
        
    }else{
        NSInteger itemCount = self.navigationBar.items ? self.navigationBar.items.count : 0;
        NSInteger n = self .viewControllers.count >= itemCount ? 2:1;
        UIViewController *popToVC = self.viewControllers[self.viewControllers.count - n];
        [self popToViewController:popToVC animated:YES];
    }
    return YES;

}
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item{

    [self setNeedsNavigationBackground:self.topViewController.navBarBgAlpha ? [self.topViewController.navBarBgAlpha floatValue] : 0 bgColor:nil];
    self.navigationBar.tintColor = self.topViewController.navBarTintColor;
    self.navigationBar.barTintColor = self.topViewController.navBackgroundColor;

    return true;
    
}


@end


@implementation UIViewController (NavBarTransparent)

- (void)setNavBarBgAlpha:(NSNumber *)navBarBgAlpha{
    
    CGFloat alpha = MAX(MIN([navBarBgAlpha floatValue], 1), 0);
    [self.navigationController setNeedsNavigationBackground:alpha bgColor:nil];
    objc_setAssociatedObject(self, @selector(navBarBgAlpha), [NSNumber numberWithFloat:alpha], OBJC_ASSOCIATION_RETAIN);
    
}

- (NSNumber *)navBarBgAlpha{
    
    id alpha = objc_getAssociatedObject(self, @selector(navBarBgAlpha));
    alpha = alpha ? alpha : [NSNumber numberWithFloat:1.0];
    return alpha;
}

- (void)setNavBarTintColor:(UIColor *)navBarTintColor{
    self.navigationController.navigationBar.tintColor = navBarTintColor;
    objc_setAssociatedObject(self, @selector(setNavBarTintColor:), navBarTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}
- (UIColor *)navBarTintColor{
    
    UIColor *color = objc_getAssociatedObject(self, @selector(setNavBarTintColor:));
    color = color ? color : [UIColor defaultNavBarTintColor];
    return color;
    
}

- (void)setNavBackgroundColor:(UIColor *)navBackgroundColor{
    
    self.navigationController.navigationBar.barTintColor = navBackgroundColor;
    objc_setAssociatedObject(self, @selector(navBackgroundColor), navBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (UIColor *)navBackgroundColor{
    
    UIColor *color = objc_getAssociatedObject(self, @selector(navBackgroundColor));
    color = color ? color : [UIColor whiteColor];
    return color;
    
}

- (UIColor *)navTitleColor{
    
    UIColor *color = objc_getAssociatedObject(self, @selector(navTitleColor));
    color = color ? color : [UIColor blackColor];
    return color;
}
- (void)setNavTitleColor:(UIColor *)navTitleColor{
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:navTitleColor forKey:NSForegroundColorAttributeName];
    objc_setAssociatedObject(self, @selector(navTitleColor), navTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

