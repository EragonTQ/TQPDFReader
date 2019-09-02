//
//  PDFScanViewController.h
//  PDFReader
//
//  Created by litianqi on 16/12/7.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFReaderFileManager.h"
NS_ASSUME_NONNULL_BEGIN





typedef void(^ShareBlock)(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError);

typedef void(^OpenErrorBlock)(NSError * __nullable error);
@interface PDFScrollView : UIScrollView<UIGestureRecognizerDelegate>

@end

@interface PDFPageCollectionCell : UICollectionViewCell
@property (nonatomic) CGPDFPageRef pageRef;
/** pageNum */
@property (nonatomic, assign) NSInteger pageNum;

@end


@interface PDFScanViewController : UIViewController
@property (nonatomic,strong) NSString * urlFile;
@property (assign, nonatomic) ResourceType_PDFReader  resourseType;
@property (nonatomic,assign) BOOL localFileType;
@property (nonatomic,assign) UILabel * customTitleLabel;
@property (nonatomic,strong) UIColor *quickLocationBtnBGColor;
@property (nonatomic,strong) UIColor *quickLocationBtnTitleColor;

/** openErrorBlock */
@property (nonatomic, copy) OpenErrorBlock openErrorBlock;

/** 分享回调 */
@property (nonatomic, copy) ShareBlock shareBlock;
/** 分享 */
@property (nonatomic, assign) BOOL enableShare;//默认是NO
/*如果采用webview 加载，就不显示下载的过程了，系统控制，否则会有下载的中间进度页面*/
@property (nonatomic, assign) BOOL openByWebView;//默认是NO


@end
NS_ASSUME_NONNULL_END
