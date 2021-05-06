//
//  PDFScanViewController.h
//  PDFReader
//
//  Created by litianqi on 16/12/7.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQPDFReaderFileManager.h"
NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger ,TQLPDFEvent) {
    TQLPDFEventUnknown ,
    TQLPDFEventScaleAdd,        ///放大
    TQLPDFEventScaleReduce,      ///减小
    TQLPDFEventSlideDrag,        ///拖动
    TQLPDFEventRotate,           ///旋转
    TQLPDFEventShare,            ///分享
    
    
    TQLPDFEventVertical,    ///竖屏模式观看
    TQLPDFEventHorizontal   ///水平模式观看
    
};


typedef void(^ShareBlock)(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError);

typedef void(^OpenErrorBlock)(NSError * __nullable error);

typedef void(^TQPDFEventBlock)(TQLPDFEvent event);

@interface TQPDFScrollView : UIScrollView<UIGestureRecognizerDelegate>

@end

@interface PDFPageCollectionCell : UICollectionViewCell
@property (nonatomic) CGPDFPageRef pageRef;
/** pageNum */
@property (nonatomic, assign) NSInteger pageNum;

@end


@interface TQPDFScanViewController : UIViewController
+(instancetype)pdfScanVC;


@property (nonatomic,strong) NSString * urlFile;
@property (assign, nonatomic) ResourceType_PDFReader  resourseType;
@property (nonatomic,assign) BOOL localFileType;
@property (nonatomic,assign) UILabel * customTitleLabel;
@property (nonatomic,strong) UIColor *quickLocationBtnBGColor;
@property (nonatomic,strong) UIColor *quickLocationBtnTitleColor;


/** <#name#> */
@property (nonatomic, copy) TQPDFEventBlock eventBlock;
/** openErrorBlock */
@property (nonatomic, copy) OpenErrorBlock openErrorBlock;

/** 分享回调 */
@property (nonatomic, copy) ShareBlock shareBlock;
/** 分享 */
@property (nonatomic, assign) BOOL enableShare;//默认是NO
/*如果采用webview 加载，就不显示下载的过程了，在线观看;
 否则就会采用下载存储的方式，显示的下载的中间进度页面，可以离线观看，建议采用这种方式
 */
@property (nonatomic, assign) BOOL openByWebView;//默认是NO


@end
NS_ASSUME_NONNULL_END
