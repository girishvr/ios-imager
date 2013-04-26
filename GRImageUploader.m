//
//  GRImageUploader.m
//  GRImageUploader
//
//  Created by Girish Rathod on 26/04/13.
//  Copyright (c) 2013 Girish Rathod. All rights reserved.
//

#import "GRImageUploader.h"

@implementation GRImageUploader


-(void)setImageActual:(UIImage *)imageActual{
    _imageActual = imageActual;
}

-(void)setImageName:(NSString *)imageName{
    _imageName = imageName;
    _imageActual = [UIImage imageNamed:imageName];
}

-(void)setImagePath:(NSString *)imagePath{
    _imagePath = imagePath;
    _imageActual = [UIImage imageWithContentsOfFile:_imagePath];
}

-(void)setImageURL:(NSURL *)imageURL{
    _imageURL = imageURL;
}

-(void)setAccessKeyId:(NSString *)accessKeyId{
    _accessKeyId = accessKeyId;
}
-(void)setBucketName:(NSString *)bucketName{
    _bucketName = bucketName;
}

#pragma mark - Internal Methods
-(NSString *)getImageName{
    if ([_imageName length]>1) 
        return [_imageName lowercaseString];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy_MM_dd_HH_mm"];
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"image_%@.jpeg",stringFromDate];
}

#pragma mark -
-(void)upload{
    
    s3Client = [[AmazonS3Client alloc] initWithAccessKey:_accessKeyId withSecretKey:_secretKey] ;
    imageData = UIImageJPEGRepresentation(_imageActual, 1.0);

    [self processGrandCentralDispatchUpload];
}

#pragma mark -
- (void)processGrandCentralDispatchUpload
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:[self getImageName] inBucket:_bucketName] ;
        por.contentType = @"image/jpeg";
        por.data        = imageData;
        
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [s3Client putObject:por];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil){
                
                NSLog(@"Error: %@", putObjectResponse.error);
                [self showAlertMessage:[putObjectResponse.error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
            }
            else{
                //The image was successfully uploaded
                [self getImageUrl];
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}


- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark - AWS Delegates

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    [self showAlertMessage:error.description withTitle:@"Upload Error"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -


-(void)getImageUrl{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Set the content type so that the browser will treat the URL as an image.
        S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
        override.contentType = @"image/jpeg";
        
        // Request a pre-signed URL to picture that has been uplaoded.
        S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init] ;
        gpsur.key                     = [self getImageName];
        gpsur.bucket                  = _bucketName;
        gpsur.expires                 = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600]; // Added an hour's worth of seconds to the current time.
        gpsur.responseHeaderOverrides = override;
        
        // Get the URL
        NSError *error;
        NSURL *url = [s3Client getPreSignedURL:gpsur error:&error];
        if(url == nil){
            if(error != nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Error: %@", error);
                    [self showAlertMessage:[error.userInfo objectForKey:@"message"] withTitle:@"Browser Error"];
                });
            }
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(uploadedImagePath:)]) {
                    [_delegate uploadedImagePath:url];
                }
            });
        }
        
    });
}


@end
