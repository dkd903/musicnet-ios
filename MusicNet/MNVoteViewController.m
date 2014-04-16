//
//  MNVoteViewController.m
//  MusicNet
//
//  Created by Debjit Saha on 4/14/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import "MNVoteViewController.h"
#import "MNLoginViewController.h"
#import "AFNetworking.h"

@interface MNVoteViewController ()

@end

@implementation MNVoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *checkedImage = [UIImage imageNamed:@"nonCheckedImage.png"];
    UIImage *nonCheckedImage = [UIImage imageNamed:@"checkedImage.png"];
    [_voteBtn1 setImage:checkedImage forState:UIControlStateSelected];
    [_voteBtn1 setImage:nonCheckedImage forState:UIControlStateNormal];
    [_voteBtn2 setImage:checkedImage forState:UIControlStateSelected];
    [_voteBtn2 setImage:nonCheckedImage forState:UIControlStateNormal];
    [_voteBtn3 setImage:checkedImage forState:UIControlStateSelected];
    [_voteBtn3 setImage:nonCheckedImage forState:UIControlStateNormal];
    [_voteBtn4 setImage:checkedImage forState:UIControlStateSelected];
    [_voteBtn4 setImage:nonCheckedImage forState:UIControlStateNormal];
    [_voteBtn5 setImage:checkedImage forState:UIControlStateSelected];
    [_voteBtn5 setImage:nonCheckedImage forState:UIControlStateNormal];
    [_voteBtn6 setImage:checkedImage forState:UIControlStateSelected];
    [_voteBtn6 setImage:nonCheckedImage forState:UIControlStateNormal];
    [self setColorMusicNet];
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


- (IBAction)voteBtnClicked1:(id)sender {
    _voteBtn1.selected = !_voteBtn1.selected;
    [self sendVotes];
}

- (IBAction)voteBtnClicked2:(id)sender {
    _voteBtn2.selected = !_voteBtn2.selected;
    [self sendVotes];
}

- (IBAction)voteBtnClicked3:(id)sender {
    _voteBtn3.selected = !_voteBtn3.selected;
    [self sendVotes];
}

- (IBAction)voteBtnClicked4:(id)sender {
    _voteBtn4.selected = !_voteBtn4.selected;
    [self sendVotes];
}

- (IBAction)voteBtnClicked5:(id)sender {
    _voteBtn5.selected = !_voteBtn5.selected;
    [self sendVotes];
}

- (IBAction)voteBtnClicked6:(id)sender {
    _voteBtn6.selected = !_voteBtn6.selected;
    [self sendVotes];
}

- (void)sendVotes {
    
    [_voteIndicator startAnimating];
    NSInteger uid = [_mntoken integerValue];
    NSMutableString *stringVotes = [[NSMutableString alloc] init];
    if(_voteBtn1.selected) { [stringVotes appendString:@"1"]; } else { [stringVotes appendString:@"0"]; }
    if(_voteBtn2.selected) { [stringVotes appendString:@"1"]; } else { [stringVotes appendString:@"0"]; }
    if(_voteBtn3.selected) { [stringVotes appendString:@"1"]; } else { [stringVotes appendString:@"0"]; }
    if(_voteBtn4.selected) { [stringVotes appendString:@"1"]; } else { [stringVotes appendString:@"0"]; }
    if(_voteBtn5.selected) { [stringVotes appendString:@"1"]; } else { [stringVotes appendString:@"0"]; }
    if(_voteBtn6.selected) { [stringVotes appendString:@"1"]; } else { [stringVotes appendString:@"0"]; }
    NSLog(@"%@", stringVotes);
    
    //send the votes
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kMNapiUrl]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"token": [NSNumber numberWithInteger:uid], @"votes": stringVotes};
    AFHTTPRequestOperation *op = [manager POST:@"sendVotes" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response" message:operation.responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        
        [_voteIndicator stopAnimating];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        UIAlertView *alertViewE = [[UIAlertView alloc] initWithTitle:@"Response" message:operation.responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertViewE show];
        
        
        [_voteIndicator stopAnimating];
        
        
    }];
    
    [op start];
}

- (void)setColorMusicNet {
    NSString *stringColor = _color;
    NSUInteger red, green, blue;
    sscanf([stringColor UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    
    UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    self.view.backgroundColor = color;
}

@end
