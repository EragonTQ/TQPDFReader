//
//  TQPDFReaderProgressBarView.m
//  edu24app
//
//  Created by litianqi on 16/3/4.
//  Copyright © 2016年 edu24ol. All rights reserved.
//

#import "TQPDFReaderProgressBarView.h"

@implementation TQPDFReaderProgressBarView

-(void)setProgressValue:(float)progressValue{
    _progressValue = progressValue;
    [self setNeedsDisplay];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (_foreGColor == nil) {
        _foreGColor = [UIColor blueColor];
    }
    if (_backGColor == nil) {
        _backGColor  = [UIColor yellowColor];
    }
    
   
     [_backGColor setFill];
     UIBezierPath * pathLineBackGround=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) cornerRadius:self.bounds.size.height/2];
    [pathLineBackGround fill];
    
    [_foreGColor setFill];
    UIBezierPath * pathLineLighten=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width*_progressValue, self.bounds.size.height) cornerRadius:self.bounds.size.height/2];
    [pathLineLighten fill];
    

    
//    CAShapeLayer * shapeLayer=[CAShapeLayer new];
//    shapeLayer.fillColor=[UIColor colorWithHexString:@"0x2ebff4"].CGColor;
////    shapeLayer.strokeColor=[UIColor colorWithRed:98.0/255.0 green:227.0/255.0 blue:246.0/255.0 alpha:1].CGColor;
//    
//    shapeLayer.lineWidth=1;
//    shapeLayer.lineCap = kCALineCapRound;
//    shapeLayer.path=pathLineBackGround.CGPath;
//    [self.layer addSublayer:shapeLayer];
    
}


@end
