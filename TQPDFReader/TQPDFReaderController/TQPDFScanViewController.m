//
//  PDFScanViewController.m
//  PDFReader
//
//  Created by litianqi on 16/12/7.
//  Copyright © 2016年 TQ. All rights reserved.
//

#import "TQPDFScanViewController.h"
#import "TQPDFDocumentTools.h"
#import "TQDownLoadPanelViewController.h"
#import "TQPDFReaderDownloadManager.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "TQPDFReader.h"
#import "TQPDFShareTools.h"
#import "TQPDFOtherViewTools.h"
#import <WebKit/WebKit.h>
//#import <Masonry/Masonry.h>
#import "Masonry/Masonry.h"
#import <math.h>
static NSString * const kActivityServiceWeixinChat = @"ActivityServiceWeixinChat";
static NSString * const kActivityServiceQQFriends = @"ActivityServiceQQFriends";
@interface HQ_UIActivityType:UIActivity
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *urlString;
@property (nonatomic) NSString *shareDescription;
@property (nonatomic) NSString *shareTitle;
@property (nonatomic) UIImage *image;

- (instancetype)initWithTitle:(NSString *)title type:(NSString *)type;


@end

@implementation HQ_UIActivityType

- (instancetype)initWithTitle:(NSString *)title type:(NSString *)type{
    if (self = [super init]) {
        self.title = title;
        self.type = type;
    }
    return self;
}
- (NSString *)activityTitle{
    return self.title;
}
- (NSString *)activityType{
    return self.type;
}
- (UIImage *)activityImage{
    NSString *weixinImageString = @"share_wechat";
    NSString *friendsImageString = @"share_qq";
    NSString *imageName = [self.type isEqualToString:kActivityServiceWeixinChat] ? weixinImageString: friendsImageString;
    NSData *imageData = [imageName dataUsingEncoding:NSUTF8StringEncoding];
    return [UIImage imageWithData:imageData scale:2.0];
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems{
    return YES;
}
- (void)prepareWithActivityItems:(NSArray *)activityItems{
    
}

- (void)performActivity {
    //这里就可以关联外面的app进行分享操作了
    //也可以进行一些数据的保存等操作
    //操作的最后必须使用下面方法告诉系统分享结束了
    if ([self.type isEqualToString:kActivityServiceWeixinChat]) {
        NSLog(@"在这里可以实现微信分享代码");
    }else  if ([self.type isEqualToString:kActivityServiceQQFriends]) {
        NSLog(@"在这里可以实现微信分享代码");
    }
    else{
        NSLog(@"在这里可以实现朋友圈分享代码");
    }
    [self activityDidFinish:YES];
    
}

@end


#define kPDFScanViewController_Device_is_iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )

@implementation TQPDFScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end


@implementation PDFPageCollectionCell
- (void)setPageRef:(CGPDFPageRef)pageRef{
    _pageRef = pageRef;
   /* if (!_pageRef) {
        return;
    }
    */
    [self setNeedsDisplay];
}

-(void)drawInContext:(CGContextRef)context {
    //Quartz坐标系和UIView坐标系不一样所致，调整坐标系，使pdf正立
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //创建一个仿射变换，该变换基于将PDF页的BOX映射到指定的矩形中。
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(_pageRef, kCGPDFCropBox, self.bounds, 0, true);
    CGContextConcatCTM(context, pdfTransform);
    //将pdf绘制到上下文中
    CGContextDrawPDFPage(context, _pageRef);
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
//    [super drawRect:rect];
    if (!_pageRef) {
        return;
    }
    [self drawInContext:UIGraphicsGetCurrentContext()];
    return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect mediaRect = CGPDFPageGetBoxRect(_pageRef, kCGPDFCropBox);//pdf内容的rect
    
    CGContextRetain(context);
    CGContextSaveGState(context);
    
    [[UIColor whiteColor] set];
    CGContextFillRect(context, rect);//填充背景色，否则为全黑色；
    CGFloat rectScale = rect.size.width / rect.size.height;
    CGFloat mediaScale = mediaRect.size.width/ mediaRect.size.height;
    CGFloat scalePdf = 0.0;
    if (mediaScale >= rectScale ) {
        scalePdf = rect.size.width / mediaRect.size.width;
    }
    else
        scalePdf = rect.size.height / mediaRect.size.height;
    
    NSInteger heightScale = mediaRect.size.height * scalePdf;
    
    CGContextTranslateCTM(context, 0, heightScale);//设置位移，x，y;
    CGContextScaleCTM(context, scalePdf, -scalePdf);//缩放倍数--x轴和y轴
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetRenderingIntent(context, kCGRenderingIntentDefault);
    CGContextDrawPDFPage(context, _pageRef);//绘制pdf
    
    CGContextRestoreGState(context);
    CGContextRelease(context);
}

@end
static NSInteger cellHeight = 0;
static NSInteger pageOffSetY = 0;


@interface TQPDFScanViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,WKNavigationDelegate>
@property (assign, nonatomic) CGPDFDocumentRef  pdfRef;
@property (assign, nonatomic) NSInteger pageTotal;//总页数
@property (assign, nonatomic) NSInteger currentPage;//当前页

@property (strong, nonatomic) NSString *pathBook;
@property (weak, nonatomic) IBOutlet UICollectionView *collection;
@property (nonatomic,weak) IBOutlet TQPDFScrollView * scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *saveImgBtn;
@property (weak, nonatomic) IBOutlet UILabel *pageLabel;

@property (nonatomic, strong) TQDownLoadPanelViewController * downLoadPanelVC;
@property (nonatomic, strong) UIButton * quickLocationBtn;
@property (nonatomic, assign) BOOL isPanG;
/** heightCache */
@property (nonatomic, strong) NSCache *cacheHeight;
/** webview */
@property (nonatomic, strong) WKWebView  *webView;
@property (nonatomic, strong) UIButton  *rotateButton;
/** rotate status */
@property (nonatomic, assign) BOOL isRotated;




@end

@implementation TQPDFScanViewController

- (void)dealloc{
    for (UIGestureRecognizer * ges in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:ges];
    }
    for (UIGestureRecognizer * ges in _quickLocationBtn.gestureRecognizers) {
        [_quickLocationBtn removeGestureRecognizer:ges];
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"dealloc%@",[self class]);
}

- (UIButton *)rotateButton
{
    if (!_rotateButton) {
        _rotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rotateButton setTitle:@"旋转" forState:UIControlStateNormal];
        [_rotateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rotateButton addTarget:self action:@selector(clickRotateEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview: _rotateButton];
        [_rotateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-50);
            make.right.mas_equalTo(-20);
            make.width.height.mas_equalTo(40);
        }];
    }
    return _rotateButton;
}

- (void)clickRotateEvent:(id)sender
{
    if (self.isRotated) {
//        [[UIDevice currentDevice] s];
//        self.view.transform = CGAffineTransformIdentity;
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }else{
//        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _cacheHeight = [NSCache new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLayoutCollectionView:) name:UIDeviceOrientationDidChangeNotification object:nil];
    cellHeight = 0;
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 3.0f;
    [self.scrollView setAlwaysBounceHorizontal:YES];
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    _isPanG = NO;
    _pageLabel.hidden = YES;
    pageOffSetY = 0;
    
    UITapGestureRecognizer * oneTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesHandleEvent:)];
    oneTapG.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:oneTapG];
    
    UITapGestureRecognizer * doubleG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesHandleEvent:)];
    doubleG.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleG];
    [oneTapG requireGestureRecognizerToFail:doubleG];
    
    
    [self.saveImgBtn setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
    [self.saveImgBtn.layer setCornerRadius:17];
    [self.saveImgBtn.layer setMasksToBounds:YES];
    

    [self.pageLabel.layer setCornerRadius:4];
    [self.pageLabel.layer setMasksToBounds:YES];
    self.pageLabel.hidden = YES;
    if (self.quickLocationBtnBGColor && self.quickLocationBtnTitleColor) {
        _quickLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_quickLocationBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_quickLocationBtn setBackgroundColor:self.quickLocationBtnBGColor];
        [_quickLocationBtn setFrame:CGRectMake(self.view.frame.size.width - 27,20, 20, 25)];
        [_quickLocationBtn setTitleColor:self.quickLocationBtnTitleColor forState:UIControlStateNormal];
        [_quickLocationBtn setImage:PDFReaderImage(@"PdfReader_slider") forState:UIControlStateNormal];
        [_quickLocationBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        _quickLocationBtn.hidden = YES;
        UIPanGestureRecognizer * panG = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(quickLocationPanEvent:)];
        [_quickLocationBtn addGestureRecognizer:panG];
        
        [self.view addSubview:_quickLocationBtn];
    }
    if (_enableShare) {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(enableRightShare)]];
    }
    
    if (self.openByWebView &&  [self.urlFile hasPrefix:@"http"]) {
        self.collection.hidden = YES;
        WKWebViewConfiguration * config = [WKWebViewConfiguration new];
        config.suppressesIncrementalRendering = YES;
        _webView  = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) configuration:config];
        _urlFile = [_urlFile stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
         _webView.navigationDelegate = self;
        NSURL * url = [NSURL URLWithString:self.urlFile];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        [self.scrollView addSubview:_webView];
        
     
        
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(0);
            make.trailing.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    
}

- (void)enableRightShare{
    __weak typeof(self) weakSelf = self;
    [[TQPDFShareTools class]shareViewController:self filePath:self.urlFile shareBlock:^(NSString * _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.shareBlock) {
            strongSelf.shareBlock(activityType, completed, returnedItems, activityError);
        }
    }];
    return;
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.fd_interactivePopDisabled = NO;
    pageOffSetY = _collection.contentOffset.y;
    [TQPDFReaderFileManager setFileScanPercent:@(pageOffSetY) withUrl:self.urlFile currentPage:_currentPage];
    
   UIDeviceOrientation  currentOrientation = [[UIDevice currentDevice] orientation];
     
    if (currentOrientation != UIDeviceOrientationPortrait) {
        NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.currentPage = [TQPDFReaderFileManager getFileScanHistoryPageWithUrl:self.urlFile];
    NSNumber * pageYNumber = [TQPDFReaderFileManager getFileScanPercentWithUrl:self.urlFile];
    pageOffSetY = pageYNumber ? [pageYNumber integerValue] :pageOffSetY;
    if (pageOffSetY > 0) {
        [_collection setContentOffset:CGPointMake(0, pageOffSetY)];
    }

    [TQPDFOtherViewTools loadHistoryView:self.view withCurrentPage:_currentPage];
    [self setPageNumber:_collection.contentOffset.y];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.fd_interactivePopDisabled = YES;
    if (self.customTitleLabel) {
         [self.navigationItem setTitleView:self.customTitleLabel];
    }
    
    if (self.openByWebView) {
        return;
    }
    
    if (_localFileType) {
        [self loadLocalResourseFile:self.urlFile];
        return;
    }
    
    if ([TQPDFReaderFileManager isExistFileFromUrl:self.urlFile]) {
        NSString * localFilePath = [TQPDFReaderFileManager getCompleteFileLocalPathFromUrl:self.urlFile];
        [self loadLocalResourseFile:localFilePath];
    }
    else{
        self.downLoadPanelVC.fileUrl = self.urlFile;
        self.downLoadPanelVC.resourseType = self.resourseType;
        __weak typeof(self) weakSelf = self;
        self.downLoadPanelVC.finishedDownLoaded = ^(NSString * downloadedFilePath){
            [weakSelf loadLocalResourseFile:downloadedFilePath];
        };
        
    }
    
    [_collection reloadData];
}

- (void)loadLocalResourseFile:(NSString * )localPath{
    if (!localPath) {
        return;
    }
    ResourceType_PDFReader typeResource = [TQPDFReaderFileManager fileTypeFromUrl:self.urlFile];
    if (typeResource != ResourceType_PDFReader_other) {//修正
        _resourseType = typeResource;
    }
    else if (typeResource == ResourceType_PDFReader_other && _resourseType == ResourceType_PDFReader_image){//修正
        _resourseType = ResourceType_PDFReader_other;
    }
    
    if (self.resourseType == ResourceType_PDFReader_image) {
        self.imageView.hidden = NO;
        self.saveImgBtn.hidden = NO;
        self.pageLabel = nil;
        self.quickLocationBtn = nil;
        [self.imageView setImage:[UIImage imageWithContentsOfFile:localPath]];
    }
    else /*if (self.resourseType == ResourceType_PDFReader_pdf )*/{
        if ([localPath hasPrefix:@"http"]) {//在线文档
            return;
        }
        _pdfRef = [TQPDFDocumentTools pdfRefByFilePath:localPath];
        CGPDFPageRef pageRef = CGPDFDocumentGetPage(_pdfRef,1);
        CGRect mediaRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);//pdf内容的rect
        if (mediaRect.size.width) {
            cellHeight = self.view.frame.size.width * mediaRect.size.height/ mediaRect.size.width;
        }
        
        if (!_pdfRef) {
            if (self.openErrorBlock) {
                self.openErrorBlock([NSError errorWithDomain:localPath code:-1 userInfo:nil]);
            }
//            DDLogError(@"文件对象=nil,直接退出:%@",localPath);
            [TQPDFOtherViewTools loadErrorView:self.view];
            return;
        }
        size_t count = CGPDFDocumentGetNumberOfPages(_pdfRef);
        _pageTotal = count;
        [self.collection reloadData];
    }
    
}

- (void)reLayoutCollectionView:(id)sender{
    [_collection reloadData];
}

#pragma mark --UICollectionViewDelegate
- (PDFPageCollectionCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"cellforro\n");
    PDFPageCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    cell.pageRef = CGPDFDocumentGetPage(_pdfRef, indexPath.row+1);
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _pageTotal;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSInteger heightScale = 0;
//    if ([self.cacheHeight objectForKey:@(indexPath.row + 1)]) {
//        heightScale = [[self.cacheHeight objectForKey:@(indexPath.row + 1)] integerValue];
//        cellHeight = heightScale;
//        return CGSizeMake(_collection.frame.size.width, heightScale);
//    }
//
//    CGPDFPageRef pageRef = CGPDFDocumentGetPage(_pdfRef, indexPath.row+1);
//    CGRect mediaRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);//pdf内容的rect
//    heightScale = self.view.frame.size.width * mediaRect.size.height/ mediaRect.size.width;
//    cellHeight = heightScale;
//    [self.cacheHeight setObject:@(heightScale) forKey:@(indexPath.row + 1)];
    return CGSizeMake(_collection.frame.size.width, cellHeight);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark --UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.resourseType == ResourceType_PDFReader_pdf) {
        return _collection;
    }
    else if (self.resourseType == ResourceType_PDFReader_image){
        return _imageView;
    }
    return _collection;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _pageLabel.hidden = YES;
    _quickLocationBtn.hidden = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _pageLabel.hidden = YES;
    _quickLocationBtn.hidden = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _pageLabel.hidden = NO;
    _quickLocationBtn.hidden = NO;
    [self setPageNumber:scrollView.contentOffset.y];
    if (_isPanG) {
        return;
    }
    
    
    
    float  quickLocationY = 0;
    if (scrollView.contentSize.height - scrollView.frame.size.height) {
        quickLocationY = (scrollView.contentOffset.y)/(scrollView.contentSize.height - scrollView.frame.size.height ) * (self.view.frame.size.height - _quickLocationBtn.frame.size.height);
    }
  
    if (quickLocationY > (self.view.frame.size.height- _quickLocationBtn.frame.size.height)){
        quickLocationY = self.view.frame.size.height- _quickLocationBtn.frame.size.height;
    }
    
    CGRect quickBtnRect = _quickLocationBtn.frame;
    quickBtnRect.origin.y = quickLocationY;
    quickBtnRect.origin.x = self.view.frame.size.width - 27;
    _quickLocationBtn.frame = quickBtnRect;
    
}

- (void)setPageNumber:(CGFloat)_offsetY{
    NSArray * arraryVisible = _collection.visibleCells ;
    for (PDFPageCollectionCell * cell  in arraryVisible) {
        if ((cell.frame.origin.y - _offsetY)< self.view.frame.size.height/2 && (cell.frame.origin.y + cell.frame.size.height - _offsetY) >self.view.frame.size.height/2) {
            NSIndexPath * indexPath = [_collection indexPathForCell:cell];
            NSInteger pageRow = indexPath.row +1;
            _currentPage = pageRow;
            _pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",pageRow,_pageTotal];
            break;
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
     return UIInterfaceOrientationPortrait;
}

#pragma mark - photo
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"呵呵";
    if (!error) {
        message = @"成功保存到相册";
        [SVProgressHUD showSuccessWithStatus:@"保存成功~"];
    }else
    {
        message = [error description];
        [SVProgressHUD showErrorWithStatus:@"保存失败~"];
    }
    NSLog(@"message is %@",message);
}

#pragma mark -Event

- (IBAction)clickSaveEvent:(id)sender{
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)tapGesHandleEvent:(UITapGestureRecognizer *)ges{
    if (ges.numberOfTapsRequired ==2) {
        CGFloat currentZoom =  _scrollView.zoomScale;
        if (currentZoom >1.01) {
            [_scrollView setZoomScale:1.01 animated:YES];
        }
        else
            [_scrollView setZoomScale:1.5 animated:YES];
        
    }
    else{
        BOOL statusHidden = self.navigationController.navigationBarHidden;
//        self.rotateButton.hidden = statusHidden;
        [self.navigationController setNavigationBarHidden:!statusHidden animated:YES];
    }
    
}

- (void)quickLocationPanEvent:(UIPanGestureRecognizer *)panG{
    if (panG.state == UIGestureRecognizerStateBegan) {
        _isPanG = YES;
    }
    else if (panG.state != UIGestureRecognizerStateChanged){
        _isPanG = NO;
        _pageLabel.hidden = YES;
        _quickLocationBtn.hidden = YES;
    }
    
    CGPoint currentPoint = [panG locationInView:self.view];
    if ((currentPoint.y > _quickLocationBtn.frame.size.height/2) &&(currentPoint.y < (self.view.frame.size.height- _quickLocationBtn.frame.size.height/2))) {
        _quickLocationBtn.center = CGPointMake(_quickLocationBtn.center.x, currentPoint.y);
    }
    
    NSInteger  offsetY = 0;
    if (_collection.frame.size.height - _quickLocationBtn.frame.size.height) {
         offsetY = currentPoint.y/(_collection.frame.size.height - _quickLocationBtn.frame.size.height) * (_collection.contentSize.height- _collection.frame.size.height);
    }
   
    if (offsetY > (_collection.contentSize.height - _collection.frame.size.height)) {
        offsetY = _collection.contentSize.height - _collection.frame.size.height;
    }
    if (offsetY >= 0) {
        [_collection setContentOffset:CGPointMake(_collection.contentOffset.x, offsetY)];
    }
    
}

- (UIColor *)quickLocationBtnBGColor{
    if (!_quickLocationBtnBGColor) {
        _quickLocationBtnBGColor = self.pageLabel.backgroundColor;
    }
    return _quickLocationBtnBGColor;
}

- (UIColor *)quickLocationBtnTitleColor{
    if (!_quickLocationBtnTitleColor) {
        _quickLocationBtnTitleColor = self.pageLabel.textColor;
    }
    return _quickLocationBtnTitleColor;
}

- (TQDownLoadPanelViewController *)downLoadPanelVC{
    if (!_downLoadPanelVC) {
        _downLoadPanelVC = [[UIStoryboard  storyboardWithName:@"TQPdfStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"TQDownLoadPanelViewController"];
        _downLoadPanelVC.title = self.title;
        [self addChildViewController:_downLoadPanelVC];
        [self.view addSubview:_downLoadPanelVC.view];
        [_downLoadPanelVC didMoveToParentViewController:self];
    }
     _downLoadPanelVC.resourseType = self.resourseType;
    return _downLoadPanelVC;
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"finished");
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"test");
    if (self.openErrorBlock) {
        self.openErrorBlock(error);
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
