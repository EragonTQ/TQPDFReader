//
//  ViewController.m
//  TQPDFReaderDemo
//
//  Created by litianqi on 2019/5/14.
//  Copyright © 2019 edu24ol. All rights reserved.
//

#import "ViewController.h"
#import <PDFScanViewController.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"002" ofType:@"PDF"];
    path = @"https://edu100hqvideo.bs2cdn.98809.com/北京市基本概况（一）_3b8fa57ea22ae5acd5dd252904c8740337b810a5.pdf";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        PDFScanViewController * pdfVC = [[UIStoryboard  storyboardWithName:@"PdfStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PDFScanViewController"];
      
        pdfVC.enableShare = YES;
      
        pdfVC.openErrorBlock = ^(NSError *error){
            
        };
        pdfVC.urlFile = path;
//        pdfVC.resourseType = ResourceType_PDFReader_pdf;
//        pdfVC.openByWebView = YES;
        [self.navigationController pushViewController:pdfVC animated:YES];
    });
}


@end
