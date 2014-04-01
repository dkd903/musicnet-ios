//
//  MNAnswerViewController.h
//  MusicNet
//
//  Created by Debjit Saha on 4/1/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNAnswerViewController : UIViewController

@property (weak, nonatomic) NSString *mntoken;
@property (weak, nonatomic) IBOutlet UITextView *fieldQuestion;
@property (weak, nonatomic) IBOutlet UITextField *fieldAnswer;
- (IBAction)sendAnswer:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *questionIndicator;

@end
