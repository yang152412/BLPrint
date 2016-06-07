//
//  SDKModel.h
//  partner
//
//  Created by YJ on 16/6/6.
//  Copyright © 2016年 YJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrinterScanProtocol.h"
//#import "CBController.h"

@interface BLGPrinterSDKModel : NSObject <PrinterScanProtocol,CBPeripheralDelegate,CBCentralManagerDelegate>


@property (nonatomic, weak) id<PrinterScanDelegate> delegate;

@end
