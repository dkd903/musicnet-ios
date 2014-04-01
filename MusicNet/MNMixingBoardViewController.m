//
//  MNMixingBoardViewController.m
//  MusicNet
//
//  Created by Debjit Saha on 3/29/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import "MNMixingBoardViewController.h"
#import "MNLoginViewController.h"

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
    //save token
    //on success move ahead
    
    NSString *apiUrl = kMNapiUrl;
    NSURL *URL = [NSURL URLWithString:apiUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    NSString *params = [[[@"fn=sendVolume&token=" stringByAppendingString:_mntoken ] stringByAppendingString:@"&volume="] stringByAppendingString:[[NSString alloc] initWithFormat:@"%f", [_mixingBoardSliderValue value]]];
    
    NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

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
    [_mixingBoardIndicator stopAnimating];
    
    //Parse the JSON response
    NSError *error;
    NSDictionary *apiResponse = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:kNilOptions
                                 error:&error];
    
    //NSLog( @"%@", apiResponse );
    
    //check if the response is good to go
    NSString *apiResponseStatus = [apiResponse objectForKey:@"status"];
    
    if ([apiResponseStatus boolValue] == 1) {
        
        [_mixingBoardIndicator stopAnimating];
        
        
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

- (IBAction)mixingBoardSlider:(id)sender {
    
    int volume = [_mixingBoardSliderValue value];
    NSString *volumeString = [[NSString alloc] initWithFormat:@"%d", volume];
    [_mixingBoardValueLabel setText:[@"Current Value: " stringByAppendingString:volumeString]];
    
}

@end
