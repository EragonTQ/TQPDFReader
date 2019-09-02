//
//  DownLoadPanelViewController.m
//  PDFReader
//
//  Created by litianqi on 16/12/8.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import "DownLoadPanelViewController.h"
#import "PDFReaderDownloadManager.h"
#import "PDFReaderProgressBarView.h"
#import "PDFReaderFileManager.h"
#import "TQPDFReader.h"

@interface DownLoadPanelViewController ()<PDFReaderDownloadManagerDelegate>
@property (nonatomic,weak) IBOutlet UILabel *currentProgressLabel;
@property (nonatomic,weak) IBOutlet PDFReaderProgressBarView * progressView;
@property (nonatomic,weak) IBOutlet UIButton * continueBtn;
@property (nonatomic,weak) IBOutlet UIImageView * imageResourceView;

@property (nonatomic,weak) IBOutlet UIButton * pauseBtn;
@end

@implementation DownLoadPanelViewController

- (void)dealloc{
    NSLog(@"delloc%@",[self class]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.progressView setForeGColor:[UIColor colorWithRed:44.0/255.0 green:192.0/255.0 blue:92.0/255.0 alpha:1]];
    [self.progressView setBackGColor:[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1]];
    
    [[PDFReaderDownloadManager shareInstance] setDownLoadDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.fileNameLabel.text = self.title;
    NSString * nameFile = [self.title stringByDeletingPathExtension];
    if (nameFile && nameFile.length > 15) {
        nameFile = [NSString stringWithFormat:@"%@...%@",[nameFile substringToIndex:8],[nameFile substringFromIndex:nameFile.length -7]];
        nameFile = [NSString stringWithFormat:@"%@.%@",nameFile,[self.title pathExtension]];
        self.fileNameLabel.text = nameFile;
    }

    
    if (self.resourseType == ResourceType_PDFReader_image) {
        [_imageResourceView setImage:PDFReaderImage(@"type_jpp_icon")];
    }
    else
        [_imageResourceView setImage:PDFReaderImage(@"icon_pd_big")];
    
    
    [[PDFReaderDownloadManager shareInstance] getDownLoadTaskStatus:self.fileUrl withBlock:^(NSURLSessionTaskState status) {
        if (NSURLSessionTaskStateRunning == status) {
            [self setPauseForUI:NO];
            
        }
        else if (status < 0){//未下载
            [self clickContinueLoad:nil];
        }
        else if ( status == NSURLSessionTaskStateSuspended){
            [self setPauseForUI:YES];
        }
        else{
            [self setPauseForUI:YES];
        }

    }];
    return;
}


- (void)pop_downLoadPanerViewController{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickPauseLoad:(id)sender{
//    DDLogInfo(@"pause download :%@",[self class]);
    [[PDFReaderDownloadManager shareInstance] stopDownLoadFile:nil];
    self.continueBtn.hidden = NO;
    [self setPauseForUI:YES];
}

- (IBAction)clickContinueLoad:(id)sender{
//     DDLogInfo(@"continue download :%@",[self class]);
    [self setPauseForUI:NO];
    NSString * urlfile = self.fileUrl;
    [[PDFReaderDownloadManager shareInstance]  startDownLoadFile:urlfile];

}

- (void)setPauseForUI:(BOOL )isPause{
    self.continueBtn.hidden = isPause;
    self.currentProgressLabel.hidden = isPause;
    self.pauseBtn.hidden = isPause;
    self.progressView.hidden = isPause;
    self.continueBtn.hidden =!isPause;
    [self.continueBtn setTitle:@"继续下载" forState:UIControlStateNormal];
}

- (void)setErrorStatusForUI:(BOOL)isError{
    self.progressView.hidden = YES;
    self.pauseBtn.hidden = YES;
    self.continueBtn.hidden = NO;
    [self.continueBtn setTitle:@"重新尝试" forState:UIControlStateNormal];
    
}


#pragma mark -- PDFReaderDownloadManagerDelegate
- (void)downLoadingPercent:(float)percentDownload totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    float totalRecived =  (float)totalBytesWritten/(1024.0*1024);
    float totalExpected =  (float)totalBytesExpectedToWrite/(1024.0*1024);

    self.currentProgressLabel.text = [NSString stringWithFormat:@"下载中...(%.2fM/%.2fM)",totalRecived,totalExpected];
    self.progressView.progressValue = percentDownload;
}

- (void)downLoadFinished:(NSString *)localPathFile error:(NSError *)error{
    if (error) {
        [self setErrorStatusForUI:YES];
        [SVProgressHUD showErrorWithStatus:@"下载失败"];
        return;
    }
  
    self.finishedDownLoaded(localPathFile);
    [self pop_downLoadPanerViewController];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
