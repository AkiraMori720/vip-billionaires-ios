//
//  ESEditProfileViewController.m
//  d'Netzwierk
//
//  Created by Eric Schanet on 08.11.14.
//
//

#import "ESEditProfileViewController.h"
#import "ESPrivacyPolicyViewController.h"

#define kOFFSET_FOR_KEYBOARD 80.0

#define MAXLENGTH 40
#define MAX_LENGTH 110

#define SERVER_DATE_FORMAT_STRING @"dd'.'MM'.'yyyy"
#define JAPANESE_DATE_FORMAT_STRING @"yyyy'.'MM'.'dd"

BOOL changeHeader = YES;
BOOL tutorial;
CGFloat animatedDistance;

typedef enum {
    kPAWSettingsTableViewDistance = 0,
    kPAWSettingsTableViewLogout,
    kPAWSettingsTableViewNumberOfSections
} kPAWSettingsTableViewSections;

typedef enum {
    kPAWSettingsLogoutDialogLogout = 0,
    kPAWSettingsLogoutDialogCancel,
    kPAWSettingsLogoutDialogNumberOfButtons
} kPAWSettingsLogoutDialogButtons;

typedef enum {
    kPAWSettingsTableViewDistanceSection250FeetRow = 0,
    kPAWSettingsTableViewDistanceSection1000FeetRow,
    kPAWSettingsTableViewDistanceSection4000FeetRow,
    kPAWSettingsTableViewDistanceNumberOfRows
} kPAWSettingsTableViewDistanceSectionRows;

@implementation ESEditProfileViewController

@synthesize _tableView;
@synthesize nameTextField,cityTextField,websiteTextField,mentionTextField,bioTextview,saveInfoBtn, emailTextField,birthdayTextField,genderTextField, sensitiveData,pickerView,genderPicker,colorProfileView, imageView3,countryTextField,educationTextField,jobTextField,textFiledToolbar,countryPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andOptionForTutorial:(NSString *)string{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ([string isEqualToString:@"YES"]) {
        tutorial = YES;
    }
    else tutorial = NO;
    if (self) {
        // Custom initialization
        
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Edit Profile Page");
    self.nameTextField.text = @"";
    self.mentionTextField.text = @"";
    self.cityTextField.text = @"";
    self.websiteTextField.text = @"";
    self.emailTextField.text = @"";
    self.countryTextField.text = @"";
    self.educationTextField.text = @"";
    self.jobTextField.text = @"";
    self.bioTextview.text = @"";
    self.genderTextField.text = @"";
    self.birthdayTextField.text = @"";
    
    self.arrCountryList = [[NSMutableArray alloc] init];
    if (![[[PFUser currentUser] objectForKey:@"acceptedTerms"] isEqualToString:@"Yes"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Terms of Use", nil) message:NSLocalizedString(@"Please accept the terms of use before using this app",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"I accept", nil), NSLocalizedString(@"Show terms", nil), nil];
        [alert show];
        alert.tag = 99;
        
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"themeColor"]) {
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeColor"];
        UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        self.navigationController.navigationBar.barTintColor = color;
    }
    else {
        self.navigationController.navigationBar.barTintColor = def_TopBar_Color;
    }
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    saveInfoBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(presaveInformation)];
    [saveInfoBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:def_Golden_Color,  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 80, 30)];
    
    [saveBtn setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveBtn.backgroundColor = def_Golden_Color;
    [saveBtn addTarget:self action:@selector(presaveInformation) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.layer.cornerRadius = 15;
    saveInfoBtn.customView = saveBtn;
    saveInfoBtn.customView.backgroundColor = def_Golden_Color;
    self.navigationItem.rightBarButtonItem = saveInfoBtn;
    
    //saveInfoBtn.enabled = NO;
    //saveInfoBtn.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];

    
    if (tutorial == NO) {
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 80, 30)];
        [cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelBtn.backgroundColor = def_Golden_Color;
        [cancelBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.layer.cornerRadius = 15;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelBtn];

    }
    
    self.navigationItem.title = NSLocalizedString(@"Edit Profile", nil);
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor whiteColor]
    };
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    [self.view addSubview:_tableView];
    _tableView.backgroundView.backgroundColor = [UIColor clearColor];
    [_tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_splash"]]];
    [_tableView setSeparatorColor:[UIColor clearColor]];
    
    PFQuery *query = [PFQuery queryWithClassName:@"SensitiveData"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *result, NSError *error) {
        if (!error) {
            sensitiveData = result;
        } else {
            if (tutorial == NO) {
                [ProgressHUD showError:NSLocalizedString(@"Connection error...", nil)];
            }
        }
    }];
    [self getCountryListData];
    
  //  [self askToSendPushnotifications];

}
- (void)askToSendPushnotifications {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Send a push to the news channel"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
    popPresenter.sourceView = self.view;
    UIAlertAction *Okbutton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self sendPushNotifications];
    }];
    [alert addAction:Okbutton];
    UIAlertAction *cancelbutton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alert addAction:cancelbutton];
    popPresenter.sourceRect = self.view.frame;
    alert.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)sendPushNotifications {
    [PFCloud callFunctionInBackground:@"sendPushToYourself"
                       withParameters:@{}
                                block:^(id object, NSError *error) {
                                    if (!error) {
                                        NSLog(@"PUSH SENT");
                                    }else{
                                        NSLog(@"ERROR SENDING PUSH: %@",error.localizedDescription);
                                    }
                                }];
}
#pragma mark - UINavigationBar-based actions

- (void)done:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SecondViewControllerDismissed" object:nil userInfo:nil];
    
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
    
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 6;
            break;
        case 3:
            return 3;
            break;
        default:
            return 0;
    };
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
//    switch (section) {
//        case 0:
//            return 50;
//            break;
//        default:
//            return 30;
//    };
//
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 ) return 260;
    if (indexPath.row == 1 ) return 180;
    return 60;
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            if (IS_IPHONE6) {
                return  85;
            }
            else return  105;
            
        }
    }
    if (indexPath.section == 0) {

        if (indexPath.row==0) {
            
            return 0;
        }
    }
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    CGFloat topPosition = 20, spacingHeight = 10, rowHeight = 34;
    CGFloat leftPosition = 110;
    if (indexPath.row == 0) {
        cell = [aTableView dequeueReusableCellWithIdentifier:@"cell1"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;;
        }
        
        UIView *bigView = [[UIView alloc] initWithFrame:CGRectMake(12, 0, SCR_W - 24, 250)];
        bigView.layer.cornerRadius = 10;
        bigView.backgroundColor = [UIColor whiteColor];
        bigView.layer.borderWidth = 0.5;
        bigView.layer.borderColor = [UIColor colorWithWhite:0.7f alpha:1].CGColor;

        //------------------ Name -------------------
        
        UILabel* labelName = [[UILabel alloc] initWithFrame:CGRectMake(20, topPosition, 100, rowHeight)];
        labelName.text = NSLocalizedString(@"Name", nil);
        labelName.font = [UIFont fontWithName:@"Montserrat-SemiBold" size:16];
        labelName.textColor = [UIColor grayColor];
        [bigView addSubview:labelName];
        
        nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(leftPosition, topPosition, [UIScreen mainScreen].bounds.size.width - 220, rowHeight)];
        nameTextField.adjustsFontSizeToFitWidth = YES;
        nameTextField.textColor = [UIColor blackColor];
        nameTextField.backgroundColor = [UIColor whiteColor];
        nameTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        nameTextField.textAlignment = UITextAlignmentLeft;
        nameTextField.delegate = self;
        
        nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
        [nameTextField setEnabled: YES];
        if ([[PFUser currentUser] objectForKey:kESUserDisplayNameKey]) {
            nameTextField.text = [[PFUser currentUser] objectForKey:kESUserDisplayNameKey];
        }
        nameTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
        nameTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
        nameTextField.keyboardType = UIKeyboardTypeDefault;
        nameTextField.returnKeyType = UIReturnKeyDone;
        nameTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        nameTextField.tag = 0;
        nameTextField.backgroundColor = [UIColor clearColor];
        [bigView addSubview:nameTextField];
        
        UIView* underLineName = [[UIView alloc] initWithFrame:CGRectMake(10,rowHeight + topPosition, SCR_W - 150, 1)];
        underLineName.backgroundColor = [UIColor colorWithWhite:0.7f alpha:1];
        [bigView addSubview:underLineName];
        
        
        changeHeader = NO;
        self.imageView2 = [[PFImageView alloc] initWithFrame:CGRectMake(SCR_W - 120, 20, 80, 80)];
        self.imageView2.layer.cornerRadius = 40;
        self.imageView2.layer.masksToBounds = true;
        self.imageView2.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView2.image = [UIImage imageNamed:@"AvatarPlaceholder"]; // placeholder image
        
        self.imageView2.file = (PFFile *)[[PFUser currentUser] objectForKey:kESUserProfilePicSmallKey]; // remote image
        [bigView addSubview:self.imageView2];
        [self.imageView2 loadInBackground];
        UIButton* imageProfileButton = [[UIButton alloc] initWithFrame:CGRectMake(SCR_W - 140, 20, 80, 80)];
        imageProfileButton.layer.cornerRadius = 40;
        [imageProfileButton addTarget:self action:@selector(changeProfilePicture) forControlEvents:UIControlEventTouchUpInside];
        [bigView addSubview:imageProfileButton];
        //------------------ Phone -------------------
        
        topPosition += spacingHeight + rowHeight;
        UILabel* labelPhone = [[UILabel alloc] initWithFrame:CGRectMake(20, topPosition, 100, rowHeight)];
        labelPhone.text = NSLocalizedString(@"Phone", nil);
        labelPhone.font = [UIFont fontWithName:@"Montserrat-SemiBold" size:16];
        labelPhone.textColor = [UIColor grayColor];
        [bigView addSubview:labelPhone];
        
        mentionTextField = [[UITextField alloc] initWithFrame:CGRectMake(leftPosition, topPosition, SCR_W - 280, rowHeight)];
         mentionTextField.adjustsFontSizeToFitWidth = YES;
         mentionTextField.textColor = [UIColor blackColor];
         mentionTextField.backgroundColor = [UIColor whiteColor];
         mentionTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
         mentionTextField.textAlignment = UITextAlignmentLeft;
         mentionTextField.delegate = self;

         mentionTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
         [mentionTextField setEnabled: YES];
         if ([[PFUser currentUser] objectForKey:@"phone"]) {
             mentionTextField.text = [NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"phone"]];
         }
         mentionTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
         mentionTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
         mentionTextField.keyboardType = UIKeyboardTypePhonePad;
         mentionTextField.returnKeyType = UIReturnKeyDone;
         mentionTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
         mentionTextField.tag = 1;
        [bigView addSubview:mentionTextField];
        
        UIView* underlinePhone = [[UIView alloc] initWithFrame:CGRectMake(10,rowHeight + topPosition, SCR_W - 150, 1)];
        underlinePhone.backgroundColor = [UIColor colorWithWhite:0.7f alpha:1];
        [bigView addSubview:underlinePhone];
        
        
        ///***************** e mail*********************
        
        
        topPosition += spacingHeight + rowHeight;
        UILabel* labelEmail = [[UILabel alloc] initWithFrame:CGRectMake(20, topPosition, 100, rowHeight)];
        labelEmail.text = NSLocalizedString(@"Email", nil);
        labelEmail.font = [UIFont fontWithName:@"Montserrat-SemiBold" size:16];
        labelEmail.textColor = [UIColor grayColor];
        [bigView addSubview:labelEmail];
        emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(leftPosition, topPosition, [UIScreen mainScreen].bounds.size.width - 100, rowHeight)];
        emailTextField.adjustsFontSizeToFitWidth = YES;
        emailTextField.textColor = [UIColor blackColor];
        emailTextField.backgroundColor = [UIColor whiteColor];
        emailTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        emailTextField.textAlignment = UITextAlignmentLeft;
        emailTextField.delegate = self;
        emailTextField.text = [[PFUser currentUser]objectForKey:kESUserEmailKey];
        
        emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
        [emailTextField setEnabled: YES];
        emailTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
        emailTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
        emailTextField.keyboardType = UIKeyboardTypeDefault;
        emailTextField.returnKeyType = UIReturnKeyDone;
        emailTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        emailTextField.tag = 6;
        
        emailTextField.backgroundColor = [UIColor clearColor];
        [bigView addSubview:emailTextField];
        
        UIView* underlineEmail = [[UIView alloc] initWithFrame:CGRectMake(10,rowHeight + topPosition, SCR_W - 50, 1)];
        underlineEmail.backgroundColor = [UIColor colorWithWhite:0.7f alpha:1];
        [bigView addSubview:underlineEmail];
        
        
        
        ///***************** gender*********************
        
        
        topPosition += spacingHeight + rowHeight;
        UILabel* labelGender = [[UILabel alloc] initWithFrame:CGRectMake(20, topPosition, 100, rowHeight)];
        labelGender.text = NSLocalizedString(@"Gender", nil);
        labelGender.font = [UIFont fontWithName:@"Montserrat-SemiBold" size:16];
        labelGender.textColor = [UIColor grayColor];
        [bigView addSubview:labelGender];
        NSString *string = [[PFUser currentUser] objectForKey:@"Gender"];
        genderTextField = [[NonPasteUITextField alloc] initWithFrame:CGRectMake(leftPosition  , topPosition, [UIScreen mainScreen].bounds.size.width - 50, rowHeight)];
        genderTextField.adjustsFontSizeToFitWidth = YES;
        genderTextField.textColor = [UIColor blackColor];
        genderTextField.backgroundColor = [UIColor whiteColor];
        genderTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        genderTextField.textAlignment = UITextAlignmentLeft;
        genderTextField.delegate = self;
        
        genderTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
        [genderTextField setEnabled: YES];
        if ([[PFUser currentUser] objectForKey:@"Gender"]) {
            genderTextField.text = string;
        }
        genderTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
        genderTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
        genderTextField.keyboardType = UIKeyboardTypeDefault;
        genderTextField.returnKeyType = UIReturnKeyDone;
        genderTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        genderTextField.tag = 5;
        
        genderTextField.backgroundColor = [UIColor clearColor];
        [bigView addSubview:genderTextField];
        
        UIView* underlineGender = [[UIView alloc] initWithFrame:CGRectMake(10,rowHeight + topPosition, SCR_W - 50, 1)];
        underlineGender.backgroundColor = [UIColor colorWithWhite:0.7f alpha:1];
        [bigView addSubview:underlineGender];
        
        [cell.contentView addSubview:bigView];
        
        
        ///***************** birthday*********************
        
        
        topPosition += spacingHeight + rowHeight;
        UILabel* labelDOB = [[UILabel alloc] initWithFrame:CGRectMake(20, topPosition, 100, rowHeight)];
        labelDOB.text = NSLocalizedString(@"Birthday", nil);
        labelDOB.font = [UIFont fontWithName:@"Montserrat-SemiBold" size:16];
        labelDOB.textColor = [UIColor grayColor];
        [bigView addSubview:labelDOB];
        
        string = [[PFUser currentUser] objectForKey:@"Birthday"];
        
        birthdayTextField = [[NonPasteUITextField alloc] initWithFrame:CGRectMake(leftPosition, topPosition, [UIScreen mainScreen].bounds.size.width - 150, rowHeight)];
        birthdayTextField.adjustsFontSizeToFitWidth = YES;
        birthdayTextField.textColor = [UIColor blackColor];
        birthdayTextField.backgroundColor = [UIColor whiteColor];
        birthdayTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        birthdayTextField.textAlignment = UITextAlignmentLeft;
        birthdayTextField.delegate = self;
        
        birthdayTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
        [birthdayTextField setEnabled: YES];
        if ([[PFUser currentUser] objectForKey:@"Birthday"]) {
            birthdayTextField.text = [self fromServerDateString:string];
        }
        birthdayTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
        birthdayTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];
        birthdayTextField.keyboardType = UIKeyboardTypeDefault;
        birthdayTextField.returnKeyType = UIReturnKeyDone;
        birthdayTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        birthdayTextField.tag = 4;
        birthdayTextField.backgroundColor = [UIColor clearColor];
        
        [bigView addSubview:birthdayTextField];
        
    } else if (indexPath.row == 1) {
        cell = [aTableView dequeueReusableCellWithIdentifier:@"cell2"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UIView *bigView = [[UIView alloc] initWithFrame:CGRectMake(12, 20, SCR_W - 24, 150)];
        bigView.layer.cornerRadius = 10;
        bigView.backgroundColor = [UIColor whiteColor];
        bigView.layer.borderWidth = 0.5;
        bigView.layer.borderColor = [UIColor colorWithWhite:0.7f alpha:1].CGColor;

        //------------------ Bio -------------------
        
        topPosition = 10;
        
        UILabel* labelName = [[UILabel alloc] initWithFrame:CGRectMake(20, topPosition, 100, rowHeight)];
        labelName.text = NSLocalizedString(@"Bio", nil);
        labelName.font = [UIFont fontWithName:@"Montserrat-SemiBold" size:16];
        labelName.textColor = [UIColor grayColor];
        [bigView addSubview:labelName];

        NSString *string = [[PFUser currentUser] objectForKey:@"UserInfo"];
        CGSize maximumLabelSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 150,FLT_MAX);
        CGSize expectedLabelSize = [string sizeWithFont:[UIFont fontWithName:@"Montserrat-Regular" size:16]
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:NSLineBreakByWordWrapping];
        
        bioTextview=[[UITextView alloc] initWithFrame:CGRectMake(leftPosition - 2, topPosition - 2, [UIScreen mainScreen].bounds.size.width - 150, 130)];
        bioTextview.font = [UIFont fontWithName:@"Montserrat-Regular" size:16.0];
        if ([[PFUser currentUser] objectForKey:@"UserInfo"]) {
            bioTextview.text= string;
        }
        
        bioTextview.backgroundColor = [UIColor clearColor];
        bioTextview.textColor=[UIColor colorWithWhite: 0 alpha: 1];
        bioTextview.editable=YES;
        bioTextview.keyboardType = UIKeyboardTypeDefault;
        bioTextview.returnKeyType = UIReturnKeyDone;
        bioTextview.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        bioTextview.textAlignment = UITextAlignmentLeft;
        bioTextview.delegate = self;
        bioTextview.backgroundColor = [UIColor clearColor];
        
        [bigView addSubview:bioTextview];
        [cell.contentView addSubview:bigView];
    } else {
        cell = [aTableView dequeueReusableCellWithIdentifier:@"cell3"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell3"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UIView *bigView = [[UIView alloc] initWithFrame:CGRectMake(12, 20, SCR_W - 24, rowHeight + 10)];
        bigView.layer.cornerRadius = 20;
        bigView.backgroundColor = [UIColor whiteColor];
        bigView.layer.borderWidth = 0.5;
        bigView.layer.borderColor = [UIColor colorWithWhite:0.7f alpha:1].CGColor;
        
        topPosition = 5;
        
        UILabel* labelName = [[UILabel alloc] initWithFrame:CGRectMake(20, topPosition, 100, rowHeight)];
        
        labelName.font = [UIFont fontWithName:@"Montserrat-SemiBold" size:16];
        labelName.textColor = [UIColor grayColor];
        [bigView addSubview:labelName];
        
        UITextField* tempField;
        switch (indexPath.row) {
            case 2:
                labelName.text = NSLocalizedString(@"Country", nil);
                countryTextField = [[NonPasteUITextField alloc] initWithFrame:CGRectMake(leftPosition, topPosition, [UIScreen mainScreen].bounds.size.width - 150, rowHeight)];
                tempField = countryTextField;
                break;
            case 3:
                labelName.text = NSLocalizedString(@"City", nil);
                cityTextField = [[NonPasteUITextField alloc] initWithFrame:CGRectMake(leftPosition, topPosition, [UIScreen mainScreen].bounds.size.width - 150, rowHeight)];
                tempField = cityTextField;
                break;
            case 4:
                labelName.text = NSLocalizedString(@"Website", nil);
                websiteTextField = [[UITextField alloc] initWithFrame:CGRectMake(leftPosition, topPosition, [UIScreen mainScreen].bounds.size.width - 150, rowHeight)];
                tempField = websiteTextField;
                break;
            case 5:
                labelName.text = NSLocalizedString(@"Education", nil);
                educationTextField = [[UITextField alloc] initWithFrame:CGRectMake(leftPosition, topPosition, [UIScreen mainScreen].bounds.size.width - 150, rowHeight)];
                tempField = educationTextField;
                break;
            case 6:
                labelName.text = NSLocalizedString(@"Job", nil);
                jobTextField = [[UITextField alloc] initWithFrame:CGRectMake(leftPosition, topPosition, [UIScreen mainScreen].bounds.size.width - 150, rowHeight)];
                tempField = jobTextField;
                break;
        }
        
        
        
        tempField.adjustsFontSizeToFitWidth = YES;
        tempField.textColor = [UIColor blackColor];
        tempField.backgroundColor = [UIColor whiteColor];
        tempField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        tempField.textAlignment = UITextAlignmentLeft;
        tempField.delegate = self;
        
        
        tempField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
        [tempField setEnabled: YES];
        
        if (indexPath.row == 2) {
            if ([[PFUser currentUser] objectForKey:@"country"]) {
                countryTextField.text = [[PFUser currentUser] objectForKey:@"country"];
            }
        } else if (indexPath.row == 3) {
            if ([[PFUser currentUser] objectForKey:@"Location"]) {
                cityTextField.text = [[PFUser currentUser] objectForKey:@"Location"];
            }
        } else if (indexPath.row == 4) {
            if ([[PFUser currentUser] objectForKey:@"Website"]) {
                websiteTextField.text = [[PFUser currentUser] objectForKey:@"Website"];
            }
        } else if (indexPath.row == 5) {
            if ([[PFUser currentUser] objectForKey:@"education"]) {
                educationTextField.text = [[PFUser currentUser] objectForKey:@"education"];
            }
        } else if (indexPath.row == 6) {
            if ([[PFUser currentUser] objectForKey:@"job"]) {
                jobTextField.text = [[PFUser currentUser] objectForKey:@"job"];
            }
        }
        
        tempField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
        tempField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
        tempField.keyboardType = UIKeyboardTypeDefault;
        tempField.returnKeyType = UIReturnKeyDone;
        tempField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        tempField.tag = 2;
        tempField.backgroundColor = [UIColor clearColor];
        
        [bigView addSubview: tempField];
        [cell.contentView addSubview:bigView];
        
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath1:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SettingsTableView1";
    static NSString *identifier2 = @"SettingsTableView2";
    if (indexPath.section == 0) {
        
        ESEditProfilePhotoTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
        
        if ( cell == nil )
        {
            cell = [[ESEditProfilePhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        if (indexPath.row == 0) {
            /*cell.textLabel.text = NSLocalizedString(@"Header Photo", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
            self.imageView1 = [[PFImageView alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
            self.imageView1.image = [UIImage imageNamed:@"AvatarPlaceholder"]; // placeholder image
            self.imageView1.file = (PFFile *)[[PFUser currentUser] objectForKey:kESUserHeaderPicSmallKey]; // remote image
            [cell addSubview:self.imageView1];
            [self.imageView1 loadInBackground];*/
            cell.textLabel.text=@"";
            [cell setHidden:TRUE];
            
        }
        
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Profile Photo", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
            self.imageView2 = [[PFImageView alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
            self.imageView2.layer.cornerRadius = 20;
            self.imageView2.layer.masksToBounds = true;
            self.imageView2.contentMode = UIViewContentModeScaleAspectFill;
            self.imageView2.image = [UIImage imageNamed:@"AvatarPlaceholder"]; // placeholder image
            self.imageView2.file = (PFFile *)[[PFUser currentUser] objectForKey:kESUserProfilePicSmallKey]; // remote image
            [cell addSubview:self.imageView2];
            [self.imageView2 loadInBackground];
        }
        /*else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Personal color", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
            NSArray *components = [[[PFUser currentUser] objectForKey:@"profileColor"] componentsSeparatedByString:@","];
            CGFloat r = [[components objectAtIndex:0] floatValue];
            CGFloat g = [[components objectAtIndex:1] floatValue];
            CGFloat b = [[components objectAtIndex:2] floatValue];
            CGFloat a = [[components objectAtIndex:3] floatValue];
            UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            self.imageView3 = [[PFImageView alloc] initWithFrame:CGRectMake(12, 7, 36, 36)];
            self.imageView3.backgroundColor = color;
            self.imageView3.layer.cornerRadius = 6;
            [cell addSubview:self.imageView3];
            
            
            [cell.contentView addSubview:colorProfileView];
            
            
        }*/
        
        cell.backgroundColor = [UIColor clearColor];
        return cell;
        
    }
    
    else if (indexPath.section == 1) {
        
        ESEditProfileTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
        if ( cell == nil )
        {
            cell = [[ESEditProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }

        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Name", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
            nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, [UIScreen mainScreen].bounds.size.width - 100, 30)];
            nameTextField.adjustsFontSizeToFitWidth = YES;
            nameTextField.textColor = [UIColor blackColor];
            nameTextField.backgroundColor = [UIColor whiteColor];
            nameTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            nameTextField.textAlignment = UITextAlignmentLeft;
            nameTextField.delegate = self;
            
            nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
            [nameTextField setEnabled: YES];
            if ([[PFUser currentUser] objectForKey:kESUserDisplayNameKey]) {
                nameTextField.text = [[PFUser currentUser] objectForKey:kESUserDisplayNameKey];
            }
            nameTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
            nameTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
            nameTextField.keyboardType = UIKeyboardTypeDefault;
            nameTextField.returnKeyType = UIReturnKeyDone;
            nameTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            nameTextField.tag = 0;
            nameTextField.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:nameTextField];

        }
        else if (indexPath.row == 1) {
            //cell.textLabel.text = NSLocalizedString(@"Mention", nil); shweta
            cell.textLabel.text = NSLocalizedString(@"Phone", nil);

            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            mentionTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, [UIScreen mainScreen].bounds.size.width - 100, 30)];
            mentionTextField.adjustsFontSizeToFitWidth = YES;
            mentionTextField.textColor = [UIColor blackColor];
            mentionTextField.backgroundColor = [UIColor whiteColor];
            mentionTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            mentionTextField.textAlignment = UITextAlignmentLeft;
            mentionTextField.delegate = self;

            mentionTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
            [mentionTextField setEnabled: YES];
            if ([[PFUser currentUser] objectForKey:@"phone"]) {
                mentionTextField.text = [NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"phone"]];
            }
            mentionTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
            mentionTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
            mentionTextField.keyboardType = UIKeyboardTypePhonePad;
            mentionTextField.returnKeyType = UIReturnKeyDone;
            mentionTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
            mentionTextField.tag = 1;
            [cell.contentView addSubview:mentionTextField];
            mentionTextField.backgroundColor = [UIColor clearColor];
            
        }
        
        cell.backgroundColor = [UIColor clearColor];;
        return cell;
    }
    else if (indexPath.section == 2) {
        
        ESEditProfileTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
        if ( cell == nil )
        {
            cell = [[ESEditProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Bio", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
            NSString *string = [[PFUser currentUser] objectForKey:@"UserInfo"];
            CGSize maximumLabelSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 100,FLT_MAX);
            CGSize expectedLabelSize = [string sizeWithFont:[UIFont fontWithName:@"Montserrat-Regular" size:16]
                                          constrainedToSize:maximumLabelSize
                                              lineBreakMode:NSLineBreakByWordWrapping];
            
            bioTextview=[[UITextView alloc] initWithFrame:CGRectMake(90, 5, [UIScreen mainScreen].bounds.size.width - 100, expectedLabelSize.height+40)];
            bioTextview.font = [UIFont fontWithName:@"Montserrat-Regular" size:16.0];
            if ([[PFUser currentUser] objectForKey:@"UserInfo"]) {
                bioTextview.text= string;
            }
            bioTextview.backgroundColor = [UIColor clearColor];
            bioTextview.textColor=[UIColor colorWithWhite: 0 alpha: 1];
            bioTextview.editable=YES;
            bioTextview.keyboardType = UIKeyboardTypeDefault;
            bioTextview.returnKeyType = UIReturnKeyDone;
            bioTextview.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            bioTextview.textAlignment = UITextAlignmentLeft;
            bioTextview.delegate = self;
            bioTextview.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:bioTextview];
            
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Country", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
            countryTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, [UIScreen mainScreen].bounds.size.width - 100, 30)];
            countryTextField.adjustsFontSizeToFitWidth = YES;
            countryTextField.textColor = [UIColor blackColor];
            countryTextField.backgroundColor = [UIColor whiteColor];
            countryTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            countryTextField.textAlignment = UITextAlignmentLeft;
            countryTextField.delegate = self;
            
            countryTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
            [countryTextField setEnabled: YES];
            if ([[PFUser currentUser] objectForKey:@"country"]) {
                countryTextField.text = [[PFUser currentUser] objectForKey:@"country"];
            }
            countryTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
            countryTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
            countryTextField.keyboardType = UIKeyboardTypeDefault;
            countryTextField.returnKeyType = UIReturnKeyDone;
            countryTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            countryTextField.tag = 2;
            countryTextField.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:countryTextField];
            
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"City", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
            cityTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, [UIScreen mainScreen].bounds.size.width - 100, 30)];
            cityTextField.adjustsFontSizeToFitWidth = YES;
            cityTextField.textColor = [UIColor blackColor];
            cityTextField.backgroundColor = [UIColor whiteColor];
            cityTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            cityTextField.textAlignment = UITextAlignmentLeft;
            cityTextField.delegate = self;
            
            cityTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
            [cityTextField setEnabled: YES];
            if ([[PFUser currentUser] objectForKey:@"Location"]) {
                cityTextField.text = [[PFUser currentUser] objectForKey:@"Location"];
            }
            cityTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
            cityTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
            cityTextField.keyboardType = UIKeyboardTypeDefault;
            cityTextField.returnKeyType = UIReturnKeyDone;
            cityTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            cityTextField.tag = 2;
            cityTextField.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:cityTextField];
            
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Website", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
            websiteTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, [UIScreen mainScreen].bounds.size.width - 100, 30)];
            websiteTextField.adjustsFontSizeToFitWidth = YES;
            websiteTextField.textColor = [UIColor blackColor];
            websiteTextField.backgroundColor = [UIColor whiteColor];
            websiteTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            websiteTextField.textAlignment = UITextAlignmentLeft;
            websiteTextField.delegate = self;
            
            websiteTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
            [websiteTextField setEnabled: YES];
            if ([[PFUser currentUser] objectForKey:@"Website"]) {
                websiteTextField.text = [[PFUser currentUser] objectForKey:@"Website"];
            }
            websiteTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
            websiteTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
            websiteTextField.keyboardType = UIKeyboardTypeDefault;
            websiteTextField.returnKeyType = UIReturnKeyDone;
            websiteTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            websiteTextField.tag = 3;
            websiteTextField.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:websiteTextField];
            
        }
        else if (indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"Education", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
            educationTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, [UIScreen mainScreen].bounds.size.width - 100, 30)];
            educationTextField.adjustsFontSizeToFitWidth = YES;
            educationTextField.textColor = [UIColor blackColor];
            educationTextField.backgroundColor = [UIColor whiteColor];
            educationTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            educationTextField.textAlignment = UITextAlignmentLeft;
            educationTextField.delegate = self;
            
            educationTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
            [educationTextField setEnabled: YES];
            if ([[PFUser currentUser] objectForKey:@"education"]) {
                educationTextField.text = [[PFUser currentUser] objectForKey:@"education"];
            }
            educationTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
            educationTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
            educationTextField.keyboardType = UIKeyboardTypeDefault;
            educationTextField.returnKeyType = UIReturnKeyDone;
            educationTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            educationTextField.tag = 2;
            educationTextField.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:educationTextField];
            
        }
        else if (indexPath.row == 5) {
            cell.textLabel.text = NSLocalizedString(@"Job", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
            jobTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, [UIScreen mainScreen].bounds.size.width - 100, 30)];
            jobTextField.adjustsFontSizeToFitWidth = YES;
            jobTextField.textColor = [UIColor blackColor];
            jobTextField.backgroundColor = [UIColor whiteColor];
            jobTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            jobTextField.textAlignment = UITextAlignmentLeft;
            jobTextField.delegate = self;
            
            jobTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
            [jobTextField setEnabled: YES];
            if ([[PFUser currentUser] objectForKey:@"job"]) {
                jobTextField.text = [[PFUser currentUser] objectForKey:@"job"];
            }
            jobTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
            jobTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
            jobTextField.keyboardType = UIKeyboardTypeDefault;
            jobTextField.returnKeyType = UIReturnKeyDone;
            jobTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            jobTextField.tag = 2;
            jobTextField.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:jobTextField];
            
        }
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    else if (indexPath.section == 3) {
        ESEditProfilePrivateTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier2];
        if ( cell == nil )
        {
            cell = [[ESEditProfilePrivateTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier2];
            
            if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"Birthday", nil);
                cell.textLabel.textColor = [UIColor grayColor];
                cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
                cell.textLabel.lineBreakMode = NSLineBreakByClipping;
                cell.textLabel.numberOfLines = 2;
                cell.detailTextLabel.backgroundColor = [UIColor clearColor];
                NSString *string = [[PFUser currentUser] objectForKey:@"Birthday"];
                
                birthdayTextField = [[NonPasteUITextField alloc] initWithFrame:CGRectMake(130, 10, [UIScreen mainScreen].bounds.size.width - 100, 30)];
                birthdayTextField.adjustsFontSizeToFitWidth = YES;
                birthdayTextField.textColor = [UIColor blackColor];
                birthdayTextField.backgroundColor = [UIColor whiteColor];
                birthdayTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
                birthdayTextField.textAlignment = UITextAlignmentLeft;
                birthdayTextField.delegate = self;
                
                birthdayTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
                [birthdayTextField setEnabled: YES];
                if ([[PFUser currentUser] objectForKey:@"Birthday"]) {
                    birthdayTextField.text = [self fromServerDateString:string];
                }
                birthdayTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
                birthdayTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];
                birthdayTextField.keyboardType = UIKeyboardTypeDefault;
                birthdayTextField.returnKeyType = UIReturnKeyDone;
                birthdayTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
                birthdayTextField.tag = 4;
                birthdayTextField.backgroundColor = [UIColor clearColor];
                
                [cell.contentView addSubview:birthdayTextField];
                
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Gender", nil);
                cell.textLabel.textColor = [UIColor grayColor];
                cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
                cell.detailTextLabel.backgroundColor = [UIColor clearColor];
                
                NSString *string = [[PFUser currentUser] objectForKey:@"Gender"];
                genderTextField = [[NonPasteUITextField alloc] initWithFrame:CGRectMake(130, 10, [UIScreen mainScreen].bounds.size.width - 100, 30)];
                genderTextField.adjustsFontSizeToFitWidth = YES;
                genderTextField.textColor = [UIColor blackColor];
                genderTextField.backgroundColor = [UIColor whiteColor];
                genderTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
                genderTextField.textAlignment = UITextAlignmentLeft;
                genderTextField.delegate = self;
                
                genderTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
                [genderTextField setEnabled: YES];
                if ([[PFUser currentUser] objectForKey:@"Gender"]) {
                    genderTextField.text = string;
                }
                genderTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
                genderTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
                genderTextField.keyboardType = UIKeyboardTypeDefault;
                genderTextField.returnKeyType = UIReturnKeyDone;
                genderTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
                genderTextField.tag = 5;
                
                genderTextField.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:genderTextField];
                
            }
            else if (indexPath.row == 0) {
                
                cell.textLabel.text = NSLocalizedString(@"Email", nil);
                cell.textLabel.textColor = [UIColor grayColor];
                cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
                cell.detailTextLabel.backgroundColor = [UIColor clearColor];
                
                
                emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(130, 10, [UIScreen mainScreen].bounds.size.width - 100, 30)];
                emailTextField.adjustsFontSizeToFitWidth = YES;
                emailTextField.textColor = [UIColor blackColor];
                emailTextField.backgroundColor = [UIColor whiteColor];
                emailTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
                emailTextField.textAlignment = UITextAlignmentLeft;
                emailTextField.delegate = self;
                emailTextField.text = [[PFUser currentUser]objectForKey:kESUserEmailKey];
                
                emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing; // no clear 'x' button to the right
                [emailTextField setEnabled: YES];
                emailTextField.textColor = [UIColor colorWithWhite: 0 alpha: 1];
                emailTextField.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];;
                emailTextField.keyboardType = UIKeyboardTypeDefault;
                emailTextField.returnKeyType = UIReturnKeyDone;
                emailTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
                emailTextField.tag = 6;
                
                emailTextField.backgroundColor = [UIColor clearColor];
                
                [cell.contentView addSubview:emailTextField];
                
            }
        }
        
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"";
            break;
        case 1:
            return NSLocalizedString(@"", nil);
            break;
        case 2:
            return @"";
            break;
        case 3:
            return NSLocalizedString(@"Private information, only you see this", nil);
            break;
        default:
            return @"";
    }
}
-(void)getCountryListData
{
    NSLocale *locale = [NSLocale currentLocale];
    NSArray *countryArray = [NSLocale ISOCountryCodes];
    
    for (NSString *countryCode in countryArray) {
        
        NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        [self.arrCountryList addObject:displayNameString];
        
    }
    
    [self.arrCountryList sortUsingSelector:@selector(localizedCompare:)];
    
    NSLog(@"%@",self.arrCountryList);
}
#pragma mark - UITableViewDelegate methods

// Called after the user changes the selection.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    return ;
    if (indexPath.section == 0) {
        if (indexPath.row == 0){
            changeHeader = YES;
            [self changeProfilePicture];
        }
        else if (indexPath.row == 1){
            changeHeader = NO;
            [self changeProfilePicture];
        }
        /*else if (indexPath.row == 2){
            changeHeader = NO;
            [self changeProfileColor];
        }*/
        
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
        }
        else if (indexPath.row == 1) {
        }
        else {
            
        }
        
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0) {
        }
        else if (indexPath.row == 1) {
        }
        else if (indexPath.row == 2) {
        }
    }
    
    else if (indexPath.section == 3)
    {
        
        
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        
        if (buttonIndex == 0) {
            [self shouldStartCameraController];
        } else if (buttonIndex == 1) {
            [self shouldStartPhotoLibraryPickerController];
        }
        
    }
}
#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99) {
        if (buttonIndex == 0) {
            PFUser *user= [PFUser currentUser];
            [user setObject:@"Yes" forKey:@"acceptedTerms"];
            [user saveInBackground];
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
        else {
            ESPrivacyPolicyViewController * vc = [[ESPrivacyPolicyViewController alloc]init];
            vc.showDoneButton = YES;
            AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.navController presentViewController:vc animated:NO completion: nil];

        }
    }
    
}
- (void)alertViewCancel:(UIAlertView *)alertView {
    return;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if ([textField isEqual:birthdayTextField]) {
        pickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        [pickerView setDatePickerMode:UIDatePickerModeDate];
        if (![birthdayTextField.text isEqualToString:@""]) {
            NSDate *date = [self dateFromLocaleDateString:birthdayTextField.text];
            [pickerView setDate:date];
        }
        textField.inputView = pickerView;
        UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:
                                CGRectMake(0,0, 320, 44)]; //should code with variables to support view resizing

        UIBarButtonItem *doneButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self action:@selector(birthdayInputDidFinish)];
        UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self action:@selector(TextInputCancel)];
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        [myToolbar setItems:[NSArray arrayWithObjects:cancelButton,flexibleItem,doneButton,nil] animated:NO];
        textField.inputAccessoryView = myToolbar;
        
    }
    else if ([textField isEqual:genderTextField]) {
        genderPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        genderPicker.delegate = self;
        genderPicker.dataSource = self;
        textField.inputView = genderPicker;
        UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:
                                CGRectMake(0,0, 320, 44)]; //should code with variables to support view resizing
        UIBarButtonItem *doneButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self action:@selector(genderInputDidFinish)];
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self action:@selector(TextInputCancel)];
        [myToolbar setItems:[NSArray arrayWithObjects:cancelButton,flexibleItem,doneButton,nil] animated:NO];        textField.inputAccessoryView = myToolbar;
        
    }
    else if ([textField isEqual:countryTextField]) {
        countryPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        countryPicker.delegate = self;
        countryPicker.dataSource = self;
        textField.inputView = countryPicker;
        UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:
                                CGRectMake(0,0, 320, 44)]; //should code with variables to support view resizing
        UIBarButtonItem *doneButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self action:@selector(countryInputDidFinish)];
        UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self action:@selector(TextInputCancel)];
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        [myToolbar setItems:[NSArray arrayWithObjects:cancelButton,flexibleItem,doneButton,nil] animated:NO];
        textField.inputAccessoryView = myToolbar;
        
    }
    else
    {
        UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:
                                CGRectMake(0,0, 320, 44)]; //should code with variables to support view resizing
        UIBarButtonItem *doneButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self action:@selector(TextInputDidFinish)];
        UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self action:@selector(TextInputCancel)];
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        [myToolbar setItems:[NSArray arrayWithObjects:cancelButton,flexibleItem,doneButton,nil] animated:NO];
        textField.inputAccessoryView = myToolbar;
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    else {
       // saveInfoBtn.enabled = YES;
        //saveInfoBtn.tintColor = [UIColor whiteColor];
    }
    
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= MAX_LENGTH)
    {
        return YES;
    } else {
        NSUInteger emptySpace = MAX_LENGTH - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textField {
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =(MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:
                            CGRectMake(0,0, 320, 44)]; //should code with variables to support view resizing
    UIBarButtonItem *doneButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(TextInputDidFinish)];
    UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self action:@selector(TextInputCancel)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [myToolbar setItems:[NSArray arrayWithObjects:cancelButton,flexibleItem,doneButton,nil] animated:NO];

    textField.inputAccessoryView = myToolbar;
    
    [UIView commitAnimations];
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =(MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}
- (void)textViewDidEndEditing:(UITextView *)textField {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //saveInfoBtn.enabled = YES;
    //saveInfoBtn.tintColor = [UIColor whiteColor];
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= MAXLENGTH || returnKey;
}

#pragma mark - PhotoLibraryPickerController

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
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    cameraUI.modalPresentationStyle = UIModalPresentationFullScreen;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:cameraUI animated:YES completion:nil];
    });
    
    return YES;
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
        cameraUI.allowsEditing = false;

        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:cameraUI animated:YES completion:nil];
    });
    
    return YES;
}
- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *_image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.imageUser = _image;
    
    [self shouldUploadImage:self.imageUser];
    
}

#pragma mark - ()

-(void) birthdayInputDidFinish
{
    [birthdayTextField resignFirstResponder];
    birthdayTextField.text = [self localeDateFormatStringFromDate:pickerView.date];
    //saveInfoBtn.enabled = YES;
    //saveInfoBtn.tintColor = [UIColor whiteColor];
}
-(void) genderInputDidFinish
{
    [genderTextField resignFirstResponder];

    //saveInfoBtn.enabled = YES;
    //saveInfoBtn.tintColor = [UIColor whiteColor];
}
-(void)countryInputDidFinish
{
    [countryTextField resignFirstResponder];
    self.countryTextField.text = [NSString stringWithFormat:@"%@",[self.arrCountryList objectAtIndex:[self.countryPicker selectedRowInComponent:0]]];

    //saveInfoBtn.enabled = YES;
    //saveInfoBtn.tintColor = [UIColor whiteColor];
}
-(void)TextInputDidFinish
{
    [self.nameTextField resignFirstResponder];
    [self.mentionTextField resignFirstResponder];
    [self.cityTextField resignFirstResponder];
    [self.websiteTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.countryTextField resignFirstResponder];
    [self.educationTextField resignFirstResponder];
    [self.jobTextField resignFirstResponder];
    [self.bioTextview resignFirstResponder];

}
-(void)TextInputCancel
{
    [self.nameTextField resignFirstResponder];
    [self.mentionTextField resignFirstResponder];
    [self.cityTextField resignFirstResponder];
    [self.websiteTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.countryTextField resignFirstResponder];
    [self.educationTextField resignFirstResponder];
    [self.jobTextField resignFirstResponder];
    [self.bioTextview resignFirstResponder];
    [self.genderTextField resignFirstResponder];
    [self.birthdayTextField resignFirstResponder];
}
-(void) changeProfilePicture {
    
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        if (changeHeader) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Change header picture", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take Photo", nil), NSLocalizedString(@"Choose Photo", nil), nil];
            //actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            actionSheet.tag = 1;
            [actionSheet showInView:self.view];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Change profile picture", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take Photo", nil), NSLocalizedString(@"Choose Photo", nil), nil];
            //actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            actionSheet.tag = 1;
            [actionSheet showInView:self.view];
        }
        
    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
    
}
- (BOOL)shouldUploadImage:(UIImage *)anImage {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(640.0f, 640.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // Do something...
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        if (succeeded) {
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSData *imageData = UIImageJPEGRepresentation(self.imageUser, 0.7);
                if (changeHeader) {
                    [ESUtility processHeaderPhotoWithData:imageData];
                    self.imageView1.image = self.imageUser;
                }
                else {
                    [ESUtility processProfilePictureData:imageData];
                    self.imageView2.image = self.imageUser;
                    self.imageView2.layer.cornerRadius = 40;
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
- (void) presaveInformation {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:6 inSection:0];
    [self._tableView scrollToRowAtIndexPath:indexPath
                           atScrollPosition:UITableViewScrollPositionTop
                                   animated:YES];
    [self performSelector:@selector(saveInformation) withObject:nil afterDelay:0.5];
}
- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
- (void)saveInformation {
    NSString *string = [nameTextField text];
    [nameTextField resignFirstResponder];
    [mentionTextField resignFirstResponder];
    [bioTextview resignFirstResponder];
    [cityTextField resignFirstResponder];
    [websiteTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [genderTextField resignFirstResponder];
    [birthdayTextField resignFirstResponder];
    
    if ([string isEqualToString:@""] || [string rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound || [[string substringToIndex:1]isEqualToString:@" "] || [string rangeOfString:@"  "].location != NSNotFound) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [ProgressHUD showError:NSLocalizedString(@"Name is invalid", nil)];
        return;
    }
    if (emailTextField.text == (id)[NSNull null] || emailTextField.text.length == 0 ) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [ProgressHUD showError:NSLocalizedString(@"Incorrect email", nil)];
        
        return;
    }
    if (![self NSStringIsValidEmail:emailTextField.text] && !([emailTextField text].length != 0)) {
        [ProgressHUD showError:NSLocalizedString(@"Incorrect email", nil)];
        
        return;
    }
    if ([self validateEmailWithString:self.emailTextField.text] == FALSE) {
        
        [ProgressHUD showError:NSLocalizedString(@"Email is invalid", nil)];
        
        return;
    }
    //NSString *mentionString = [[mentionTextField text] stringByReplacingOccurrencesOfString:@"@" withString:@""];
   /* if ([mentionString isEqualToString:@""]  || [[mentionString substringToIndex:1]isEqualToString:@" "] || [mentionString rangeOfString:@" "].location != NSNotFound) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [ProgressHUD showError:@"Invalid mention name"];
        
        return;
    }*/
    
    if (genderTextField.text == (id)[NSNull null] || genderTextField.text == (NSString*)[NSNull null]) {
        
        genderTextField.text = @"";
    }

    if ([genderTextField text]) {
        [sensitiveData setObject:[genderTextField text] forKey:@"Gender"];
        
    }
    if (![[[PFUser currentUser]objectForKey:kESUserEmailKey] isEqualToString:emailTextField.text]) {
        
        [sensitiveData setObject:[emailTextField text] forKey:@"email"];

    }
    if ([genderTextField text]) [sensitiveData setObject:[self fromLocaleDateString:birthdayTextField.text] forKey:@"Birthday"];
    [sensitiveData saveInBackground];

    [[PFUser currentUser] setObject:[nameTextField text] forKey:kESUserDisplayNameKey];
    [[PFUser currentUser] setObject:[string lowercaseString] forKey:kESUserDisplayNameLowerKey];
    [[PFUser currentUser] setObject:[bioTextview text] forKey:@"UserInfo"];
    [[PFUser currentUser] setObject:[cityTextField text] forKey:@"Location"];
    [[PFUser currentUser] setObject:[websiteTextField text] forKey:@"Website"];
    if (![[[PFUser currentUser]objectForKey:kESUserEmailKey] isEqualToString:emailTextField.text]) {

    [[PFUser currentUser] setObject:[emailTextField text] forKey:@"email"];
        
    }
    [[PFUser currentUser] setObject:[mentionTextField text] forKey:@"phone"];
    [[PFUser currentUser] setObject:[countryTextField text] forKey:@"country"];
    [[PFUser currentUser] setObject:[educationTextField text] forKey:@"education"];
    [[PFUser currentUser] setObject:[jobTextField text] forKey:@"job"];
    [[PFUser currentUser] setObject:[self fromLocaleDateString:birthdayTextField.text] forKey:@"Birthday"];
    [[PFUser currentUser] setObject:[genderTextField text] forKey:@"Gender"];

    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [ProgressHUD showSuccess:NSLocalizedString(@"Success", nil)];
            
           // saveInfoBtn.enabled = NO;
           // saveInfoBtn.tintColor = [UIColor lightGrayColor];
            
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SecondViewControllerDismissed" object:nil userInfo:nil];
            
            if (tutorial == YES) {
                //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
                PFUser *user = [PFUser currentUser];
                [user setObject:@"Yes" forKey:@"firstLaunch"];
                [user saveInBackground];
                [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"firstLaunch"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
               


            }
        }
        else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [ProgressHUD showError:@"Operation failed"];
        }
    }];
}

#pragma mark - UIPickerView data source
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if (pickerView == self.genderPicker) {

    return 3;
        
    }
    else
    {
        return [self.arrCountryList count];
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    if (pickerView == self.genderPicker) {

    switch (row) {
        case 0:
            return NSLocalizedString(@"male", nil);
            break;
        case 1:
            return NSLocalizedString(@"female", nil);
            break;
        case 2:
            return NSLocalizedString(@"other", nil);
            break;
        default:
            return 0;
    };
    }
    else
    {
        return [NSString stringWithFormat:@"%@",[self.arrCountryList objectAtIndex:row]];
    }
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    if (pickerView == self.genderPicker) {
        
    switch(row)
    {
        case 0:
            genderTextField.text = NSLocalizedString(@"male", nil);
            break;
        case 1:
            genderTextField.text = NSLocalizedString(@"female", nil);
            break;
        case 2:
            genderTextField.text = NSLocalizedString(@"other", nil);
            break;
            
    }
    }
    else
    {
        self.countryTextField.text = [NSString stringWithFormat:@"%@",[self.arrCountryList objectAtIndex:row]];

    }
}
// Formats the date chosen with the date picker.
- (NSString *)localeDateFormatStringFromDate:(NSDate *)date
{
    NSString *dateFormatString = SERVER_DATE_FORMAT_STRING;
    NSString *languageCode = [self languageCode];
    if ([languageCode isEqualToString:@"ja"]) {
        dateFormatString = JAPANESE_DATE_FORMAT_STRING;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:dateFormatString];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return formattedDate;
}

- (NSDate *)dateFromLocaleDateString:(NSString *)localeDateString {
    NSString *dateFormatString = SERVER_DATE_FORMAT_STRING;
    NSString *languageCode = [self languageCode];
    if ([languageCode isEqualToString:@"ja"]) {
        dateFormatString = JAPANESE_DATE_FORMAT_STRING;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:dateFormatString];
    return [dateFormatter dateFromString:localeDateString];
}

- (NSString *)languageCode {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];
    return [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
}

- (NSString *)fromServerDateString:(NSString *)serverDateString {
    if (serverDateString == nil || serverDateString.length == 0) {
        return @"";
    }
    
    NSString *languageCode = [self languageCode];
    if (![languageCode isEqualToString:@"ja"]) {
        return serverDateString;
    }
    
    // convert to japanese format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:SERVER_DATE_FORMAT_STRING];
    NSDate *date = [dateFormatter dateFromString:serverDateString];
    
    [dateFormatter setDateFormat:JAPANESE_DATE_FORMAT_STRING];
    return [dateFormatter stringFromDate:date];
}

- (NSString *)fromLocaleDateString:(NSString *)localeDateString {
    if (localeDateString == nil || localeDateString.length == 0) {
        return @"";
    }
    
    NSString *languageCode = [self languageCode];
    if (![languageCode isEqualToString:@"ja"]) {
        return localeDateString;
    }
    
    // convert to japanese format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:JAPANESE_DATE_FORMAT_STRING];
    NSDate *date = [dateFormatter dateFromString:localeDateString];
    
    [dateFormatter setDateFormat:SERVER_DATE_FORMAT_STRING];
    return [dateFormatter stringFromDate:date];
}

- (void) changeProfileColor {
    ColorPickerViewController *colorpickercontroller = [[ColorPickerViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:colorpickercontroller];
    [self presentViewController:navController animated:YES completion:nil];
}

@end

