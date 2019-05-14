//
//  PDFReaderFileManager.h
//  PDFReader
//
//  Created by litianqi on 16/12/8.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger , ResourceType_PDFReader){
    ResourceType_PDFReader_pdf = 0,
    ResourceType_PDFReader_image = 1,
    ResourceType_PDFReader_other
};

@interface PDFReaderFileManager : NSObject

+ (ResourceType_PDFReader )fileTypeFromUrl:(NSString *)url;
+ (NSString *)configBaseDirectory;
+ (NSString *)cachedFileNameForKey:(NSString *)key;
+ (NSString *)getCompleteFileLocalPathFromUrl:(NSString *)url;

+ (NSString *)moveFileFrom:(NSString *)fromPath  withNewName:( NSString *)newName;
+ (BOOL)isExistFileFromUrl:(NSString *)url;
+ (void)deleteDownLoadPdfFile:(NSString * )filePath;


+ (void)setFileScanPercent:(NSNumber*)percent withUrl:(NSString *)url;
//文件浏览进度保存
+ (void)setFileScanPercent:(NSNumber*)percent withUrl:(NSString *)url currentPage:(NSInteger)page;
/*获取历史进度*/
+ (NSNumber *)getFileScanPercentWithUrl:(NSString *)url;
/*获取历史页*/
+ (NSInteger )getFileScanHistoryPageWithUrl:(NSString *)url;

@end

