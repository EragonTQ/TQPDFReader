//
//  PDFOtherViewTools.h
//  PDFReaderDemo
//
//  Created by litianqi on 2018/7/12.
//  Copyright © 2018年 tqUDown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PDFOtherViewTools : NSObject
+ (void)loadHistoryView:(UIView *)containerView withCurrentPage:(NSInteger)pageIndex;
+ (UIView *)loadErrorView:(UIView *)viewContainer;
@end
