//
//  DownLoadedDataManager.h
//  PDFReader
//
//  Created by litianqi on 16/12/12.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownLoadedTempDataManager : NSObject
+ (void)setResumeDataToLocal:(NSData *)resumeData withPercent:(float)percentDownload withTaskDescription:(NSString *)taskDescription;
+ (float)getResumeDataPercent:(NSString *)taskDescription;
+ (NSData *)getResumeData:(NSString *)taskDescription;
+ (void)removeResumeData:(NSString *)taskDescription;
@end
