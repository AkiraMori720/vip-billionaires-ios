//
//  AddGroupViewController.m
//  VIP Billionaires
//
//  Created by jts on 15/06/18.
//  Copyright © 2018 Eric Schanet. All rights reserved.
//

#import "AddGroupViewController.h"
#import <Firebase/Firebase.h>
#import "UIImage+ResizeAdditions.h"
#import "AFNetworking.h"

@interface AddGroupViewController ()

@end

@implementation AddGroupViewController

@synthesize isEdit;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_splash"]]];
    self.navigationItem.title = NSLocalizedString(@"VIP Billionaires", nil);
    self.navigationController.navigationBar.barTintColor = def_TopBar_Color;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnGroupDoneAcion)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnCancelAction)];
    
    [self.navigationItem.rightBarButtonItem setTintColor:def_Golden_Color];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:def_Golden_Color,  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:def_Golden_Color,  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    
    self.groupAddView.layer.cornerRadius = 5.0;
    self.groupAddView.clipsToBounds = YES;
    
    self.btnGroupIcon.layer.cornerRadius = self.btnGroupIcon.frame.size.width/2;
    self.btnGroupIcon.clipsToBounds = YES;
    
    //self.imgView.layer.cornerRadius = self.imgView.frame.size.width/2;
   // self.imgView.clipsToBounds = YES;
    
    self.backGroupView.alpha = 0.5;
    
    [self.txtGroupName becomeFirstResponder];
    
    if (self.isEdit == TRUE) {
        
        self.txtGroupName.text = self.groupName;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.groupIconStr]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIImage *img = (UIImage *)responseObject;
            
            [self.imgView setImage:img];

        }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"createNewPhotoMessage picture load error.");
            
            self.groupIcon = nil;
            
        }];
        [[NSOperationQueue mainQueue] addOperation:operation];
    }

    // Do any additional setup after loading the view from its nib.
}
- (IBAction)btnCancelAction
{
    [self dismissViewControllerAnimated:YES completion:^{
       
    }];
}
- (IBAction)btnGroupDoneAcion{
    
    self.txtGroupName.text = [self.txtGroupName.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (self.txtGroupName.text.length == 0) {
        
        [ProgressHUD showError:NSLocalizedString(@"Please enter group name", nil)];

        return;
    }
   /* if (self.groupIcon == nil) {
        
        [ProgressHUD showError:@"Please select group icon"];
        
        return;
    }*/
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self.delegate selecteGroupNameIcon:self.txtGroupName.text image:self.groupIcon];
    }];
}
- (IBAction)btnGroupIconAction:(id)sender
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take Photo", nil), NSLocalizedString(@"Choose existing photo", nil), nil];
    action.tag = 2;
    [action showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        
        [ESUtility shouldPresentPhotoAndVideoCamera:self editable:YES];
    }
    if (buttonIndex == 1) {
        
        [ESUtility shouldPresentPhotoLibrary:self editable:NO];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *picture = info[UIImagePickerControllerOriginalImage];
    
    if(picture != nil)
    {
        UIImage *resizedImage = [picture resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(340.0f, 340.0f) interpolationQuality:kCGInterpolationHigh];
        
       // [self.btnGroupIcon setImage:resizedImage forState:UIControlStateNormal];
        self.groupIcon = resizedImage;

        [self.imgView setImage:resizedImage];
    }
   
    
    /*NSURL *localFile = [NSURL URLWithString:@"path/to/image"];
    
    // Create a reference to the file you want to upload
    FIRStorageReference *riversRef = [storageRef child:@"images/rivers.jpg"];
    
    // Upload the file to the path "images/rivers.jpg"
    FIRStorageUploadTask *uploadTask = [riversRef putFile:localFile metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            // Metadata contains file metadata such as size, content-type, and download URL.
            int size = metadata.size;
            // You can also access to download URL after upload.
            [riversRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    NSURL *downloadURL = URL;
                }
            }];
        }
     }];*/
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
