//
//  FirstViewController.m
//  Smart_Pi-mobile
//
//  Created by 朱嘉灵 on 2019/10/24.
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import "cocos2d.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 添加LaunchScreenBackground.png以防止黑屏
    UIImage* image = [UIImage imageNamed:@"LaunchScreenBackground.png"];
    UIImageView* imageView = [[UIImageView alloc] init];
    imageView.image = image;
    imageView.clipsToBounds = YES;
    [imageView setFrame:self.view.frame];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.view addSubview:imageView];
    _mask = imageView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_onViewDidAppearTarget performSelector:_onViewDidAppearHandler withObject:self];
}

- (void)setViewDidAppearHandler:(SEL) selector :(id) target {
    _onViewDidAppearHandler = selector;
    _onViewDidAppearTarget = target;
}

- (void)fadeOutMask:(void (^)(void)) onFinish {
    [UIView animateWithDuration:0.5 animations:^{
        if (_mask) {
            _mask.layer.opacity = 0;
        }
    } completion:^(BOOL complete){
        if (_mask) {
            [_mask removeFromSuperview];
            _mask = nil;
        }
        if (onFinish){
            onFinish();
        }
    }];
}

- (void)dealloc{
    [super dealloc];
}

@end
