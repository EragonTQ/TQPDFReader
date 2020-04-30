//
//  PDFFileManeger.m
//  PDFReader
//
//  Created by litianqi on 16/12/6.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import "TQPDFDocumentTools.h"

@implementation TQPDFDocumentTools
//用于本地pdf文件
+ (CGPDFDocumentRef)pdfRefByFilePath:(NSString * _Nonnull)aFilePath
{
    if (aFilePath.length == 0) {
        return nil;
    }
    
    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    
    path = CFStringCreateWithCString(NULL, [aFilePath UTF8String], kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, NO);
    document = CGPDFDocumentCreateWithURL(url);
    
    CFRelease(path);
    CFRelease(url);
    
    return document;
}

+ (NSString *)getPdfPathByFile:(NSString *)fileName
{
    return [[NSBundle mainBundle] pathForResource:fileName ofType:@".pdf"];
}

@end
