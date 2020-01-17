//
//  PhotoPicker.h
//  Smart_Pi
//
//  暂时不支持编辑功能。
//
//  Created by 朱嘉灵 on 2020/1/14.
//

#ifndef PhotoPicker_h
#define PhotoPicker_h

#include "cocos2d.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>

@interface PhotoPicker : NSObject
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

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

#include <string>

class PhotoPicker
{
private:
    std::string _key;
    std::string _filename;
    void* _owner;
public:
    PhotoPicker(const std::string& key, void* owner) : _key(key), _owner(owner) { }
    ~PhotoPicker() { }

    void takeOrPickPhoto(const std::string& filename);
    void takePhoto(const std::string& filename);
    void pickPhoto(const std::string& filename);

    void callActivity(const std::string& method);
    void response(const std::string& filename);
};
#endif

#endif /* PhotoPicker_h */
