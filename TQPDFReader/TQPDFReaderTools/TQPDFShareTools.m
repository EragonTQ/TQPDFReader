//
//  TQPDFShareTools.m
//  PDFReaderDemo
//
//  Created by litianqi on 2018/7/10.
//  Copyright © 2018年 tqUDown. All rights reserved.
//

#import "TQPDFShareTools.h"
#define kPDFScanViewController_Device_is_iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )

@implementation TQPDFShareTools
#pragma mark -- 分享

+ (void)removeTmpFile:(NSString *)cacheFilePath{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (cacheFilePath.length > 0) {
            NSFileManager * fileM = [NSFileManager defaultManager];
            if ([fileM fileExistsAtPath:cacheFilePath]) {
                [fileM removeItemAtPath:cacheFilePath error:nil];
                
            }
        }
    });
    
}


+ (NSString *)getFileCopyPath:(NSString *)filePath viewController:(UIViewController *)viewController{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    // 获取Caches目录路径
    NSString *cachesDir = NSTemporaryDirectory();
    NSString * cachaPathFile = [cachesDir stringByAppendingPathComponent:@"Ebook"];
    BOOL isDir = FALSE;
    if (![fileManager fileExistsAtPath:cachaPathFile isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:cachaPathFile withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString * suffix = filePath.pathExtension;
    cachaPathFile = [cachaPathFile stringByAppendingFormat:@"/%@.%@",viewController.title,suffix];
    NSError * error = nil;
    if (![fileManager fileExistsAtPath:filePath]) {//不存在
        return @"";
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachaPathFile]) {
        if([[NSFileManager defaultManager] copyItemAtPath:filePath toPath:cachaPathFile error:&error]){
        }else{
            NSLog(@"%s%@",__func__,error);
            cachaPathFile = @"";//copy failure
        }
        
    }
    return cachaPathFile;
}
+ (void)shareViewController:(UIViewController * _Nullable)viewController  filePath:(NSString *_Nullable)filePath shareBlock:(ShareBlock  _Nullable )block{
    NSMutableArray * itemArray = @[].mutableCopy;
    NSURL *url = nil;
    NSString * copyFilePath = @"";
    if (filePath && ![filePath hasPrefix:@"http"]) {
        copyFilePath = [[self class]getFileCopyPath:filePath viewController:viewController];
        if (copyFilePath.length > 0) {
             url = [NSURL fileURLWithPath:copyFilePath];
        }else
            url = [NSURL fileURLWithPath:filePath];
    }else
        url = [NSURL URLWithString:filePath];
    
    if (url) {
        [itemArray addObject:url];
    }
    
    UIActivityViewController *avc = [[UIActivityViewController alloc]initWithActivityItems:itemArray.copy applicationActivities:nil];
    
    NSMutableArray * excludeArray = @[UIActivityTypePostToFacebook,
                                      UIActivityTypePostToTwitter,
                                      UIActivityTypePostToWeibo,
                                      UIActivityTypeMail,
                                      UIActivityTypeMessage,
                                      UIActivityTypePrint,
                                      UIActivityTypeCopyToPasteboard,
                                      UIActivityTypeAssignToContact,
                                      UIActivityTypeSaveToCameraRoll,
                                      UIActivityTypeAddToReadingList,
                                      UIActivityTypePostToFlickr,
                                      UIActivityTypePostToVimeo,
                                      UIActivityTypePostToTencentWeibo,
                                      UIActivityTypeAirDrop,
                                      ].mutableCopy;
    
    
//    NSString *sysVersion = [UIDevice currentDevice].systemVersion;
//    CGFloat version = [sysVersion floatValue];
    
        if (@available(iOS 11.0, *)) {
            [excludeArray addObject:UIActivityTypeMarkupAsPDF];
        } else {
            // Fallback on earlier versions
        }
    
        if (@available(iOS 9.0, *)) {
            [excludeArray addObject:UIActivityTypeOpenInIBooks];
        } else {
            // Fallback on earlier versions
        }
    
    avc.excludedActivityTypes = excludeArray.copy;
    
    __weak typeof(self) weakSelf = viewController;
    [avc setCompletionWithItemsHandler:^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        __strong typeof(self) strongSelf = weakSelf;
        if (block) {
            block(activityType,completed,returnedItems,activityError);
        }
        [[TQPDFShareTools class] removeTmpFile:copyFilePath];
    }];
    if (kPDFScanViewController_Device_is_iPad) {
        if (viewController.navigationItem.rightBarButtonItem != nil) {
            avc.popoverPresentationController.barButtonItem = viewController.navigationItem.rightBarButtonItem;
        } else {
            UIPopoverPresentationController *popover = avc.popoverPresentationController;
            if (popover != nil){
                popover.sourceView = viewController.view;
                popover.sourceRect = CGRectMake(0, viewController.view.frame.size.height, viewController.view.frame.size.width, 0);;
                popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
            }
        }
    }
    [viewController presentViewController:avc animated:YES completion:nil];
    
        
    

}

@end
