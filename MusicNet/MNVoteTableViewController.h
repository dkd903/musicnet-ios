//
//  MNVoteTableViewController.h
//  MusicNet
//
//  Created by Debjit Saha on 4/1/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNVoteTableViewController : UITableViewController

@property (weak, nonatomic) NSString *mntoken;
@property int musiciansCount;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *voteIndicator;
@property (weak, nonatomic) IBOutlet UILabel *voteLabel;


@end
