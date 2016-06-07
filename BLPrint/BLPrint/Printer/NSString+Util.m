//
//  NSString+Util.m
//  BLPrint
//
//  Created by 杨世昌 on 16/6/7.
//  Copyright © 2016年 YJ. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)

+ (BOOL)isEmptyString:(NSString *)string
{
    if (!string) {
        return YES;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    return string.length == 0;
}

@end
