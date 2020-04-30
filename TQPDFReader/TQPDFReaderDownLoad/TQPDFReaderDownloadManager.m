
//  TQPDFReaderDownloadManager.m
//  PDFReader
//
//  Created by litianqi on 16/12/8.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import "TQPDFReaderDownloadManager.h"
//#import "PDFReaderURLSession.h"
//#import "PDFReaderURLSessionDataTask.h"
#import "TQPDFReaderFileManager.h"
#import <UIKit/UIKit.h>
#import "TQDownLoadedTempDataManager.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
static NSString * const DownLoadManagerIdentifier = @"DownLoadManagerDemo";
@interface TQPDFReaderDownloadManager()<NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession * urlSession;
//@property (nonatomic, copy) DownloadBlock downLoadedBlock;
@property (nonatomic, strong) NSMutableArray * downLoadingArray;
@property (nonatomic,strong) NSData * resumeData;

@end

@implementation TQPDFReaderDownloadManager
+ (TQPDFReaderDownloadManager *)shareInstance{
    static TQPDFReaderDownloadManager * readerManagerInstance = nil;
    static dispatch_once_t  onceToken ;
    dispatch_once(&onceToken, ^{
        readerManagerInstance = [[TQPDFReaderDownloadManager alloc] init];
    });
    return readerManagerInstance;

}

- (id)init{
    if (self = [super init]) {
        [self urlSession];
    }
    return self;
}


- (NSMutableArray *)downLoadingArray{
    if (!_downLoadingArray) {
        _downLoadingArray = [[NSMutableArray alloc] init];
    }
    return _downLoadingArray;
}
- (NSURLSession *)urlSession{
    if (_urlSession == nil) {
        _urlSession = [self backgroundSession];
    }
    return _urlSession;
}
-(NSURLSession*)backgroundSession{
    static NSURLSession * backgroundSession = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:DownLoadManagerIdentifier];
        config.discretionary =YES;
        config.HTTPMaximumConnectionsPerHost =20;
        backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    return backgroundSession;
}

- (void)startDownLoadFile:( NSString * _Nonnull)filePath{
     NSString * downLoadTaskDescription = [TQPDFReaderFileManager cachedFileNameForKey:filePath];
    [self.urlSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        BOOL isExistTask = NO;
        for (NSURLSessionDownloadTask *task in downloadTasks) {
            if ([task.taskDescription isEqualToString:downLoadTaskDescription]) {
                isExistTask = YES;
            }
            else{
                [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    [TQDownLoadedTempDataManager setResumeDataToLocal:resumeData withPercent:0 withTaskDescription:task.taskDescription];
                }];
                
            }
        }
        
        if (!isExistTask) {
            [self resumeTask:filePath];
        }
        
    }];
    
}

- (void)resumeTask:(NSString *)filePath{
    NSString * downLoadTaskDescription = [TQPDFReaderFileManager cachedFileNameForKey:filePath];
    NSData * resumeData = [TQDownLoadedTempDataManager getResumeData:downLoadTaskDescription];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        resumeData = [self correctResumeData:resumeData];
    }
    
    if (resumeData) {
        NSURLSessionDownloadTask * downLoadTask = [self.urlSession downloadTaskWithResumeData:resumeData];
        downLoadTask.taskDescription = downLoadTaskDescription;
        [downLoadTask resume];
        NSLog(@"start a resume download task");
        return;
    }
    filePath = [ filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * urlOfPath = [NSURL URLWithString:filePath];
    NSURLSessionDownloadTask * downLoadTask = [self.urlSession downloadTaskWithRequest:[NSURLRequest requestWithURL:urlOfPath]];
    [downLoadTask setTaskDescription:downLoadTaskDescription];
    [downLoadTask resume];
    NSLog(@"start a new download Task");

}


- (void)stopDownLoadFile:(NSString * _Nonnull )filePath{
    NSString * downLoadTaskDescription = [TQPDFReaderFileManager cachedFileNameForKey:filePath];
    [self.urlSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        for (NSURLSessionDownloadTask * task in downloadTasks) {
            if (!filePath) {
                [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    [TQDownLoadedTempDataManager setResumeDataToLocal:resumeData withPercent:0 withTaskDescription:task.taskDescription];
                }];
                continue;
            }
            
            if ([task.taskDescription isEqualToString:downLoadTaskDescription]) {
                [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                   [TQDownLoadedTempDataManager setResumeDataToLocal:resumeData withPercent:0 withTaskDescription:task.taskDescription];
                }];
                break;
            }
         
        }
    }];
}

- (void)getDownLoadTaskStatus:(NSString *)fileUrl withBlock:(void (^)(NSURLSessionTaskState status))block{
    if (!fileUrl) {
        block(-1);
        return;
    }
    
    NSString * description = [TQPDFReaderFileManager cachedFileNameForKey:fileUrl];
    [self.urlSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        
        BOOL isCreated = NO;//已经存在
        if (downloadTasks && downloadTasks.count >0) {
            for (NSURLSessionDownloadTask * task in downloadTasks) {
                if ([task.taskDescription  isEqualToString:description]) {
                    isCreated = YES;
                    block(task.state);
                    break;
                }
            }
        }
        
        //没有run
        if (!isCreated) {
            NSData * resumeData = [TQDownLoadedTempDataManager getResumeData:description];
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
                resumeData = [self correctResumeData:resumeData];
            }
            if (resumeData) {//暂停
                return block(NSURLSessionTaskStateSuspended);
            }
            else
                block(-1);

        }
        /*
        if (!isCreated) {
             block(-1);
        }
         */
     }];

}

- (float)getFileDownloadedPercent:(NSString *)filePath{
    NSString * downLoadTaskDescription = [TQPDFReaderFileManager cachedFileNameForKey:filePath];
    return [TQDownLoadedTempDataManager getResumeDataPercent:downLoadTaskDescription];
    
}

#pragma mark --NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    if (totalBytesExpectedToWrite > 0 ) {
        float percentDownload = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        [self.downLoadDelegate downLoadingPercent:percentDownload totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"finished======%@",location.path);
    //TODO: move
    NSString * localFilePath = [TQPDFReaderFileManager moveFileFrom:location.path withNewName:downloadTask.taskDescription];
    [TQDownLoadedTempDataManager removeResumeData:downloadTask.taskDescription];
    
    if (self.downLoadDelegate && [self.downLoadDelegate respondsToSelector:@selector(downLoadFinished:error:)]) {
        NSError * error = nil;
        if (!localFilePath) {
            error = [NSError errorWithDomain:@"move 失败" code:-1 userInfo:nil];
        }
        
        [self.downLoadDelegate downLoadFinished:localFilePath error:error];
     
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
   
    if (error && error.code !=-999) {
        [TQDownLoadedTempDataManager removeResumeData:task.taskDescription];
        NSLog(@"error:%@",error);
    }
    if (error &&error.code != -999 && self.downLoadDelegate && [self.downLoadDelegate respondsToSelector:@selector(downLoadFinished:error:)]) {
        [self.downLoadDelegate downLoadFinished:@""  error:error];
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    //NSLog(@"test");
}

- (NSData*)correctResumeData:(NSData*)data
{
    NSString const * kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
    NSString const * kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
    
    if (!data) return nil;
    
    NSMutableDictionary* iresumeDictionary = nil;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        id root  = nil;
        id keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        NSError* err;
        
        root = [keyedUnarchiver decodeTopLevelObjectForKey:@"NSKeyedArchiveRootObjectKey" error:&err];
        if (!root) {
            root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:&err];
        }
        
        
        if (err) {
            return nil;
        }
        
        [keyedUnarchiver finishDecoding];
        
        if (root) {
            iresumeDictionary = [[NSMutableDictionary alloc] initWithDictionary:root];
        }
        
        
    }
    
    NSError* err;
    if (iresumeDictionary == nil) {
        
        id dict = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:&err];
        if (!err) {
            iresumeDictionary = [[NSMutableDictionary alloc] initWithDictionary:dict];
        }
    }
    
    NSMutableDictionary* resumeDictionary = iresumeDictionary.mutableCopy;
    
    resumeDictionary[kResumeCurrentRequest] = [self correctData:resumeDictionary[kResumeCurrentRequest]];
    resumeDictionary[kResumeOriginalRequest] = [self correctData:resumeDictionary[kResumeOriginalRequest]];
    
    NSData* result = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:&err];
    
    if (!result) {
        return nil;
    }
    return result;
}


- (NSData*)correctData:(NSData*)data
{
    if (!data) {
        return nil;
    }
    
    if ([NSKeyedUnarchiver unarchiveObjectWithData:data]) {
        return data;
    }
    
    NSMutableDictionary* archive;
    NSError* err;
    
    archive = [[NSMutableDictionary alloc] initWithDictionary:[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:&err]];
    
    if (err) {
        return nil;
    }
    
    @try {
        int k = 0;
        
        while (archive[@"$objects"][1][[NSString stringWithFormat:@"$%d", k]]) {
            k += 1;
        }
        
        int i = 0;
        while (archive[@"$objects"][1][[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%d", i]]) {
            
            NSMutableArray* arr = [[NSMutableArray alloc] initWithArray:archive[@"$objects"]];
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:arr[1]];
            id obj = dic[[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%d", i]];
            if (obj) {
                [dic setObject:obj forKey:[NSString stringWithFormat:@"$%d", i+k]];
                [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%d", i]];
                arr[1] = dic;
                archive[@"$objects"] = arr;
            }
            
            i += 1;
        }
        
        if (archive[@"$objects"][1][@"__nsurlrequest_proto_props"]) {
            NSMutableArray* arr =  [[NSMutableArray alloc] initWithArray:archive[@"$objects"]];
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:arr[1]];
            id obj = dic[@"__nsurlrequest_proto_props"];
            if (obj) {
                [dic setObject:obj forKey:[NSString stringWithFormat:@"$%d", i+k]];
                [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
                arr[1] = dic;
                archive[@"$objects"] = arr;
            }
        }
        
        // Rectify weird "NSKeyedArchiveRootObjectKey" top key to NSKeyedArchiveRootObjectKey = "root"
        if (archive[@"$top"][@"NSKeyedArchiveRootObjectKey"] != nil){
            id obj = archive[@"$top"][@"NSKeyedArchiveRootObjectKey"];
            [archive[@"$top"] setObject:obj forKey:NSKeyedArchiveRootObjectKey];
            [archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
        }
    } @catch (NSException *exception) {
        NSLog(@"<ResumeDataCorrect> catch exp %@", exception);
    } @finally {
        // Reencode archived object
        NSData* result = [NSPropertyListSerialization dataWithPropertyList:archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:&err];
        
        if (err) {
            return nil;
        }
        
        return result;
    }
    
}

- (void)dealloc{
//    DDLogInfo(@"dealloc TQPDFReaderDownloadManager ");
}


@end
