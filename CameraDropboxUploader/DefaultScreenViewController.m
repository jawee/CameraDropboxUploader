//
//  ViewController.m
//  CameraDropboxUploader
//
//  Created by Andreas Olsson on 5/16/13.
//  Copyright (c) 2013 Andreas Olsson. All rights reserved.
//

#import "DefaultScreenViewController.h"


@interface DefaultScreenViewController ()
@property (nonatomic, strong) NSString *pathToLatestUploadedFile;
@end

@implementation DefaultScreenViewController
@synthesize imageView = _imageView;
@synthesize restClient = _restClient;
@synthesize pathToLatestUploadedFile = _pathToLatestUploadedFile;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}


- (IBAction)takePhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    self.imageView.image = nil;
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
    
}
- (IBAction)selectPhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)uploadPressed:(id)sender {
    if(self.imageView.image) {
        if (![[DBSession sharedSession] isLinked]) {
            [[DBSession sharedSession] linkFromController:self];
        } else {
            NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
            
            NSDate *now = [[NSDate alloc] init];
            NSString *theTime = [timeFormat stringFromDate:now];
            
            NSString *filename = [NSString stringWithFormat:@"%@.png", theTime];
            NSData *data = UIImagePNGRepresentation(self.imageView.image);
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
            [data writeToFile:filePath atomically:YES];
            self.pathToLatestUploadedFile = [NSString stringWithFormat:@"/Public/CameraDropboxUploader/%@", filename];
            [self.restClient uploadFile:filename toPath:@"/Public/CameraDropboxUploader/" withParentRev:nil fromPath:filePath];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.imageView.image = chosenImage;
    
    
    
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    self.pathToLatestUploadedFile = metadata.path;
    [[self restClient] loadSharableLinkForFile:metadata.path];
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"File uploaded, the public link is in your clipboard!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [myAlertView show];
    
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"File wasn't uploaded, please try again!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [myAlertView show];
}

- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link
           forFile:(NSString*)path
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = link;
    NSLog(@"Sharable link %@",link);
}

- (void)restClient:(DBRestClient*)restClient loadSharableLinkFailedWithError:(NSError*)error
{
    NSLog(@"Error %@",error);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
@end
