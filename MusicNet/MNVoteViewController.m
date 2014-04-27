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
    
    NSString *mnvotes = @"000000";
    NSString *homeDirectory = NSHomeDirectory();
    NSString *filePath = [homeDirectory stringByAppendingString:@"/Documents/MNvotes.txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        mnvotes = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSLog(@"%@", mnvotes);
    
    unichar chvote;
    chvote = [mnvotes characterAtIndex:0];
    if ([[NSString stringWithFormat:@"%c",chvote] isEqualToString:@"0"]) {
        [_voteBtn1 setSelected:NO];
        [_voteBtn1 setUserInteractionEnabled:YES];
    } else {
        [_voteBtn1 setSelected:YES];
        [_voteBtn1 setUserInteractionEnabled:NO];
    }
    chvote = [mnvotes characterAtIndex:1];
    if ([[NSString stringWithFormat:@"%c",chvote] isEqualToString:@"0"]) {
        [_voteBtn2 setSelected:NO];
        [_voteBtn2 setUserInteractionEnabled:YES];
    } else {
        [_voteBtn2 setSelected:YES];
        [_voteBtn2 setUserInteractionEnabled:NO];
    }
    chvote = [mnvotes characterAtIndex:2];
    if ([[NSString stringWithFormat:@"%c",chvote] isEqualToString:@"0"]) {
        [_voteBtn3 setSelected:NO];
        [_voteBtn3 setUserInteractionEnabled:YES];
    } else {
        [_voteBtn3 setSelected:YES];
        [_voteBtn3 setUserInteractionEnabled:NO];
    }
    chvote = [mnvotes characterAtIndex:3];
    if ([[NSString stringWithFormat:@"%c",chvote] isEqualToString:@"0"]) {
        [_voteBtn4 setSelected:NO];
        [_voteBtn4 setUserInteractionEnabled:YES];
    } else {
        [_voteBtn4 setSelected:YES];
        [_voteBtn4 setUserInteractionEnabled:NO];
    }
    chvote = [mnvotes characterAtIndex:4];
    if ([[NSString stringWithFormat:@"%c",chvote] isEqualToString:@"0"]) {
        [_voteBtn5 setSelected:NO];
        [_voteBtn5 setUserInteractionEnabled:YES];
    } else {
        [_voteBtn5 setSelected:YES];
        [_voteBtn5 setUserInteractionEnabled:NO];
    }
    chvote = [mnvotes characterAtIndex:5];
    if ([[NSString stringWithFormat:@"%c",chvote] isEqualToString:@"0"]) {
        [_voteBtn6 setSelected:NO];
        [_voteBtn6 setUserInteractionEnabled:YES];
    } else {
        [_voteBtn6 setSelected:YES];
        [_voteBtn6 setUserInteractionEnabled:NO];
    }
    
    [self resetVotes];
  
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    [_voteBtn1 setUserInteractionEnabled:NO];
    [self sendVotes];
}

- (IBAction)voteBtnClicked2:(id)sender {
    _voteBtn2.selected = !_voteBtn2.selected;
    [_voteBtn2 setUserInteractionEnabled:NO];
    [self sendVotes];
}

- (IBAction)voteBtnClicked3:(id)sender {
    _voteBtn3.selected = !_voteBtn3.selected;
    [_voteBtn3 setUserInteractionEnabled:NO];
    [self sendVotes];
}

- (IBAction)voteBtnClicked4:(id)sender {
    _voteBtn4.selected = !_voteBtn4.selected;
    [_voteBtn4 setUserInteractionEnabled:NO];
    [self sendVotes];
}

- (IBAction)voteBtnClicked5:(id)sender {
    _voteBtn5.selected = !_voteBtn5.selected;
    [_voteBtn5 setUserInteractionEnabled:NO];
    [self sendVotes];
}

- (IBAction)voteBtnClicked6:(id)sender {
    _voteBtn6.selected = !_voteBtn6.selected;
    [_voteBtn6 setUserInteractionEnabled:NO];
    [self sendVotes];
}

- (void)sendVotes {
    
    [_voteIndicator startAnimating];
    
    [self resetVotes];
    
    NSInteger uid = [_mntoken integerValue];
    NSMutableString *stringVotes = [[NSMutableString alloc] init];
    if(_voteBtn1.selected) { [stringVotes appendString:@"1"]; } else { [stringVotes appendString:@"0"]; }
    if(_voteBtn2.selected) { [stringVotes appendString:@"1"]; } else { [stringVotes appendString:@"0"]; }
    if(_voteBtn3.selected) { [stringVotes appendString:@"1"]; } else { [stringVotes appendString:@"0"]; }
    if(_voteBtn4.selected) { [stringVotes appendString:@"1"]; } else { [stringVotes appendString:@"0"]; }
    if(_voteBtn5.selected) { [stringVotes appendString:@"1"]; } else { [stringVotes appendString:@"0"]; }
    if(_voteBtn6.selected) { [stringVotes appendString:@"1"]; } else { [stringVotes appendString:@"0"]; }
    
    NSLog(@"%@", stringVotes);
    //Save the votes in a votes plist
    NSError *error;
    NSString *homeDirectory = NSHomeDirectory();
    NSString *filePath = [homeDirectory stringByAppendingString:@"/Documents/MNvotes.txt"];
    [stringVotes writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    //send the votes
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kMNapiUrl]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"token": [NSNumber numberWithInteger:uid], @"votes": stringVotes};
    AFHTTPRequestOperation *op = [manager POST:@"sendVotes" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response" message:operation.responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alertView show];
        
        [_voteIndicator stopAnimating];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        //UIAlertView *alertViewE = [[UIAlertView alloc] initWithTitle:@"Response" message:operation.responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alertViewE show];
        
        [_voteIndicator stopAnimating];
        
        
    }];
    
    [op start];
    
}

- (void)resetVotes {
    //check if it is needed to reset the votes
    AFHTTPRequestOperationManager *managerReset = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kMNapiUrl]];
    managerReset.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    managerReset.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSInteger uid = [_mntoken integerValue];
    NSDictionary *parametersReset = @{@"token": [NSNumber numberWithInteger:uid]};
    AFHTTPRequestOperation *opReset = [managerReset POST:@"resetVotesFlag" parameters:parametersReset success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response" message:operation.responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alertView show];
        
        //[_voteIndicator stopAnimating];
        
        //reset all votes
        if ([responseObject[@"resetFlag"] boolValue]) {
            
            [_voteBtn1 setSelected:NO];
            [_voteBtn2 setSelected:NO];
            [_voteBtn3 setSelected:NO];
            [_voteBtn4 setSelected:NO];
            [_voteBtn5 setSelected:NO];
            [_voteBtn6 setSelected:NO];
            [_voteBtn1 setUserInteractionEnabled:YES];
            [_voteBtn2 setUserInteractionEnabled:YES];
            [_voteBtn3 setUserInteractionEnabled:YES];
            [_voteBtn4 setUserInteractionEnabled:YES];
            [_voteBtn5 setUserInteractionEnabled:YES];
            [_voteBtn6 setUserInteractionEnabled:YES];
            //NSLog(@"Hehe");
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        //UIAlertView *alertViewE = [[UIAlertView alloc] initWithTitle:@"Response" message:operation.responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alertViewE show];
        
        
        //[_voteIndicator stopAnimating];
        
        
    }];
    
    [opReset start];
}

- (IBAction)voteResetTap:(id)sender {
    //This function was created torespond
    //to a tap in the hidden area
    //bottom right
    //Save the votes in a votes plist
    /*NSError *error;
    NSString *homeDirectory = NSHomeDirectory();
    NSString *filePath = [homeDirectory stringByAppendingString:@"/Documents/MNvotes.txt"];
    NSString *stringVotes = @"000000";
    [stringVotes writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [_voteBtn1 setSelected:NO];
    [_voteBtn2 setSelected:NO];
    [_voteBtn3 setSelected:NO];
    [_voteBtn4 setSelected:NO];
    [_voteBtn5 setSelected:NO];
    [_voteBtn6 setSelected:NO];
    [_voteBtn1 setUserInteractionEnabled:YES];
    [_voteBtn2 setUserInteractionEnabled:YES];
    [_voteBtn3 setUserInteractionEnabled:YES];
    [_voteBtn4 setUserInteractionEnabled:YES];
    [_voteBtn5 setUserInteractionEnabled:YES];
    [_voteBtn6 setUserInteractionEnabled:YES];*/
}
@end
