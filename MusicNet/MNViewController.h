//
//  MNViewController.h
//  MusicNet
//
//  Created by Debjit Saha on 3/29/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNViewController : UIViewController
- (IBAction)logoutClicked:(id)sender;
@property (strong, nonatomic) NSString *mntoken;
@property (strong, nonatomic) NSString *color;
@end
