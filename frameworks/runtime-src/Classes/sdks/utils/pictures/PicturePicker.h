//
//  PicturePicker.h
//  Smart_Pi
//
//  暂时不支持编辑功能。
//
//  Created by 朱嘉灵 on 2020/1/14.
//

#ifndef PicturePicker_h
#define PicturePicker_h

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>

@interface PicturePicker : NSObject
{
    UIViewController* _viewController;
    
    NSString* _key;
    NSString* _filename;
    void* _owner;
}

-(id) initWithKey:(NSString*)key :(void*)owner;
-(void) takeOrPickPhoto:(NSString*)filename;
-(void) takePhoto:(NSString*)filename;
-(void) pickPhoto:(NSString*)filename;

@end
#endif

#endif /* PicturePicker_h */
