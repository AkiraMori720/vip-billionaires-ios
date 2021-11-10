//
//  ESPrivacyPolicyViewController.h
//  SocialNetwork
//
//  Created by Gregor H on 6/26/16.
//  Copyright © 2016 Eric Schanet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESPrivacyPolicyViewController : UIViewController

@property CGPDFDocumentRef pdf;
@property CGPDFPageRef page;
@property BOOL showDoneButton;
@end
