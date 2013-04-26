//
//  GRImageUploader.h
//  GRImageUploader
//
//  Created by Girish Rathod on 26/04/13.
//  Copyright (c) 2013 Girish Rathod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>


@protocol GRImageUploaderDelegate <NSObject>
-(void)uploadedImagePath:(NSURL *)imageUrl;
@end


@interface GRImageUploader : NSObject<AmazonServiceRequestDelegate>{
    AmazonS3Client *s3Client;
    NSData *imageData;
}
@property(nonatomic, assign)id <GRImageUploaderDelegate> delegate;
@property(nonatomic, retain)NSString *accessKeyId;
@property(nonatomic, retain)NSString *secretKey;
@property(nonatomic, retain)NSString *bucketName;
@property(nonatomic, retain)UIImage  *imageActual;
@property(nonatomic, retain)NSString *imageName;
@property(nonatomic, retain)NSString *imagePath;
@property(nonatomic, retain)NSURL    *imageURL;

-(void)upload;

@end
