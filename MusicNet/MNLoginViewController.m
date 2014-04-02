//
//  MNLoginViewController.m
//  MusicNet
//
//  Created by Debjit Saha on 3/29/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import "MNLoginViewController.h"
#import "AFNetworking.h"

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
    [super viewDidAppear:TRUE];
    NSString *mntoken = @"";
    NSString *homeDirectory = NSHomeDirectory();
    NSString *filePath = [homeDirectory stringByAppendingString:@"/Documents/MNtoken.txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        mntoken = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    }
    
    //skip login screen if token exists
    if ([mntoken length] > 8) {
        NSLog(@"%@", mntoken);
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
    NSData *imageData = UIImageJPEGRepresentation(_userImage, 90);
    
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
        
        /*NSString *apiUrl = kMNapiUrl;
        NSURL *URL = [NSURL URLWithString:apiUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        request.HTTPMethod = @"POST";
        
        NSString *params = [[[[@"fn=register&email=" stringByAppendingString:userEmail ] stringByAppendingString:@"&city="] stringByAppendingString:userCity] stringByAppendingString:@"&image=32.jpg"];
        
        NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
        [request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:data];
        
        // Create url connection and fire request
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];*/
        
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kMNapiUrl]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        NSDictionary *parameters = @{@"fn": @"register", @"email": userEmail, @"city" : userCity};
        AFHTTPRequestOperation *op = [manager POST:@"index.php" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            //do not put image inside parameters dictionary as I did, but append it!
            [formData appendPartWithFileData:imageData name:@"photo" fileName:[userEmail stringByAppendingString:@"photo.jpg"] mimeType:@"image/jpeg"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
            [_activityIndicator stopAnimating];
            
            if ([responseObject[@"status"] isEqualToString:@"1"]) {
                
                [self loginUser:responseObject[@"data"]];
            
            } else {

                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:operation.responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Error: %@ ***** %@", operation.responseString, error);
            [_activityIndicator stopAnimating];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:operation.responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            
        }];
        [_activityIndicator startAnimating];
        [op start];
        
    }
     
    
}

-(void)loginUser:(NSString *)apiResponseData {
    
    //Save the token in a token plist
    NSError *error;
    NSString *homeDirectory = NSHomeDirectory();
    NSString *filePath = [homeDirectory stringByAppendingString:@"/Documents/MNtoken.txt"];
    [apiResponseData writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    //move user to welcome screen
    [self performSegueWithIdentifier:@"MusicNetWelcomeTo" sender:self];
    
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

/*
 
 Without any library file upload
 
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    //_responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [_activityIndicator stopAnimating];
    
    //Parse the JSON response
    NSError *error;
    NSDictionary *apiResponse = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:kNilOptions
                                 error:&error];
    
    //NSLog( @"%@", apiResponse );
    
    //check if the response is good to go
    NSString *apiResponseStatus = [apiResponse objectForKey:@"status"];
    //get the data part of the response
    NSString *apiResponseData = [apiResponse objectForKey:@"data"];
    
    if ([apiResponseStatus boolValue] == 1) {
        
        NSLog(@"%@", apiResponseData);
        
        //Save the token in a token plist
        NSString *homeDirectory = NSHomeDirectory();
        NSString *filePath = [homeDirectory stringByAppendingString:@"/Documents/MNtoken.txt"];
        [apiResponseData writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        //move user to welcome screen
        [self performSegueWithIdentifier:@"MusicNetWelcomeTo" sender:self];
        
        
    } else {
        
        //Show alert that request was not fine
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something Went Wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        
    }
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}
 */

@end
