//
//  UIImage+Base64.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/2/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "UIImage+Base64.h"
#import "Base64.h"

@implementation UIImage (Base64)

- (NSString *)base64String {
    NSData* data = UIImagePNGRepresentation(self);//UIImageJPEGRepresentation(self, 1.0f);
    NSString *strEncoded = [Base64 encode:data];
    return strEncoded;//[UIImagePNGRepresentation(self) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


@end
