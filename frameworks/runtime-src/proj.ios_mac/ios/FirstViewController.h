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
}

- (void)setViewDidAppearHandler:(SEL) selector :(id) target;

@end

NS_ASSUME_NONNULL_END
