//
//  GPrinterController.h
//  BLPrint
//
//  Created by YJ on 16/6/7.
//  Copyright © 2016年 YJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBController.h"

@interface GPrinterController : CBController

// add by me
@property (nonatomic, strong) CBCentralManager *centralManager;

@end
