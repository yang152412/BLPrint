//
//  PrinterScanProtocol.h
//  partner
//
//  Created by YJ on 16/6/6.
//  Copyright © 2016年 YJ. All rights reserved.
//

#ifndef PrinterScanProtocol_h
#define PrinterScanProtocol_h
#import <CoreBluetooth/CoreBluetooth.h>

@protocol PrinterScanProtocol <NSObject,CBCentralManagerDelegate,CBPeripheralDelegate>

- (void)startScan;
- (void)stopScan;

// 写 id 是为了 方便 其他 sdk 封装 peripheral 对象，传递参数

//@property (nonatomic, strong) id connectedPeripheral;

- (void)connectPeripheral:(CBPeripheral *)peripheral;
- (void)disconnectPeripheral:(CBPeripheral *)peripheral;

@end


@protocol PrinterScanDelegate <NSObject>

// 更新列表，不需要回调。
//- (void)didUpdatePeripheralList:(NSArray<CBPeripheral *> *)peripherals;

// 下面的方法，就是为了知道 第三方 sdk 也正确执行了 对应方法。
- (void)didConnectPeripheral:(CBPeripheral *)peripheral;
- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral;
- (void)didConnectPeripheral:(CBPeripheral *)peripheral failed:(NSError *)error;
- (void)didPrepareForPrintWithPeripheral:(CBPeripheral *)peripheral;

@end

#endif /* PrinterScanProtocol_h */
