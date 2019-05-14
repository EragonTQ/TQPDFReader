//
//  DownLoadPanelViewController.h
//  PDFReader
//
//  Created by litianqi on 16/12/8.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFReaderFileManager.h"
typedef void (^FinishedDownLoad)(NSString * downLoadedlocalPath);

@interface DownLoadPanelViewController : UIViewController
@property (nonatomic,weak) IBOutlet UILabel * fileNameLabel;
@property (nonatomic,strong) NSString * fileUrl;
@property (nonatomic,copy) FinishedDownLoad  finishedDownLoaded;
@property (assign, nonatomic) ResourceType_PDFReader  resourseType;
- (IBAction)clickContinueLoad:(id)sender;
- (IBAction)clickPauseLoad:(id)sender;
- (void)pop_downLoadPanerViewController;
@end
