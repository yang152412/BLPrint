//
//  SDKModel.h
//  partner
//
//  Created by 杨世昌 on 16/6/6.
//  Copyright © 2016年 杨世昌. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrinterScanProtocol.h"
//#import "CBController.h"

@interface BLGPrinterSDKModel : NSObject <PrinterScanProtocol,CBPeripheralDelegate,CBCentralManagerDelegate>


@property (nonatomic, weak) id<PrinterScanDelegate> delegate;

@end
