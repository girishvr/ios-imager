# Static library - GRImageUploader.

Here, the objective is to upload images either on Amazon (secure/non secure way) and other services like DropBox, Google Drive and Apple's very own iCloud and make available the links of the uploaded images for further usage.

Apparently its not safe using the Secret key in the client code according to AWS (https://forums.aws.amazon.com/thread.jspa?threadID=63089).
Therefore, it an alternative is suggested to gain access to your account atleast for the mobile applications (http://aws.amazon.com/articles/Mobile/4611615499399490).

For s3 add the following framework to the file - 
1)AWSS3.framework
2)AWSRuntime.framework
 

 
