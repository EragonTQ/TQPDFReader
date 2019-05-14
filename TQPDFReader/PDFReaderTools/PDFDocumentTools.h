//
//  PDFFileManeger.h
//  PDFReader
//
//  Created by litianqi on 16/12/6.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface PDFDocumentTools : NSObject
+ (NSString *)getPdfPathByFile:(NSString *)fileName;
+ (CGPDFDocumentRef)pdfRefByFilePath:(NSString * _Nonnull )aFilePath;
@end
