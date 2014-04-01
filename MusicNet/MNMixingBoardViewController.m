//
//  MNMixingBoardViewController.m
//  MusicNet
//
//  Created by Debjit Saha on 3/29/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import "MNMixingBoardViewController.h"
#import "MNLoginViewController.h"
#import "AFNetworking.h"

@interface MNMixingBoardViewController ()

@end

@implementation MNMixingBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //NSLog([segue identifier]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        NSLog(@"%@", _mntoken);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendMixingBoard:(id)sender {
    
    [_mixingBoardIndicator startAnimating];
    
    //API Calls
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kMNapiUrl]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *parameters = @{@"fn": @"sendVolume", @"token": _mntoken, @"volume": [[NSString alloc] initWithFormat:@"%f", [_mixingBoardSliderValue value]]};
    AFHTTPRequestOperation *op = [manager POST:@"index.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        [_mixingBoardIndicator stopAnimating];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [_mixingBoardIndicator stopAnimating];
        
    }];

    [op start];
    
    
}

- (IBAction)mixingBoardSlider:(id)sender {
    
    int volume = [_mixingBoardSliderValue value];
    NSString *volumeString = [[NSString alloc] initWithFormat:@"%d", volume];
    [_mixingBoardValueLabel setText:[@"Current Value: " stringByAppendingString:volumeString]];
    
}

@end
