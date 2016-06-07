//
//  Order.h
//  BLPrint
//
//  Created by 杨世昌 on 16/6/7.
//  Copyright © 2016年 YJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger count;

@property (nonatomic, assign) float price;

@end

@interface Order : NSObject

@property (nonatomic, copy) NSString *merchant_name;

@property (nonatomic, copy) NSString *order_code;
@property (nonatomic, strong) NSArray<Product *> *products;

@property (nonatomic, assign) NSTimeInterval reserved_time_start;
@property (nonatomic, assign) NSTimeInterval create_time;

@property (nonatomic, copy) NSString *order_note;

@property (nonatomic, assign) int pay_type;
@property (nonatomic, copy) NSString *money;

+ (Order *)getTestData;

@end
