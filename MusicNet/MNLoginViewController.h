//
//  MNLoginViewController.h
//  MusicNet
//
//  Created by Debjit Saha on 3/29/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMNapiUrl @"http://digitizormedia.com/dev/mn/index.php"

@interface MNLoginViewController : UIViewController
- (IBAction)loginClicked:(id)sender;
- (IBAction)textFieldReturn:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userCity;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *addImageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) UIImage *userImage;
@property int imageChanged;

@end
