//
//  Order.m
//  BLPrint
//
//  Created by 杨世昌 on 16/6/7.
//  Copyright © 2016年 YJ. All rights reserved.
//

#import "Order.h"

@implementation Product



@end

@implementation Order

+ (Order *)getTestData
{
    Order *order = [[Order alloc] init];
    
    order.merchant_name = @"测试商户";
    order.order_code = @"1234567890";
    order.reserved_time_start = 1441176300;
    order.create_time = 1441177200;
    order.order_note = @"备注 备注 哈哈哈哈哈哈哈哈";
    order.pay_type = 1;
    order.money = @"123.45";
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i =0; i < 4; i++) {
        Product *p = [[Product alloc] init];
        p.name = [NSString stringWithFormat:@"第%d个商品",i];
        p.count = i;
        p.price = i*1.00;
    }
    order.products = array;
    return order;
}

@end
