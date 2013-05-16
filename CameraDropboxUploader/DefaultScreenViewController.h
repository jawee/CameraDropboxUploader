//
//  ViewController.h
//  CameraDropboxUploader
//
//  Created by Andreas Olsson on 5/16/13.
//  Copyright (c) 2013 Andreas Olsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface DefaultScreenViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)takePhoto:(id)sender;
- (IBAction)selectPhoto:(id)sender;
@end

