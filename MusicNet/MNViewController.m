//
//  MNViewController.m
//  MusicNet
//
//  Created by Debjit Saha on 3/29/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import "MNViewController.h"
#import "MNAnswerViewController.h"
#import "MNVoteViewController.h"
#import "MNMixingBoardViewController.h"
#import "MNPulseViewController.h"


@interface MNViewController ()

@end

@implementation MNViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"%@", [segue identifier]);
    
    if ([[segue identifier] isEqualToString:@"MixingBoard"]) {
        
        MNMixingBoardViewController *mixingBoardViewController = [segue destinationViewController];
        mixingBoardViewController.mntoken = _mntoken;
        mixingBoardViewController.color = _color;
        
    } else if ([[segue identifier] isEqualToString:@"VoteMusician"]) {
        
        MNVoteViewController *voteBoardViewController = [segue destinationViewController];
        voteBoardViewController.mntoken = _mntoken;
        voteBoardViewController.color = _color;
        
    } else if ([[segue identifier] isEqualToString:@"AnswerQuestion"]) {
        
        MNAnswerViewController *answerBoardViewController = [segue destinationViewController];
        answerBoardViewController.mntoken = _mntoken;
        answerBoardViewController.color = _color;
        
    } else if ([[segue identifier] isEqualToString:@"RecordPulse"]) {
        
        MNPulseViewController *pulseBoardViewController = [segue destinationViewController];
        pulseBoardViewController.mntoken = _mntoken;
        pulseBoardViewController.color = _color;
        
    }
    
    //MyViewController *controller = (MyViewController *)segue.destinationViewController;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSString *color = @"";
    NSString *chomeDirectory = NSHomeDirectory();
    NSString *cfilePath = [chomeDirectory stringByAppendingString:@"/Documents/MNUserColor.txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cfilePath]) {
        color = [[NSString alloc] initWithContentsOfFile:cfilePath encoding:NSUTF8StringEncoding error:nil];
    }
    
    _color = color;
    NSLog(@"%@", _color);
}

- (void)viewDidAppear:(BOOL)animated {
    //if user is already logged in then skip to welcome
    //read token from local store
    [super viewDidAppear:TRUE];
    NSString *mntoken = @"";
    NSString *homeDirectory = NSHomeDirectory();
    NSString *filePath = [homeDirectory stringByAppendingString:@"/Documents/MNtoken.txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        mntoken = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    }
    
    _mntoken = mntoken;
    [self setColorMusicNet];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutClicked:(id)sender {
    
    NSError *error;
    NSString *homeDirectory = NSHomeDirectory();
    NSString *filePath = [homeDirectory stringByAppendingString:@"/Documents/MNtoken.txt"];
    [@"" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [self performSegueWithIdentifier:@"MusicNetLogin" sender:self];
    
}

- (void)setColorMusicNet {
    NSString *stringColor = _color;
    NSUInteger red, green, blue;
    sscanf([stringColor UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    
    UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    //self.view.backgroundColor = color;
    //self.window.backgroundColor = color;
    //[[self navigationController] navigationBar setTintColor:[UIColor redColor]; //Red as an example.
    //[[[self navigationController] navigationBar] setTintColor:color];
}
@end
