//
//  PicturePicker.m
//  Smart_Pi-mobile
//
//  Created by 朱嘉灵 on 2020/1/14.
//

#import "PicturePicker.h"
#include "../UtilsSdk.h"
#pragma mark - 01.使用相机相册要导入头文件的
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface PicturePicker ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
#pragma mark - 02.拖线一个imageView控件用来展示选中的图片 & 创建一个弹框;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@end

@implementation PicturePicker
#pragma mark - 03.懒加载初始化弹框;
- (UIImagePickerController *)imagePickerController {
    if (_imagePickerController == nil) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self; //delegate遵循了两个代理
        _imagePickerController.allowsEditing = NO;
    }
    return _imagePickerController;
}

- (id)initWithKey:(NSString*)key :(void*)owner {
    self = [super init];
    
    _key = [NSString stringWithString:key];
    [_key retain];
    _owner = owner;
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    _viewController = [window rootViewController];

    return self;
}

-(void) dealloc {
    if (_key){
        [_key release];
    }
    if (_filename){
        [_filename release];
    }
    [super dealloc];
}

#pragma mark - 05.在租来的触发方法里添加事件;
- (void)takeOrPickPhoto:(NSString*)filename {
    _filename = [NSString stringWithString:filename];
    [_filename retain];
    //MARK: - 06.点击图片调起弹窗并检查权限;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"使用相机拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self checkCameraPermission];//调用检查相机权限方法
    }];
    UIAlertAction *album = [UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self checkAlbumPermission];//调起检查相册权限方法
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [_viewController dismissViewControllerAnimated:YES completion:nil];
        [self response:@""];
    }];

    [alert addAction:camera];
    [alert addAction:album];
    [alert addAction:cancel];

    [_viewController presentViewController:alert animated:YES completion:nil];
}

- (void)takePhoto:(NSString *)filename
{
    _filename = [NSString stringWithString:filename];
    [_filename retain];
    
    [self checkCameraPermission];
}

#pragma mark - Camera(检查相机权限方法)
- (void)checkCameraPermission {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [self callCamera];
            }
        }];
    } else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
//        [self alertAlbum];//如果没有权限给出提示
        [self response:@""];
    } else {
        [self callCamera];//有权限进入调起相机方法
    }
}

- (void)callCamera {
#pragma mark - 07.判断相机是否可用，如果可用调起
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [_viewController presentViewController:self.imagePickerController animated:YES completion:^{}];
    } else {//不可用只能GG了
        NSLog(@"木有相机");
        [self response:@""];
    }
}

- (void)pickPhoto:(NSString *)filename
{
    _filename = [NSString stringWithString:filename];
    [_filename retain];
    
    [self checkAlbumPermission];
}

#pragma mark - Album(相册流程与相机流程相同,相册是不存在硬件问题的,只要有权限就可以直接调用)
- (void)checkAlbumPermission {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    [self selectAlbum];
                }
            });
        }];
    } else if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        [self alertAlbum];
    } else {
        [self selectAlbum];
    }
}

- (void)selectAlbum {
    //判断相册是否可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [_viewController presentViewController:self.imagePickerController animated:YES completion:^{}];
    }
}

- (void)alertAlbum {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请在设置中打开相册" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [_viewController dismissViewControllerAnimated:YES completion:nil];
        [self response:@""];
    }];
    [alert addAction:cancel];
    [_viewController presentViewController:alert animated:YES completion:nil];
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_2_0,__IPHONE_3_0)
//{
//    [picker dismissViewControllerAnimated:YES completion:nil];
//    image = [editingInfo valueForKey:UIImagePickerControllerEditedImage];
//    BOOL result = [UIImageJPEGRepresentation(image, 1) writeToFile:_filename atomically:YES];
//    if (result)
//    {
//        [self response:_filename];
//    }
//    else
//    {
//        [self response:@""];
//    }
//    [self autorelease];
//}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    BOOL result = [UIImageJPEGRepresentation(image, 1) writeToFile:_filename atomically:YES];
    if (result)
    {
        [self response:_filename];
    }
    else
    {
        [self response:@""];
    }
    [self autorelease];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self response:@""];
}

- (void)response:(NSString*)filename
{
    if (_owner)
    {
        UtilsSdk* utils = reinterpret_cast<UtilsSdk*>(_owner);
        utils->callbackToMainThread(_key.UTF8String, filename.UTF8String);
    }
}

@end
