//
//  TQPDFReaderFileManager.m
//  PDFReader
//
//  Created by litianqi on 16/12/8.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import "TQPDFReaderFileManager.h"
#import <CommonCrypto/CommonDigest.h>
static NSString * const kPDFScanViewOffsetY = @"_kPDFScanViewOffsetY";
static NSString * const kPDFScanViewCurrentPage = @"_kPDFScanViewCurrentPage";

@implementation TQPDFReaderFileManager

+ (ResourceType_PDFReader )fileTypeFromUrl:(NSString *)url{
    if (!url) {
        return ResourceType_PDFReader_other;
    }
    NSString * urlLowcase = [url lowercaseString];
    if ([urlLowcase hasSuffix:@".pdf"]) {
        return ResourceType_PDFReader_pdf;
    }
    else if ([urlLowcase hasSuffix:@".jpg"]||[urlLowcase hasSuffix:@".png"]||[urlLowcase hasSuffix:@".jpeg"])
        return ResourceType_PDFReader_image;
    else
        return ResourceType_PDFReader_other;
    
}

+ (NSString *)configBaseDirectory{
    NSString * destinationDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject];
    destinationDirectory = [destinationDirectory stringByAppendingPathComponent:@"LTQ_PDFReader"];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error ;
    if (![fileManager fileExistsAtPath:destinationDirectory]) {
        [fileManager createDirectoryAtPath:destinationDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"create LTQ_PDFReader directory failure\n");
            return @"";
        }
    }
    return destinationDirectory;
}

+ (NSString *)cachedFileNameForKey:(NSString *)key {
    if (key.length > 0 && ![key hasPrefix:@"http"]) {//本地路径-避开沙盒目录变化的问题
        NSString * docLocal = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        key = [key stringByReplacingOccurrencesOfString:docLocal withString:@""];
    }
    
    const char *str = [key UTF8String];
    if (str == NULL) {
        return @"";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];
    
    return filename;
}
/*
+ (NSString *)convertToCommonTextFromUrl:(nonnull NSString * )url{
    
    if (!url) {
        return @"";
    }
    NSString *speciText = @"!*’();:@&=+$,/?%#[]";
    NSString * encodedString =  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, (CFStringRef)speciText, kCFStringEncodingUTF8));
    return encodedString;
}
*/

+ (NSString *)getCompleteFileLocalPathFromUrl:(NSString *)url{
    NSString * nameFile = [TQPDFReaderFileManager cachedFileNameForKey:url];
    return [TQPDFReaderFileManager getCompleteFilePathFromName:nameFile];
}

+ (NSString *)getCompleteFilePathFromName:(NSString *)fileName{
    NSString * basePath = [TQPDFReaderFileManager configBaseDirectory];
    basePath = [basePath stringByAppendingPathComponent:fileName];
    return basePath;
}

+ (BOOL)isExistFileFromUrl:(NSString *)url{
    NSString * pathLocalFile = [TQPDFReaderFileManager getCompleteFileLocalPathFromUrl:url];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:pathLocalFile];
}

+ (NSString *)moveFileFrom:(NSString *)fromPath withNewName:(nonnull NSString *)newName{
    
    NSString * pathBase = [TQPDFReaderFileManager configBaseDirectory];
    NSString * toFilePath = [pathBase stringByAppendingPathComponent:newName];
    NSError * error;
    NSFileManager * fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:toFilePath]) {
        [fileManager removeItemAtPath:toFilePath error:&error];
        if (error) {
            NSLog(@"removeExist file failure\n%@",error);
            return nil;
        }
    }
    
    if (![fileManager moveItemAtPath:fromPath toPath:toFilePath error:&error]) {
        NSLog(@"move file failure%@ path= %@\n",error,toFilePath);
        return nil;
    }
    return toFilePath;
}

+ (void)deleteDownLoadPdfFile:(NSString * )filePath{
    NSString * pathDirectory = [TQPDFReaderFileManager configBaseDirectory];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error = nil;
    if (filePath && filePath.length >0) {
        filePath = [self cachedFileNameForKey:filePath];
        pathDirectory = [pathDirectory stringByAppendingPathComponent:filePath];
        
        if ([fileManager fileExistsAtPath:pathDirectory]) {
            [fileManager removeItemAtPath:pathDirectory error:&error];
            NSLog(@"删除成功%@",pathDirectory);
          
        }else{
            NSLog(@"文件不存在%@",pathDirectory);
        }
        
        if (error) {
            NSLog(@"删除失败%@\n",error);
        }
        
        return;
    }
  
    NSArray *itemArray = [fileManager contentsOfDirectoryAtPath:pathDirectory error:&error];
    if (!itemArray || itemArray.count == 0) {
        NSLog(@"缓存为空，不需要清理~");
        return;
    }
    [itemArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * description = obj;
        description = [description stringByAppendingString:description];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:description];
        
        NSString * keyForFileScanPercent = [obj stringByAppendingString:kPDFScanViewOffsetY];

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyForFileScanPercent];
        
    }];
    
    [fileManager removeItemAtPath:pathDirectory error:&error];
    if (error) {
        NSLog(@"delete PDF file failure:%@",error);
    }
}

+ (NSNumber *)getFileScanPercentWithUrl:(NSString *)url{
    NSString * description = [self cachedFileNameForKey:url];
    description = [description stringByAppendingString:kPDFScanViewOffsetY];
    NSNumber * percentNumber = [[NSUserDefaults standardUserDefaults] objectForKey:description];
    return percentNumber;
}

+ (NSInteger)getFileScanHistoryPageWithUrl:(NSString *)url{
    NSString * description = [self cachedFileNameForKey:url];
    description = [description stringByAppendingString:kPDFScanViewCurrentPage];
    NSNumber * historyPageNumber = [[NSUserDefaults standardUserDefaults] objectForKey:description];
    return historyPageNumber.integerValue;
}

+ (void)setFileScanPercent:(NSNumber*)percent withUrl:(NSString *)url {
    [[self class] setFileScanPercent:percent withUrl:url currentPage:0];
}

+ (void)setFileScanPercent:(NSNumber*)percent withUrl:(NSString *)url currentPage:(NSInteger)page{
    NSString * description = [self cachedFileNameForKey:url];
    
    NSString * keyForPercent = [description stringByAppendingString:kPDFScanViewOffsetY];
    [[NSUserDefaults standardUserDefaults] setObject:percent forKey:keyForPercent];
    
    if (page > 0) {
        NSString * keyForPage = [description stringByAppendingString:kPDFScanViewCurrentPage];
        [[NSUserDefaults standardUserDefaults] setObject:@(page) forKey:keyForPage];
    }
    
}

@end
