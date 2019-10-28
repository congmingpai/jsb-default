/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org
 Copyright (c) 2013-2017 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
****************************************************************************/

#import "AppController.h"
#import "cocos2d.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "FirstViewController.h"
#import "platform/ios/CCEAGLView-ios.h"

#import "cocos-analytics/CAAgent.h"

#include "SdkManager.h"

using namespace cocos2d;

@implementation AppController

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate* s_sharedApplication = nullptr;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [CAAgent enableDebug:NO];

    if (s_sharedApplication == nullptr)
    {
        s_sharedApplication = new (std::nothrow) AppDelegate();
    }
    cocos2d::Application *app = cocos2d::Application::getInstance();

    // Initialize the GLView attributes
    app->initGLContextAttrs();
    cocos2d::GLViewImpl::convertAttrs();

    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];

    FirstViewController* firstViewController = [[FirstViewController alloc] init];
    [firstViewController setViewDidAppearHandler:@selector(onFirstViewDidAppear) :self];

    // Set RootViewController to window
    [self setRootView:firstViewController];

    [window makeKeyAndVisible];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // sdk manager
    SdkManager::appController = self;
    SdkManager::viewController = _viewController;
    SdkManager::window = window;
    SdkManager::applicationDidFinishLaunching(application, launchOptions);

    return YES;
}

- (void)setRootView:(UIViewController*) viewController {
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:viewController];
    }
}

- (void)onFirstViewDidAppear {
    cocos2d::Application *app = cocos2d::Application::getInstance();

    // Initialize the GLView attributes
    app->initGLContextAttrs();
    cocos2d::GLViewImpl::convertAttrs();

    // Override point for customization after application launch.

    // Use RootViewController to manage CCEAGLView
    _viewController = [[RootViewController alloc]init];
    _viewController.wantsFullScreenLayout = YES;
    
    // Set RootViewController to window
    [self setRootView:_viewController];

    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLViewImpl::createWithEAGLView((__bridge void *)_viewController.view);
    cocos2d::Director::getInstance()->setOpenGLView(glview);

    //run the cocos2d-x game scene
    app->run();
    
    // 第一次触发此消息时加载游戏
    // 将启动逻辑移至此处，防止iOS启动超过20秒被系统自动杀死
//    if (!app->isApplicationLoaded())
//    {
        app->applicationOnLoad();
//    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
      Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
      Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    */
    SdkManager::applicationWillResignActive(application);
    // We don't need to call this method any more. It will interrupt user defined game pause&resume logic
    /* cocos2d::Director::getInstance()->pause(); */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
      Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    */

    SdkManager::applicationDidBecomeActive(application);    // We don't need to call this method any more. It will interrupt user defined game pause&resume logic
    /* cocos2d::Director::getInstance()->resume(); */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
      Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
      If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
    */
    SdkManager::applicationDidEnterBackground(application);
    cocos2d::Application::getInstance()->applicationDidEnterBackground();
    if (CAAgent.isInited) {
        [CAAgent onPause];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
      Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
    */
    auto glview = (__bridge CCEAGLView*)(Director::getInstance()->getOpenGLView()->getEAGLView());
    auto currentView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    if (glview == currentView) {
        SdkManager::applicationWillEnterForeground(application);
        cocos2d::Application::getInstance()->applicationWillEnterForeground();
    }
    if (CAAgent.isInited) {
        [CAAgent onResume];
    }
    Director::getInstance()->purgeCachedData();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
      Called when the application is about to terminate.
      See also applicationDidEnterBackground:.
    */
    SdkManager::applicationWillTerminate(application);
    if (s_sharedApplication != nullptr)
    {
        delete s_sharedApplication;
        s_sharedApplication = nullptr;
    }
    [CAAgent onDestroy];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return SdkManager::applicationOpenURL(app, url, options);
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
      Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
    */
    Director::getInstance()->purgeCachedData();
}


#if __has_feature(objc_arc)
#else
- (void)dealloc {
    [window release];
    [_viewController release];
    [super dealloc];
}
#endif


@end
