//
//  ESPrivacyPolicyViewController.m
//  SocialNetwork
//
//  Created by Gregor H on 6/26/16.
//  Copyright © 2016 Eric Schanet. All rights reserved.
//

#import "ESPrivacyPolicyViewController.h"
#import <WebKit/WebKit.h>

@interface ESPrivacyPolicyViewController ()
@property UIButton *button;
@end
@implementation ESPrivacyPolicyViewController
@synthesize button;
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Privacy Policy", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:def_Golden_Color,
       NSFontAttributeName:[UIFont fontWithName:@"Montserrat-Medium" size:21]}];
    
    WKWebView * pdfView = [[WKWebView alloc]initWithFrame:CGRectMake(0, self.showDoneButton ? 40 : 0, SCR_W, SCR_H)];
    [self.view addSubview:pdfView];
    if (self.showDoneButton) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, -10000, SCR_W, 50 + 10000)];
        view.backgroundColor = [UIColor blackColor];
        [self.view addSubview:view];
        [self.view bringSubviewToFront:pdfView];
        self.presentationController.presentedView.gestureRecognizers[0].enabled = NO;
        UIButton* cancelButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 70,  0, 50, 30)];
        [cancelButton setTitle:@"Done" forState:UIControlStateNormal];
        [cancelButton setTitleColor:def_Golden_Color forState:UIControlStateNormal];
        [self.view addSubview: cancelButton];
        [cancelButton addTarget:self action:@selector(dismissWindow) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];
    NSString *languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
    NSString * preCountry = @"en";
    if ([languageCode isEqualToString:@"zh"]) {
        preCountry = @"zh";
    }else if([languageCode isEqualToString:@"ja"]){
        preCountry = @"ja";
    }else{
        preCountry = @"en";
    }
    
    NSLog(@"%@",languageCode);
    
    NSURL * pdfURL = [[NSBundle mainBundle]URLForResource:[NSString stringWithFormat:@"%@.pdf",preCountry]
                                            withExtension:nil];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:pdfURL];
    
    [pdfView loadRequest:request];
}

-(void)dismissWindow {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
