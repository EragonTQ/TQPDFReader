//
//  PDFOtherViewTools.m
//  PDFReaderDemo
//
//  Created by litianqi on 2018/7/12.
//  Copyright © 2018年 tqUDown. All rights reserved.
//

#import "PDFOtherViewTools.h"
#import "TQPDFReader.h"
@implementation PDFOtherViewTools
+ (void)loadHistoryView:(UIView *)containerView withCurrentPage:(NSInteger)pageIndex{
    if (pageIndex <= 1) {
        return;
    }
    
    UIView * viewHistory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerView.frame.size.width,40)];
    [viewHistory setBackgroundColor:[UIColor colorWithRed:100.0/255 green:156.0/255 blue:240.0/255 alpha:1]];
    [containerView addSubview:viewHistory];
    viewHistory.alpha = 0;
    
    NSString * textHistory = [NSString stringWithFormat:@"您上次浏览到第%ld页",pageIndex];
    UILabel * labelText = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 200, 13)];
    [labelText setCenter:CGPointMake(viewHistory.frame.size.width/2, viewHistory.frame.size.height/2)];
    [labelText setTextAlignment:NSTextAlignmentCenter];
    [labelText setTextColor:[UIColor whiteColor]];
    [labelText setFont:[UIFont systemFontOfSize:14]];
    [labelText setText:textHistory];
    [viewHistory addSubview:labelText];
    
    [UIView animateWithDuration:0.8 animations:^{
        viewHistory.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:0.5 options:0 animations:^{
            viewHistory.alpha = 0;
        } completion:^(BOOL finished) {
            [viewHistory removeFromSuperview];
        }];
    }];
    
}


+ (UIView *)loadErrorView:(UIView *)viewContainer{
    UIView * viewError = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewContainer.frame.size.width,PDFReader_Screen_height_Seat)];
    [viewError setBackgroundColor:[UIColor whiteColor]];
    
    NSInteger imgY = 178 * PDFReader_Screen_widthScale;
    UIImageView * imagV = [[UIImageView alloc] initWithFrame:CGRectMake(139, imgY, 97, 84)];
    [imagV setCenter:CGPointMake(viewError.frame.size.width/2, imagV.center.y)];
    
    
    [imagV setImage:PDFReaderImage(@"icon_failure")];
    [viewError addSubview:imagV];
    
    UILabel * labelText = [[UILabel alloc] initWithFrame:CGRectMake(0,imagV.frame.origin.y +imagV.frame.size.height +12, 200, 13)];
    [labelText setCenter:CGPointMake(imagV.center.x, labelText.center.y)];
    [labelText setTextAlignment:NSTextAlignmentCenter];
    [labelText setTextColor:[UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1]];
    [labelText setFont:[UIFont systemFontOfSize:14]];
    [labelText setText:@"打开失败，返回重试~"];
    [viewError addSubview:labelText];
    [viewContainer addSubview:viewError];
    [viewContainer bringSubviewToFront:viewError];
    return viewError;
}



@end
