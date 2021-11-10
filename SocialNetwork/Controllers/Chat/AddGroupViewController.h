//
//  AddGroupViewController.h
//  VIP Billionaires
//
//  Created by jts on 15/06/18.
//  Copyright © 2018 Eric Schanet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddGroupDelegate

- (void)selecteGroupNameIcon:(NSString *)groupName image:(UIImage*)image;

@end

@interface AddGroupViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSString *groupName;
@property (strong, nonatomic) UIImage *groupIcon;
@property (strong, nonatomic) NSString *groupIconStr;

@property (assign, nonatomic) BOOL isEdit;

@property (weak, nonatomic) IBOutlet UIView *groupAddView;
@property (weak, nonatomic) IBOutlet UIButton *btnGroupIcon;
@property (weak, nonatomic) IBOutlet UITextField *txtGroupName;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnGroupDone;
@property (weak, nonatomic) IBOutlet UIView *backGroupView;
@property (nonatomic, assign) IBOutlet id<AddGroupDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

- (IBAction)btnGroupIconAction:(id)sender;

@end
