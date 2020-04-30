//
//  TQPDFReaderDownloadManager.h
//  PDFReader
//
//  Created by litianqi on 16/12/8.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ DownloadBlock)(NSString *  downLoadedFilePath,BOOL success, NSError * error) ;


@protocol TQPDFReaderDownloadManagerDelegate <NSObject>
- (void)downLoadingPercent:(float)percentDownload  totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
//error 不为nil 就是错误了
- (void)downLoadFinished:(NSString *)localPathFile  error:(NSError*)error;
@end

@interface TQPDFReaderDownloadManager : NSObject
@property (nonatomic, weak)id<TQPDFReaderDownloadManagerDelegate> downLoadDelegate;
+ (TQPDFReaderDownloadManager *)shareInstance;
- (void)startDownLoadFile:(NSString * )filePath;
- (void)stopDownLoadFile:(NSString * )filePath;

- (float)getFileDownloadedPercent:(NSString *)filePath;

- (void)getDownLoadTaskStatus:(NSString *)fileUrl withBlock:(void (^)(NSURLSessionTaskState status))block;
@end
