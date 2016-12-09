//
//  ViewController.m
//  WKWebView
//
//  Created by Mr. Wu on 16/12/1.
//  Copyright © 2016年 wuzhendong. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "FootView.h"

#define kBottomViewH 44
/// 屏幕大小尺寸
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UISearchBarDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler, FootViewDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) WKWebView *wkWebView;

@property (weak, nonatomic) NSString *baseURLString;
@property(nonatomic,strong)FootView *footView;
@property(nonatomic,strong)UIProgressView *progressView;

@end

@implementation ViewController

/*
 重要方法和属性;
 
 @property (nonatomic, readonly) BOOL canGoBack; //向后
 @property (nonatomic, readonly) BOOL canGoForward;//向前;
 - (WKNavigation *)goBack;
 - (WKNavigation *)goForward;
 - (WKNavigation *)reload;
 - (WKNavigation *)reloadFromOrigin; // 增加的函数 ,会比较网络数据是否有变化，没有变化则使用缓存，否则从新请求。
 - (WKNavigation *)goToBackForwardListItem:(WKBackForwardListItem *)item; // 比向前向后更强大，可以跳转到某个指定历史页面
 - (void)stopLoading;
 一些常用属性
 allowsBackForwardNavigationGestures：BOOL类型，是否允许左右划手势导航，默认不允许
 estimatedProgress：加载进度，取值范围0~1
 title：页面title
 .scrollView.scrollEnabled：是否允许上下滚动，默认允许
 backForwardList：WKBackForwardList类型，访问历史列表，可以通过前进后退按钮访问，或者通过goToBackForwardListItem函数跳到指定页面
 
 */

#pragma mark - 懒加载;
-(UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth,10)];
         [self.view addSubview:_progressView];
    }
    return _progressView;
    
}
-(FootView *)footView{
    if (!_footView) {
        _footView = [[FootView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kBottomViewH, kScreenWidth, kBottomViewH)];
        _footView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        _footView.delegate = self;
        [self.view addSubview:_footView];
        
    }return _footView;
    
}
- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 40)];
        searchBar.delegate = self;
        _searchBar = searchBar;
        
    }
    return _searchBar;
}

- (WKWebView *)wkWebView {
    if (_wkWebView == nil) {
      
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,64, kScreenWidth, kScreenHeight - kBottomViewH-64)];
             //                webView.scrollView.scrollEnabled = NO;
        
        //        webView.backgroundColor = [UIColor colorWithPatternImage:self.image];
        // 允许左右划手势导航，默认允许
        webView.allowsBackForwardNavigationGestures = YES;
        webView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;//拖拽时隐藏键盘;
        
        _wkWebView = webView;
    }
    
    return _wkWebView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
   self.automaticallyAdjustsScrollViewInsets = NO;
     self.navigationController.navigationBar.backgroundColor= [UIColor cyanColor];
    [self addSubViews];
    self.wkWebView.allowsBackForwardNavigationGestures = YES;
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld context:nil];
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.utouu.com/"]]];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{ NSLog(@" %s,change = %@",__FUNCTION__,change);
    if ([keyPath isEqual: @"estimatedProgress"] && object == self.wkWebView) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:YES];
        if(self.wkWebView.estimatedProgress >= 1.0f)
        {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)addSubViews {
    self.navigationItem.titleView = self.searchBar;
    [self.view addSubview:self.wkWebView];
    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate = self;
}

/// 刷新按钮是否允许点击
- (void)refreshBottomButtonState {
    if ([self.wkWebView canGoBack]) {
        self.footView.backBtn.enabled = YES;
    } else {
        self.footView.backBtn.enabled = NO;
    }
    
    if ([self.wkWebView canGoForward]) {
        self.footView.forwardBtn.enabled = YES;
    } else {
        self.footView.forwardBtn.enabled = NO;
    }
}
-(void)loadLocalFile{
  
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20)];
    // 2.创建url  userName：电脑用户名
    NSURL *url = [NSURL fileURLWithPath:@"/Users/yons/Desktop/屏幕快照 2016-10-10 上午10.18.00.png"];
    // 3.加载文件
    [webView loadFileURL:url allowingReadAccessToURL:url];
    // 最后将webView添加到界面
    [self.view addSubview:webView];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - searchBar代理方法
/// 点击搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // 创建url
    NSURL *url = nil;
    NSString *urlStr = searchBar.text;
    
    // 如果file://则为打开bundle本地文件，http则为网站，否则只是一般搜索关键字
    if([urlStr hasPrefix:@"file://"]){
        NSRange range = [urlStr rangeOfString:@"file://"];
        NSString *fileName = [urlStr substringFromIndex:range.length];
        url = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        // 如果是模拟器加载电脑上的文件，则用下面的代码
        //        url = [NSURL fileURLWithPath:fileName];
    }else if(urlStr.length>0){
        if ([urlStr hasPrefix:@"http://"]) {
            url=[NSURL URLWithString:urlStr];
        } else {
            urlStr=[NSString stringWithFormat:@"http://www.baidu.com/s?wd=%@",urlStr];
        }
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        url=[NSURL URLWithString:urlStr];
        
    }
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    // 加载请求页面
    [self.wkWebView loadRequest:request];
}
//执行顺序;
/// 1 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *urlString = [[navigationAction.request URL] absoluteString];
    self.searchBar.text = urlString;
    
    urlString = [urlString stringByRemovingPercentEncoding];
    //    NSLog(@"urlString=%@",urlString);
    // 用://截取字符串
    NSArray *urlComps = [urlString componentsSeparatedByString:@"://"];
    if ([urlComps count]) {
        // 获取协议头
        NSString *protocolHead = [urlComps objectAtIndex:0];
        NSLog(@"protocolHead=%@",protocolHead);
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    
    
}
/// 2 页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
    
}
/// 3 在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationResponsePolicyCancel取消跳转，WKNavigationResponsePolicyAllow允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    
    decisionHandler(WKNavigationResponsePolicyAllow);
    
}
/// 4 开始获取到网页内容时返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    [self refreshBottomButtonState];
    
}
/// 5 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   
}
/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    
}
/// 接收到服务器跳转请求之后调用 (服务器端redirect)，不一定调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
    
}
/// message: 收到的脚本信息.
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSLog(@"haahah");
    
    
}
//WKUIDelegate：UI界面相关，原生控件支持，三种提示框：输入、确认、警告。可以把javaScript的一些alert捕捉到,然后显示自定义的UI
/// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    return nil;
    
}
/// 输入框 调用prompt函数时，会触发此方法
// 要求输入一段文本
// 在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"%@", prompt);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput" message:@"JS调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
   }
/// 确认框 调用confirm函数时，会触发此方法
// 通过message可以拿到JS端所传的数据
// 在iOS端显示原生alert得到YES/NO后
// 通过completionHandler回调给JS端
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"confirm" message:@"JS调用confirm" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
    NSLog(@"%@", message);

}
/// 警告框在  JS端调用alert函数时，会触发此代理方法。
// JS端调用alert时所传的数据可以通过message拿到
// 在原生得到结果后，需要回调JS，是通过completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"%s", __FUNCTION__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:@"JS调用alert" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    NSLog(@"%@", message);
    
}

// 从web界面中接收到一个脚本时调用
//-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
//    
//    
//}
-(void)goBackClick:(UIButton *)Bt_goBack{
    [self.wkWebView goBack];
    [self refreshBottomButtonState];
}
-(void)goFowardClick:(UIButton *)Bt_goFoward{
    [self.wkWebView goForward];
    [self refreshBottomButtonState];
}
-(void)goReloadClick:(UIButton *)Bt_reload{
    // [self.wkWebView reload];
    [self.wkWebView reloadFromOrigin];
}
-(void)goSafarrClick:(UIButton *)Bt_Safari{
    [[UIApplication sharedApplication] openURL:self.wkWebView.URL];
}
- (void)dealloc {
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    
    // if you have set either WKWebView delegate also set these to nil here
    [self.wkWebView setNavigationDelegate:nil];
    [self.wkWebView setUIDelegate:nil];
}

@end
