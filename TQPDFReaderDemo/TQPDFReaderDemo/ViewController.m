//
//  ViewController.m
//  TQPDFReaderDemo
//
//  Created by litianqi on 2019/5/14.
//  Copyright © 2019 edu24ol. All rights reserved.
//

#import "ViewController.h"
#import <TQPDFScanViewController.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)clickRemoteBtn:(id)sender
{
    NSString *path = @"https://edu100hqvideo.bs2cdn.98809.com/北京市基本概况（一）_3b8fa57ea22ae5acd5dd252904c8740337b810a5.pdf";
    TQPDFScanViewController * pdfVC = [[UIStoryboard  storyboardWithName:@"TQPdfStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"TQPDFScanViewController"];
    pdfVC.enableShare = YES;
    
    pdfVC.openErrorBlock = ^(NSError *error){
        
    };
    pdfVC.urlFile = path;
    //        pdfVC.resourseType = ResourceType_PDFReader_pdf;
    //        pdfVC.openByWebView = YES;
    [self.navigationController pushViewController:pdfVC animated:YES];
}

- (IBAction)clickLocalBtn:(id)sender
{
    TQPDFScanViewController * pdfVC = [[UIStoryboard  storyboardWithName:@"TQPdfStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"TQPDFScanViewController"];
    pdfVC.enableShare = YES;
    
    pdfVC.openErrorBlock = ^(NSError *error){
        
    };
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"002" ofType:@"PDF"];
    pdfVC.localFileType = YES;
    pdfVC.urlFile = path;
    [self.navigationController pushViewController:pdfVC animated:YES];
}


- (IBAction)clickRemoteIMg:(id)sender
{
    TQPDFScanViewController * pdfVC = [[UIStoryboard  storyboardWithName:@"TQPdfStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"TQPDFScanViewController"];
    pdfVC.enableShare = YES;
    pdfVC.openErrorBlock = ^(NSError *error){
        
    };
    pdfVC.urlFile = @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2534506313,1688529724&fm=26&gp=0.jpg";
    pdfVC.resourseType = ResourceType_PDFReader_image;
    [self.navigationController pushViewController:pdfVC animated:YES];
}

- (IBAction)deleteRemotePdf:(id)sender
{
    NSString * url = @"https://edu100hqvideo.bs2cdn.98809.com/北京市基本概况（一）_3b8fa57ea22ae5acd5dd252904c8740337b810a5.pdf";
    [TQPDFReaderFileManager deleteDownLoadPdfFile:url];
    
}

@end
