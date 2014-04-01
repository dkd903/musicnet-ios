//
//  MNMixingBoardViewController.h
//  MusicNet
//
//  Created by Debjit Saha on 3/29/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNMixingBoardViewController : UIViewController

@property (weak, nonatomic) NSString *mntoken;
- (IBAction)sendMixingBoard:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mixingBoardIndicator;
- (IBAction)mixingBoardSlider:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *mixingBoardSliderValue;
@property (weak, nonatomic) IBOutlet UILabel *mixingBoardValueLabel;


@end
