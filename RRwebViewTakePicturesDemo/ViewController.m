//
//  ViewController.m
//  RRwebViewTakePicturesDemo
//
//  Created by roarrain on 16/1/16.
//  Copyright © 2016年 roarrain. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong)UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"webView" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    self.webView = webView;
    
}
#pragma mark --UIWebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    rr://自定义协议头 如果url中带有参数可以 直接转化为SEL
    NSString *str = request.URL.absoluteString;
    NSUInteger loc = [str rangeOfString:@"rr://takePicture"].location;
    if (loc!= NSNotFound) {
//        调用相机
        [self takePicture];
    }
    return YES;
}

- (void)takePicture{

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
        pickerC.delegate = self;
        pickerC.allowsEditing = YES;
        pickerC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:pickerC animated:YES completion:nil];
    }else{
        NSLog(@"相机不可用");
    }

}
#pragma mark --UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMddmmss"];
    NSString *nowTime = [formatter stringFromDate:[NSDate date]];
    
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"photo%@.png",nowTime]];
//    将拍得照片缓存到沙盒中
    if ([UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]) {
        [self innerImage:filePath];
    }else{
        NSLog(@"保存失败");
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
   
}


- (void)innerImage:(NSString *)path{
//    JS  将图片插入到webView
    NSMutableString *js = [NSMutableString string];
    [js appendString:@"var imgs = document.createElement('img');"];
    [js appendString:[NSString stringWithFormat:@"imgs.src = \"%@\";",path]];
    [js appendString:@"imgs.width = 320;"];
    [js appendString:@" imgs.height = 320;"];
    [js appendString:@" var bd = document.getElementsByTagName('body')[0];"];
    [js appendString:@" bd.appendChild(imgs);"];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
