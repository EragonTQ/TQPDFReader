//
//  TQPDFReaderLog.h
//  TQPDFReader
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TQPDFLogEvent) {
    TQPDFLogEventDownloadStart,
    TQPDFLogEventDownloadProgress,
    TQPDFLogEventDownloadSuccess,
    TQPDFLogEventDownloadFailure
};

FOUNDATION_EXPORT NSString * const TQPDFLogInfoURLKey;
FOUNDATION_EXPORT NSString * const TQPDFLogInfoProgressKey;
FOUNDATION_EXPORT NSString * const TQPDFLogInfoBytesWrittenKey;
FOUNDATION_EXPORT NSString * const TQPDFLogInfoTotalBytesKey;
FOUNDATION_EXPORT NSString * const TQPDFLogInfoLocalPathKey;
FOUNDATION_EXPORT NSString * const TQPDFLogInfoErrorKey;

typedef void (^TQPDFLogBlock)(TQPDFLogEvent event,
                              NSString *message,
                              NSDictionary<NSString *, id> * _Nullable info);

NS_ASSUME_NONNULL_END
