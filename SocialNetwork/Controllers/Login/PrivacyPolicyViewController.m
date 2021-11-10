//
//  PrivacyPolicyViewController.m
//  VIP Billionaires - Social Chat
//
//  Created by jts on 06/08/18.
//  Copyright © 2018 Eric Schanet. All rights reserved.
//

#import "PrivacyPolicyViewController.h"
#import <WebKit/WebKit.h>

@interface PrivacyPolicyViewController ()

@end

@implementation PrivacyPolicyViewController
@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *nsurl=[NSURL URLWithString:@"http://vipbillionaires.com/privacy-policy/"];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [webView loadRequest:nsrequest];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
