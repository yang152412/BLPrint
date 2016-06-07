//
//  PrinterUtil.h
//  partner
//
//  Created by 杨世昌 on 16/5/26.
//  Copyright © 2016年 杨世昌. All rights reserved.
//

/*
 用普通方法，扫描打印机，链接上之后，读取打印机 model，判断是否是 佳博，如果是，则用
 1、
 根据 Services uuid E7810A71-73AE-499D-8C15-FAA9AEF0C3F2 下面的bef8d6c9- 判断是否是佳博打印机。
 写用bef8d6c9-这个characteristic写
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class ConnectViewController;
@class MyPeripheral;

static NSString *kBluetoothManagerNotificationCentralManagerDidUpdateState = @"kBluetoothManagerNotificationCentralManagerDidUpdateState";
static NSString *kBluetoothManagerNotificationUserInfoCentralKey = @"kBluetoothManagerNotificationUserInfoCentralKey";

static NSString *kBluetoothManagerNotificationDidUpdatePeripheralList = @"kBluetoothManagerNotificationDidUpdatePeripheralList";

static NSString *kBluetoothManagerNotificationDidBeginScan = @"kBluetoothManagerNotificationDidBeginScan";
static NSString *kBluetoothManagerNotificationDidEndScan = @"kBluetoothManagerNotificationDidEndScan";
static NSString *kBluetoothManagerNotificationAutoConnectPeripheralTimeout = @"kBluetoothManagerNotificationAutoConnectPeripheralTimeout";


static NSString *kPrinterManagerUserInfoConnectedPerpheralKey = @"kPrinterManagerUserInfoConnectedPerpheralKey";
static NSString *kPrinterManagerUserInfoErrorKey = @"kPrinterManagerUserInfoErrorKey";

static NSString *kPrinterManagerWillConnectPerpheralNotification = @"kPrinterManagerWillConnectPerpheralNotification";
static NSString *kPrinterManagerDidConnectPerpheralNotification = @"kPrinterManagerDidConnectPerpheralNotification";
static NSString *kPrinterManagerDidConnectPerpheralFailedNotification = @"kPrinterManagerDidConnectPerpheralFailedNotification";
static NSString *kPrinterManagerDidDisconnectPerpheralNotification = @"kPrinterManagerDidDisconnectPerpheralNotification";

// 准备好打印
static NSString *kPrinterManagerDidPreparePerpheralNotification = @"kPrinterManagerDidPreparePerpheralNotification";

@interface PrinterUtil : NSObject


@property (nonatomic, assign,readonly) CBCentralManagerState centralManagerState;
@property (strong, nonatomic,readonly)   CBPeripheral *connectedPerpheral;
@property (strong, nonatomic,readonly)   NSMutableArray<CBPeripheral *> *peripheralList;

// 适配 GPrinter SDK 的属性。
//@property (nonatomic, strong,readonly) ConnectViewController *connectVC;

+ (instancetype)sharedInstance;

#pragma mark - 打印判断
- (BOOL)canPrint;
- (void)showCanNotPrintReason;

#pragma mark - 扫描打印机
- (void)startScan;
- (void)stopScan;

- (void)connectPeriperhal:(CBPeripheral *)peripheral;
- (void)autoConnectLastPeripheral;
- (void)disconnectPeripheral:(CBPeripheral *)peripheral;
- (void)disconnectCurrentPeripheral;

- (BOOL)printOrder:(id)order ;

+ (void)initPrinter; // 测试方法，不做打印机

@end
