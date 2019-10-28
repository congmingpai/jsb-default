//
//  FirstViewController.h
//  Smart_Pi-mobile
//
//  Created by 朱嘉灵 on 2019/10/24.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class RootViewController;

@interface FirstViewController : UIViewController
{
    SEL _onViewDidAppearHandler;
    id _onViewDidAppearTarget;
    UIView* _mask;
}

- (void)setViewDidAppearHandler:(SEL) selector :(id) target;

- (void)fadeOutMask:(void (^)(void)) onFinish;

@end

NS_ASSUME_NONNULL_END
