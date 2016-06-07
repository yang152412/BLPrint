//
//  PrinterFormatText.m
//  BLPrint
//
//  Created by YJ on 16/6/7.
//  Copyright © 2016年 YJ. All rights reserved.
//

#import "PrinterFormatText.h"

@implementation PrinterFormatText

// 58mm 打印机 最多一行 32个星号
#pragma mark - 排版

/**
 *  科普一下：Pt(磅值)是物理长度单位，指的是72分之一英寸,1英寸=25.4mm 。所以 22磅字体大小为  22 * (1/72) * 25.4 = 7.76mm
 *  GPrint 58-MB III 打印机，纸宽 58mm
 */

/*
 纸宽 58mm，左右边距，各给5mm。商品 一行，名称占 28mm，数量和小计 各占 10mm
 
 简单计算，一行打 30个英文字符。 1个汉字 占2个字符。间距各2个空格。数量和小计 各占 6个，右对齐；商品名称 占 14个，左对齐。
 商品名称打7个汉字。数量3个汉字
 
 */

#define kLeftMaxLength 14
#define kMiddleMaxLength 6
#define kRightMaxLength 6
//判断中英混合的的字符串长度

+ (NSStringEncoding)getTextEncoding
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return enc;
}

+ (NSData *)getDataWithString:(NSString *)strtemp
{
    NSStringEncoding enc = [self getTextEncoding];
    NSData *data = [strtemp dataUsingEncoding:enc];
    return data;
}

+ (NSUInteger)getStringLength:(NSString*)strtemp
{
    NSData *data = [self getDataWithString:strtemp];
    return data.length;
}

+ (int)getLinesWithText:(NSString *)text maxLineLength:(int)maxLineLength
{
    NSUInteger length = [self getStringLength:text];
    NSUInteger lines = length/maxLineLength + (length%maxLineLength == 0 ? 0 : 1);
    return (int)lines;
}

+ (NSString *)getSpaceString:(int)count
{
    NSMutableString *spaceString = [[NSMutableString alloc] init];
    for (int i = 0; i < count; i++) {
        [spaceString appendString:@" "];
    }
    return spaceString;
}

+ (NSString *)appendSpaceString:(NSString *)string spaceCount:(int)needSpaceCount aligment:(NSTextAlignment)aligment
{
    NSMutableString *spaceString = [[NSMutableString alloc] initWithString:string];
    if (aligment == NSTextAlignmentLeft) {
        // 右边拼空格
        [spaceString appendString:[self getSpaceString:needSpaceCount]];
    } else if (aligment == NSTextAlignmentRight) {
        // 最后一行左边拼空格
        [spaceString insertString:[self getSpaceString:needSpaceCount] atIndex:0];
    } else {
        // 两边拼空格
        for (int i = 0; i < needSpaceCount; i++) {
            if (i < needSpaceCount/2) {
                [spaceString insertString:@" " atIndex:0];
            } else {
                [spaceString appendString:@" "];
            }
        }
    }
    return spaceString;
}

+ (NSArray *)getMultiLineString:(NSString *)string maxLength:(int)maxLineLength aligment:(NSTextAlignment)aligment
{
    NSUInteger length = [self getStringLength:string];
    if (length < maxLineLength) {
        int needSpaceCount = maxLineLength - (int)length;
        if (needSpaceCount > 0) {
            NSString *appendSpaceString = [self appendSpaceString:string spaceCount:needSpaceCount aligment:aligment];
            return @[appendSpaceString];
        }
        return @[string];
    } else {
        NSMutableArray *mut = [[NSMutableArray alloc] init];
        NSMutableString *lineString = [[NSMutableString alloc] initWithCapacity:0];
        NSData *data = [self getDataWithString:string];
        
        int lastRow = 0;
        for (int i = 0; i < length; i++) {
            
            BOOL isNextLine = NO;
            
            NSData *subData = [data subdataWithRange:NSMakeRange(i, 1)];
            NSString *text = [[NSString alloc] initWithData:subData encoding:[self getTextEncoding]];
            
            int oneWordLength = 1;
            while (text==nil) {
                oneWordLength += 1;
                subData = [data subdataWithRange:NSMakeRange(i, oneWordLength)];
                text = [[NSString alloc] initWithData:subData encoding:[self getTextEncoding]];
            }
            i += (oneWordLength - 1); // i 会自动加一，所以这里少加一个
            
            int rowTemp = i/maxLineLength; // 判断
            if (rowTemp > lastRow) {
                // 到下一行了
                isNextLine = YES;
            }
            
            if (isNextLine) {
                
                [mut addObject:[lineString copy]];
                [lineString setString:@""];
                [lineString appendString:text];
                
            } else {
                [lineString appendString:text];
            }
            lastRow = rowTemp;
        }
        // 加最后一行
        [mut addObject:[lineString copy]];
        [lineString setString:@""];
        
        int needSpaceCount = length%maxLineLength;
        if (needSpaceCount > 0) {
            NSString *lastLineStr = mut.lastObject;
            lastLineStr = [self appendSpaceString:lastLineStr spaceCount:needSpaceCount aligment:aligment];
            [mut replaceObjectAtIndex:mut.count-1 withObject:lastLineStr];
        }
        
        return mut;
    }
}

int max3(int a,int b, int c)
{
    int m = a > b ? a : b;
    int n= m > c ? m : c;
    return n;
}

+ (NSArray *)getTextsWithLeft:(NSString *)left middle:(NSString *)middle right:(NSString *)right
{
    // 1.left
    
    //    int leftLines = [self getLinesWithText:left maxLineLength:kLeftMaxLength];
    NSArray *leftStringArr = [self getMultiLineString:left maxLength:kLeftMaxLength aligment:NSTextAlignmentLeft];
    
    
    //    int middleLines = [self getLinesWithText:middle maxLineLength:kMiddleMaxLength];
    NSArray *middleStringArr = [self getMultiLineString:middle maxLength:kMiddleMaxLength aligment:NSTextAlignmentRight];
    
    //    int rightLines = [self getLinesWithText:right maxLineLength:kRightMaxLength];
    NSArray *rightStringArr = [self getMultiLineString:right maxLength:kRightMaxLength aligment:NSTextAlignmentRight];
    
    int maxLines = max3((int)leftStringArr.count, (int)middleStringArr.count, (int)rightStringArr.count);
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i = 0; i<maxLines; i++) {
        
        NSMutableString *lineString = [[NSMutableString alloc] init];
        
        NSString *leftString = nil;
        if (i < leftStringArr.count) {
            leftString = leftStringArr[i];
        }
        if (leftString) {
            [lineString appendString:leftString];
        } else {
            [lineString appendString:[self getSpaceString:kLeftMaxLength]];
        }
        
        [lineString appendString:kPaddingPlaceholder]; // 2个空格
        NSString *middleString = nil;
        if (i < middleStringArr.count) {
            middleString = middleStringArr[i];
        }
        if (middleString) {
            [lineString appendString:middleString];
        } else {
            [lineString appendString:[self getSpaceString:kMiddleMaxLength]];
        }
        
        [lineString appendString:kPaddingPlaceholder]; // 2个空格
        NSString *rightString = nil;
        if (i < rightStringArr.count) {
            rightString = rightStringArr[i];
        }
        if (rightString) {
            [lineString appendString:rightString];
        } else {
            [lineString appendString:[self getSpaceString:kRightMaxLength]];
        }
        
        [result addObject:lineString];
    }
    
    NSLog(@" \n拼接字符串结果:\n%@\n",result);
    return result;
}

@end
