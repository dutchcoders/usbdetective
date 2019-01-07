//
//  BBBUSBKitCore.m
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/07.
//
//

#import "BBBUSBKitCore.h"

@implementation NSError (BBBUSBKit_IOReturn)
+ (NSError *)BBBUSBKitErrorWithIOReturnError:(IOReturn)err {
  return [NSError errorWithDomain:kBBBUSBKitIOReturnErrorDomain code:err userInfo:nil];
}
@end
