//
//  MNAnswerViewController.m
//  MusicNet
//
//  Created by Debjit Saha on 4/1/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import "MNAnswerViewController.h"
#import "MNLoginViewController.h"
#import "AFNetworking.h"

@interface MNAnswerViewController ()

@end

@implementation MNAnswerViewController

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
    NSLog(@"%@", _mntoken);
    NSLog(@"%@", _color);
    [_fieldAnswer setHidden:YES];
    //[_sendButton setHidden:YES];
    //_sendButton.width = 0.01;
    [_fieldQuestion setHidden:YES];
    [_greatAnswer setHidden:YES];
    [_questionIndicator startAnimating];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:TRUE];
    [self setColorMusicNet];
    //get the latest question
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kMNapiUrl]];
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSInteger uid = [_mntoken integerValue];
    
    NSDictionary *parameters = @{@"token": [NSNumber numberWithInteger:uid]};
    AFHTTPRequestOperation *op = [manager POST:@"getLatestQuestion" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response" message:operation.responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        
        [_questionIndicator stopAnimating];
        [_fieldQuestion setText:responseObject[@"question"]];
        _questionId = [@"" stringByAppendingString:responseObject[@"questionId"]];
        NSLog(@"%@", _questionId);
        [_fieldAnswer setHidden:NO];
        //[_sendButton setHidden:NO];
        //_sendButton.width = 0;
        [_fieldQuestion setHidden:NO];
        
        //if the question is not new and user has already answered it
        //set the answer field with old answer
        NSString *userAnswer = @"";
        NSString *homeDirectory = NSHomeDirectory();
        NSString *filePath = [homeDirectory stringByAppendingString:@"/Documents/MNUserAnswer.txt"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] && !([responseObject[@"isNew"] boolValue])) {
            userAnswer = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            [_fieldAnswer setText:userAnswer];
        }
        NSLog(@"[][] Answer - %@", userAnswer);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        UIAlertView *alertViewE = [[UIAlertView alloc] initWithTitle:@"Response" message:operation.responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertViewE show];
        
        
        [_questionIndicator stopAnimating];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot Get Question Right Now" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        
        
    }];
    
    [op start];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setColorMusicNet {
    NSString *stringColor = _color;
    NSUInteger red, green, blue;
    sscanf([stringColor UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    
    UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    self.view.backgroundColor = color;
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

- (IBAction)sendAnswer:(id)sender {
    
    //NSString *filePath = @"/Documents/UserAnswer.plist";
    NSInteger uid = [_mntoken integerValue];
    
    if([[_fieldAnswer text] length] == 0) {
        
        UIAlertView *newAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please fill in Answer" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [newAlert show];
        
    } else {
     
        [_questionIndicator startAnimating];
        //dismiss the keypad
        [self.view endEditing:YES];
        
        //store the last entered answer and question id
        NSError *error;
        NSString *homeDirectory = NSHomeDirectory();
        NSString *filePath = [homeDirectory stringByAppendingString:@"/Documents/MNUserAnswer.txt"];
        NSString *answerToSave = [[NSString alloc] initWithFormat:@"%@", [_fieldAnswer text]];
        [answerToSave writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kMNapiUrl]];
        //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        NSDictionary *parameters = @{@"token": [NSNumber numberWithInteger:uid], @"questionId": _questionId, @"answer": [_fieldAnswer text]};
        AFHTTPRequestOperation *op = [manager POST:@"sendAnswer" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
            [_questionIndicator stopAnimating];
            //[self.navigationController popViewControllerAnimated:YES];
            [_greatAnswer setHidden:NO];

            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Error: %@ ***** %@", operation.responseString, error);
            [_questionIndicator stopAnimating];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot Save Answer" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            
        }];
        
        [op start];
        
    }
    
}

#pragma mark - Hide Keyboard
//On touching any space on the screen

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_fieldAnswer isFirstResponder] && [touch view] != _fieldAnswer) {
        [_fieldAnswer resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - Hide Keyboard With Button

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - get file path
- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"/Documents/UserAnswer.plist"];
}

@end
