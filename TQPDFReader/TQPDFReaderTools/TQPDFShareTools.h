//
//  TQPDFShareTools.h
//  PDFReaderDemo
//
//  Created by litianqi on 2018/7/10.
//  Copyright © 2018年 tqUDown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ShareBlock)(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError);

@interface TQPDFShareTools : NSObject
+ (void)shareViewController:(UIViewController * _Nullable)viewController  filePath:(NSString *_Nullable)filePath shareBlock:(ShareBlock  _Nullable )block;
@end
