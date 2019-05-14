//
//  DownLoadedDataManager.m
//  PDFReader
//
//  Created by litianqi on 16/12/12.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import "DownLoadedTempDataManager.h"

@implementation DownLoadedTempDataManager

+ (NSData *)getResumeData:(NSString *)taskDescription{
    NSDictionary * dicResumeData =  [[NSUserDefaults standardUserDefaults] objectForKey:taskDescription];
    if (dicResumeData && [dicResumeData isKindOfClass:[NSDictionary class]]) {
        NSData * resumeData = dicResumeData[taskDescription];
        return resumeData;
    }
    return nil;
}

+ (float)getResumeDataPercent:(NSString *)taskDescription{
    if (!taskDescription) {
        return 0;
    }
    NSDictionary * dicResumeData =  [[NSUserDefaults standardUserDefaults] objectForKey:taskDescription];
    if (dicResumeData && [dicResumeData isKindOfClass:[NSDictionary class]]) {
        NSNumber * numPercent = dicResumeData[@"percent"];
        return [numPercent floatValue];
    }
    return 0.0;
}

+ (void)setResumeDataToLocal:(NSData *)resumeData withPercent:(float)percentDownload withTaskDescription:(NSString *)taskDescription{
    if (!resumeData) {
        return;
    }
    
    NSDictionary * dicResumeData = [[NSDictionary alloc] initWithObjectsAndKeys:resumeData,taskDescription,@(percentDownload),@"percent", nil];
    [[NSUserDefaults standardUserDefaults] setObject:dicResumeData forKey:taskDescription];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeResumeData:(NSString *)taskDescription{
    if (!taskDescription) {
        return;
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:taskDescription]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:taskDescription];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
