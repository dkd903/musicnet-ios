//
//  MNVoteViewController.h
//  MusicNet
//
//  Created by Debjit Saha on 4/14/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNVoteViewController : UIViewController
- (IBAction)voteBtnClicked1:(id)sender;
- (IBAction)voteBtnClicked2:(id)sender;
- (IBAction)voteBtnClicked3:(id)sender;
- (IBAction)voteBtnClicked4:(id)sender;
- (IBAction)voteBtnClicked5:(id)sender;
- (IBAction)voteBtnClicked6:(id)sender;
@property (weak, nonatomic) NSString *mntoken;
@property (weak, nonatomic) NSString *color;
@property (weak, nonatomic) IBOutlet UIButton *voteBtn2;
@property (weak, nonatomic) IBOutlet UIButton *voteBtn4;
@property (weak, nonatomic) IBOutlet UIButton *voteBtn1;
@property (weak, nonatomic) IBOutlet UIButton *voteBtn3;
@property (weak, nonatomic) IBOutlet UIButton *voteBtn5;
@property (weak, nonatomic) IBOutlet UIButton *voteBtn6;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *voteIndicator;

@end
