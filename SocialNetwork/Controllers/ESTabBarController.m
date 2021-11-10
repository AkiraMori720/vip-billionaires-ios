//
//  ESTabBarController.m
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//
#define IS_IPHONE6 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 667)


#import "ESTabBarController.h"
#import "UIImage+ImageEffects.h"
#import "MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "RecorderViewController.h"
#import "SCLAlertView.h"
#import "ESConstants.h"
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "RNGridMenu.h"
#import "REComposeViewController.h"
#import "ESEditVedioViewController.h"
#import "MBSliderView.h"
#import "AVCamRecorder.h"
#import "AVCamUtilities.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <ImageIO/CGImageProperties.h>
#import "UIImage+ResizeAdditions.h"
#import <Photos/Photos.h>

@interface ESTabBarController () <RNGridMenuDelegate>
@end

@implementation ESTabBarController
@synthesize navController;


#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    self.navigationItem.backBarButtonItem.tintColor = def_Golden_Color;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:def_Golden_Color,  UITextAttributeTextColor,nil] forState:UIControlStateNormal];

    self.navController = [[UINavigationController alloc] init];
    
    //Notification listen
    NSString *notificationName = @"ESNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useNotificationWithString:) name:notificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoUploadBegins) name:@"videoUploadBegins" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoUploadEnds) name:@"videoUploadEnds" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoUploadWithDescription:) name:@"uploadVedioWithDescription" object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoUploadSucceeds) name:@"videoUploadSucceeds" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoUploadFails) name:@"videoUploadFails" object:nil];
    
}
- (void) videoUploadBegins {
   // self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
   // self.hud.labelText = NSLocalizedString(@"Uploading", nil);
   
}
-(void)videoUploadWithDescription:(NSNotification*)notification
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [ProgressHUD dismiss];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self.hud hide:true];
    
    NSDictionary *dic = notification.object;
    
    UIImage *img = [dic objectForKey:@"image"];
    NSURL *url = [dic objectForKey:@"url"];
    
    NSData *videoData = [[NSData alloc] initWithContentsOfURL:url];

    NSLog(@"%lu",(unsigned long)videoData.length);

    NSLog(@"%@",dic);
    
    NSLog(@"%@",img);
    NSLog(@"%@",url);
    
    NSLog(@"%@",[dic objectForKey:@"image"]);
    NSLog(@"%@",[dic objectForKey:@"url"]);
    
    ESEditVedioViewController *viewController = [[ESEditVedioViewController alloc] initWithImage:img url:url isEditView:FALSE];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self.navController pushViewController:viewController animated:YES];
    [self presentViewController:self.navController animated:YES completion:nil];

}


- (void) videoUploadEnds  {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [ProgressHUD dismiss];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self.hud hide:true];
    

}
- (void) videoUploadSucceeds:(NSNotification*)notification {
    
    [ProgressHUD dismiss];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self.hud hide:true];
   
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];
    [alert showSuccess:self.parentViewController title:NSLocalizedString(@"Congratulations", nil) subTitle:NSLocalizedString(@"Successfully uploaded the video", nil) closeButtonTitle:NSLocalizedString(@"Done", nil) duration:0.0f];
}
- (void) videoUploadFails {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert showError:self.parentViewController title:NSLocalizedString(@"Hold On...", nil)
            subTitle:NSLocalizedString(@"A problem occurred, try again later", nil)
    closeButtonTitle:@"OK" duration:0.0f];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
//    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    if (IS_IPHONE6) {
//        cameraButton.frame = CGRectMake( 162.0f, 0.0f, 50.0f, self.tabBar.bounds.size.height);
//    }
//    else {
//        cameraButton.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width/2 - 40/2, 5.0f, 40, self.tabBar.bounds.size.height - 10);
//    }
//    [cameraButton setImage:[UIImage imageNamed:@"ButtonCamera"] forState:UIControlStateNormal];
//    [cameraButton setImage:[UIImage imageNamed:@"ButtonCameraSelected"] forState:UIControlStateHighlighted];
//    [cameraButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *vipButton = ((AppDelegate*)[UIApplication sharedApplication].delegate).vipButton;
    [vipButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [vipButton removeFromSuperview];
    [self.view insertSubview:vipButton aboveSubview: self.tabBar];
//    MBSliderView * vip = [[MBSliderView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
//    [vip setText:@""];
//    vip.layer.borderWidth = 0;
////    [vip setLabelColor:def_Golden_Color];
////    [vip setThumbColor:def_Golden_Color];
//    [self.tabBar addSubview:vip];
//    vip.center = cameraButton.center;
//    cameraButton.layer.borderWidth = 0;
//    [self.tabBar addSubview:cameraButton];
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
//    [cameraButton addGestureRecognizer:swipeUpGestureRecognizer];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIButton *vipButton = ((AppDelegate*)[UIApplication sharedApplication].delegate).vipButton;
    CGFloat vipButonSize = 80;
    
    [vipButton setFrame:CGRectMake(self.tabBar.center.x - vipButonSize / 2, self.view.bounds.size.height - self.tabBar.bounds.size.height - vipButonSize / 2 , vipButonSize, vipButonSize)];
}
#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    image = [self scaleImage:image toSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-40,([UIScreen mainScreen].bounds.size.width-40) * image.size.height / image.size.width)]; // or some other size

    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    //if (!image && url) {
    if (url) {

        AVAsset* asset = [AVAsset assetWithURL:info[UIImagePickerControllerReferenceURL]];
        AVAssetImageGenerator* gen = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime firstTime = CMTimeMake(0, 60);
        UIImage* image = [UIImage imageWithCGImage:[gen copyCGImageAtTime:firstTime actualTime:0 error:nil]];
        
        //[ProgressHUD show:NSLocalizedString(@"Uploading", nil)];
//        [[ALAssetsLibrary new] assetForURL:info[UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
//            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
            
            image = [self scaleImage:image toSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-40, ([UIScreen mainScreen].bounds.size.width-40) * image.size.height / image.size.width)]; // or some other size

          /*  UIImage *thumbnailImage = [image thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:42.0f interpolationQuality:kCGInterpolationDefault];
            
            NSData *imageData = UIImageJPEGRepresentation(image, 0.8f);
            PFFile *thumbnail = [PFFile fileWithData:imageData];
            NSData *_imageData = UIImageJPEGRepresentation(thumbnailImage, 0.8f);
            PFFile *_thumbnail = [PFFile fileWithData:_imageData];
            
            NSDictionary * properties = [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:nil];
            NSNumber * size = [properties objectForKey: NSFileSize];
            
            NSLog(@"%@",size);
            
            NSData *videoData = [[NSData alloc] initWithContentsOfURL:url];
            
            NSLog(@"%lu",(unsigned long)videoData.length);
            NSLog(@"File size is : %.2f MB",(float)videoData.length/1024.0f/1024.0f);
            
            double vedioSize = (float)videoData.length/1024.0f/1024.0f;

            if (vedioSize > 10) {
                
                [ProgressHUD showError:@"Video should not be larger than 10 MB"];
                return;
            }
            
           
           
            PFFile *videoFile = [PFFile fileWithData:videoData];
            NSLog(@"%@",[NSByteCountFormatter stringFromByteCount:videoData.length countStyle:NSByteCountFormatterCountStyleFile]);
            
            PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            [ACL setPublicReadAccess:YES];
            [ACL setWriteAccess:YES forUser:[PFUser currentUser]];
            
            PFObject *videoObject = [PFObject objectWithClassName:kESPhotoClassKey];
            [videoObject setObject:videoFile forKey:kESVideoFileKey];
            [videoObject setObject:thumbnail forKey:kESVideoFileThumbnailKey];
            [videoObject setObject:_thumbnail forKey:kESVideoFileThumbnailRoundedKey];
            [videoObject setObject:kESVideoTypeKey forKey:kESVideoOrPhotoTypeKey];
            [videoObject setACL:ACL];
            [videoObject setObject:[PFUser currentUser] forKey:@"user"];
            
            [videoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"videoUploadEnds" object:nil];
                if (succeeded) {
                    [ProgressHUD dismiss];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"videoUploadSucceeds" object:nil];
                    
                    ESEditVedioViewController *viewController = [[ESEditVedioViewController alloc] initWithImage:image url:url];
                    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                    [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                    [self.navController pushViewController:viewController animated:NO];
                    [self presentViewController:self.navController animated:YES completion:nil];
                }
                else if (error) {
                    [ProgressHUD showError:NSLocalizedString(@"Internet connection failed", nil)];
                }
            }];*/
            
            ESEditVedioViewController *viewController = [[ESEditVedioViewController alloc] initWithImage:image url:url isEditView:FALSE];
            [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            self.navController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [self.navController pushViewController:viewController animated:YES];
            [self presentViewController:self.navController animated:YES completion:nil];
            
//
//        } failureBlock:^(NSError *error) {
//            [ProgressHUD showError:@"Error creating thumbnail"];
//        }];
        
        
    }
    else {
        
        //image = [self scaleImage:image toSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-40,[UIScreen mainScreen].bounds.size.width-40)];
        
       // image = [self scaleAndRotateImage:image];

        
       /* UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, self.view.frame.size.height-20)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self.view addSubview:imgView];
        [self.view setBackgroundColor:[UIColor redColor]];*/

       // image = [self imageByScalingAndCroppingForSize:imgView.image targetSize:CGSizeMake(imgView.image.size.width,imgView.image.size.height)];
        CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
        editor.delegate = self;
        [[CLImageEditorTheme theme] setBackgroundColor:[UIColor whiteColor]];
        [[CLImageEditorTheme theme] setToolbarColor:[[UIColor whiteColor] colorWithAlphaComponent:1]];
        [[CLImageEditorTheme theme] setToolbarTextColor:[UIColor blackColor]];
        [[CLImageEditorTheme theme] setToolIconColor:@"black"];
        editor.modalPresentationStyle =UIModalPresentationFullScreen;
        [self presentViewController:editor animated:YES completion:nil];
    }
    
}
- (UIImage *)scaleAndRotateImage:(UIImage *)image {
    int kMaxResolution = 320; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}
- (UIImage*)imageByScalingAndCroppingForSize:(UIImage*)image targetSize:(CGSize)targetSize{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
    else if (buttonIndex == 2) {
        RecorderViewController *viewController = [[RecorderViewController alloc] init];
        [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self.navController pushViewController:viewController animated:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:self.navController animated:YES completion:nil];
        });
        
    }    else if (buttonIndex == 3) {
        [self shouldPresentVideoCaptureController];
        
    }
}
#pragma mark - RNGridMenuDelegate

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    if (itemIndex == 0) {
        [self shouldStartCameraController];
    }
    else if (itemIndex == 1) {
        RecorderViewController *viewController = [[RecorderViewController alloc] init];
        [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self.navController pushViewController:viewController animated:NO];
        self.navController.modalPresentationStyle = UIModalPresentationFullScreen;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:self.navController animated:YES completion:nil];
        });
    }
    else if (itemIndex == 2) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {

                if (status == PHAuthorizationStatusAuthorized) {
                    // Access has been granted.
                    [self shouldStartPhotoLibraryPickerController];
                }

                else {
                    // Access has been denied.
                }
            }];
        } else
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                [self shouldStartPhotoLibraryPickerController];
            } else {
               
            }
        
    }
    else if (itemIndex == 3) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {

                if (status == PHAuthorizationStatusAuthorized) {
                    // Access has been granted.
                   [self shouldPresentVideoCaptureController];
                }

                else {
                    // Access has been denied.
                }
            }];
        } else
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                [self shouldPresentVideoCaptureController];
            } else {
               
            }
        
    }
    else if (itemIndex == 4) {
        REComposeViewController *composeViewController = [[REComposeViewController alloc] init];
        
        composeViewController.title = NSLocalizedString(@"CREATE POST", nil);
        composeViewController.hasAttachment = NO;
        composeViewController.attachmentImage = nil;
        composeViewController.text = @"";
        composeViewController.modalPresentationStyle = UIModalPresentationFullScreen;
//        [self presentViewController:composeview animated:<#(BOOL)#> completion:<#^(void)completion#>]
        [composeViewController presentFromRootViewController];

        composeViewController.completionHandler = ^(REComposeViewController *composeViewController, REComposeResult result) {
            
            if (result == REComposeResultCancelled) {
                NSLog(@"Cancelled");
                [composeViewController dismissViewControllerAnimated:YES completion:nil];

            }
            
            if (result == REComposeResultPosted) {
                [composeViewController dismissViewControllerAnimated:YES completion:nil];
                [ProgressHUD show:@"Posting"];
                PFObject *post = [PFObject objectWithClassName:@"Photo"];
                [post setObject:@"text" forKey:@"type"];
                PFACL *defaultACL = [PFACL ACL];
                [defaultACL setPublicReadAccess:YES];
                [defaultACL setPublicWriteAccess:YES];
                [post setACL:defaultACL];
                [post setObject:composeViewController.text forKey:@"text"];
                [post setObject:[PFUser currentUser] forKey:@"user"];
                
                NSRegularExpression *_regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:nil];
                NSArray *_matches = [_regex matchesInString:composeViewController.text options:0 range:NSMakeRange(0, composeViewController.text.length)];
                NSMutableArray *hashtagsArray = [[NSMutableArray alloc]init];
                for (NSTextCheckingResult *match in _matches) {
                    NSRange wordRange = [match rangeAtIndex:1];
                    NSString* word = [composeViewController.text substringWithRange:wordRange];
                    [hashtagsArray addObject:[word lowercaseString]];
                }
                PFObject *comment = [PFObject objectWithClassName:kESActivityClassKey];
                [comment setObject:composeViewController.text forKey:kESActivityContentKey]; // Set comment text
                [comment setObject:[PFUser currentUser] forKey:kESActivityFromUserKey]; // Set fromUser
                [comment setObject:kESActivityTypeCommentPost forKey:kESActivityTypeKey];
                [comment setObject:post forKey:kESActivityPhotoKey];

                if (hashtagsArray.count > 0) {
                    
                    [comment setObject:hashtagsArray forKey:@"hashtags"];
                    [comment setObject:@"YES" forKey:@"noneread"];
                    [comment saveInBackground];
                    
                    for (int i = 0; i < hashtagsArray.count; i++) {
                        
                        //In the Hashtags class, if the hashtag doesn't already exist, we add it to the list a user can search through.
                        
                        NSString *hash = [[hashtagsArray objectAtIndex:i] lowercaseString];
                        PFQuery *hashQuery = [PFQuery queryWithClassName:@"Hashtags"];
                        [hashQuery whereKey:@"hashtag" equalTo:hash];
                        [hashQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error) {
                                if (objects.count == 0) {
                                    PFObject *hashtag = [PFObject objectWithClassName:@"Hashtags"];
                                    [hashtag setObject:hash forKey:@"hashtag"];
                                    [hashtag saveInBackground];
                                }
                            }
                        }];
                    }
                }

                PFObject *mention = [PFObject objectWithClassName:kESActivityClassKey];
                [mention setObject:[PFUser currentUser] forKey:kESActivityFromUserKey]; // Set fromUser
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:nil];
                NSArray *matches = [regex matchesInString:composeViewController.text options:0 range:NSMakeRange(0, composeViewController.text.length)];
                NSMutableArray *mentionsArray = [[NSMutableArray alloc]init];
                for (NSTextCheckingResult *match in matches) {
                    NSRange wordRange = [match rangeAtIndex:1];
                    NSString* word = [composeViewController.text substringWithRange:wordRange];
                    [mentionsArray addObject:word];
                }
                if (mentionsArray.count > 0 ) {
                    PFQuery *mentionQuery = [PFUser query];
                    [mentionQuery whereKey:@"usernameFix" containedIn:mentionsArray];
                    [mentionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            [mention setObject:objects forKey:@"mentions"]; // Set toUser
                            [mention setObject:kESActivityTypeMention forKey:kESActivityTypeKey];
                            [mention setObject:post forKey:kESActivityPhotoKey];
                            [mention saveEventually];
                        }
                    }];
                }

                
                [post saveInBackgroundWithBlock:^(BOOL result, NSError *error){
                    if (!error) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:ESTabBarControllerDidFinishEditingPhotoNotification object:post];
                        [ProgressHUD dismiss];
                    }
                    else {
                        [ProgressHUD showError:@"Connection error!"];
                    }
                }];

            }
            
        };
    }
}

#pragma mark - ESTabBarController

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

#pragma mark - ()

- (void)photoCaptureButtonAction:(id)sender {
    //This is a fix for the simulator, to test tweets. We don't want the camera to automatically pop up.
//    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
//    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
//    if (cameraDeviceAvailable && photoLibraryAvailable) {
        NSArray *menuItems = @[[[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ButtonCamera"] title:NSLocalizedString(@"Take Photo", nil)],
                               [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"video_camera"] title:NSLocalizedString(@"Take Video", nil)],
                               [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"photo_image"] title:NSLocalizedString(@"Choose Photo", nil)],
                               [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"Video"] title:NSLocalizedString(@"Choose Video", nil)],
                               [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"pencil-icon"] title:NSLocalizedString(@"Text", nil)]];
        RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
        gridMenu.delegate = self;
        gridMenu.menuStyle = RNGridMenuStyleGrid;
        gridMenu.itemSize = CGSizeMake(150, 100);
        [gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
//    } else {
//        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
//        [self shouldPresentPhotoCaptureController];
//    }
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = FALSE;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    cameraUI.modalPresentationStyle = UIModalPresentationFullScreen;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:cameraUI animated:YES completion:nil];
    });
    
    return YES;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    cameraUI.view.frame = [[UIScreen mainScreen] bounds];
    cameraUI.modalPresentationStyle = UIModalPresentationFullScreen;
    dispatch_async(dispatch_get_main_queue(), ^{

        [self presentViewController:cameraUI animated:YES completion:^{
            
        }];
    });
    
    
    
    return YES;
}
- (UIImage *) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (BOOL) shouldPresentVideoCaptureController
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) return NO;
    NSString *type = (NSString *)kUTTypeMovie;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
  //  imagePicker.videoMaximumDuration = VIDEO_LENGTH;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:type])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObject:type];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
             && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:type])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.mediaTypes = [NSArray arrayWithObject:type];
    }
    else return NO;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:imagePicker animated:YES completion:nil];
    });
    //---------------------------------------------------------------------------------------------------------------------------------------------
    return YES;
}
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    [self shouldPresentPhotoCaptureController];
}
- (void)useNotificationWithString:(NSNotification *)notification //use notification method and logic
{
    // This key must match the key in postNotificationWithString: exactly.
    
    NSString *key = @"CommunicationStringValue";
    NSDictionary *dictionary = [notification userInfo];
    NSString *stringValueToUse = [dictionary valueForKey:key];
    if([stringValueToUse isEqualToString:@"ChangeTheme"])
    {
        
        
    }
}
#pragma mark - CLImageEditor delegate
- (void)imageEditor:(CLImageEditor *)editor didFinishEdittingWithImage:(UIImage *)image
{
    
    ESEditPhotoViewController *viewController = [[ESEditPhotoViewController alloc] initWithImage:image isEditView:FALSE];
    viewController.isEdit = FALSE;
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    self.navController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navController pushViewController:viewController animated:NO];
    [editor dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:self.navController animated:YES completion:nil];
    
}

- (void)imageEditor:(CLImageEditor *)editor willDismissWithImageView:(UIImageView *)imageView canceled:(BOOL)canceled
{
    
}

@end
