//
//  MNLoginViewController.m
//  MusicNet
//
//  Created by Debjit Saha on 3/29/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import "MNLoginViewController.h"

@interface MNLoginViewController ()

@end

@implementation MNLoginViewController

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

    //Setup tap on add image view
    UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newTapMethod)];
    [_userImageView setUserInteractionEnabled:YES];
    [_userImageView addGestureRecognizer:newTap];
    
    //check if image has been added
    _imageChanged = 0;
    
    //[[_activityIndicator alloc] init];


}

- (void)viewDidAppear:(BOOL)animated {
    //if user is already logged in then skip to welcome
    //read token from local store
    if (0) {
        [self performSegueWithIdentifier:@"MusicNetWelcomeTo" sender:self];
    }
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

#pragma mark - Continue BUtton Click

- (IBAction)loginClicked:(id)sender {
    
    NSString *userEmail = [_userEmail text];
    NSString *userCity = [_userCity text];
    //_userImage
    //Trim whitespace if any
    [userEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
    [userCity stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
    
    if ([userEmail length] == 0 || [userCity length] == 0 || _imageChanged == 0) {
        UIAlertView *newAlert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Please fill in all the fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [newAlert show];
    } else {
        [_activityIndicator startAnimating];
        //API Calls
        //save token
        //on success move ahead
        [self performSegueWithIdentifier:@"MusicNetWelcomeTo" sender:self];
    }
    
}

-(void)newTapMethod{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    //UIImagePickerControllerSourceTypeCamera
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:NULL];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //UIImageView *newImageView  = [[UIImageView alloc] initWithImage:image];
    //[newImageView setFrame:CGRectMake(arc4random_uniform(240), arc4random_uniform(300), 80, 80)];
    //[[self view] addSubview:newImageView];
    [_userImageView setImage:image];
    _userImage = image;
    [_addImageLabel setText:@"Tap on image to change"];
    _imageChanged = 1;
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Hide Keyboard 
//On touching any space on the screen

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_userEmail isFirstResponder] && [touch view] != _userEmail) {
        [_userEmail resignFirstResponder];
    }
    if ([_userCity isFirstResponder] && [touch view] != _userCity) {
        [_userCity resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - Hide Keyboard With Button

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}


@end
