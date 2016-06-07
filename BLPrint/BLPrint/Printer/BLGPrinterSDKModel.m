//
//  SDKModel.m
//  partner
//
//  Created by YJ on 16/6/6.
//  Copyright © 2016年 YJ. All rights reserved.
//

#import "BLGPrinterSDKModel.h"
#import "CBController.h"
#import "GPrinterController.h"

@interface BLGPrinterSDKModel ()<CBControllerDelegate>

//@property (nonatomic, strong) MyPeripheral *connectedMyPeripheral;

//@property (nonatomic, strong,readonly) ConnectViewController *connectVC;
@property (nonatomic, strong,readonly) GPrinterController *connectVC;

@property (nonatomic, strong) MyPeripheral *connectedPeripheral;

@property (nonatomic, strong) NSMutableArray *deviceList;

@end

@implementation BLGPrinterSDKModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _deviceList = [[NSMutableArray alloc] init];
        [self initGPrinter];
    }
    return self;
}

- (void)initGPrinter {
    GPrinterController *connectVC = [[GPrinterController alloc] init];
    connectVC.centralManager.delegate = nil; // 清除 他自己的 delegate，我们自己做
    connectVC.centralManager = nil;
    _connectVC = connectVC;
    
    connectVC.delegate = self;
//    connectVC.connectVCDelegate = self;
}

- (MyPeripheral *)findMyPeripheralWithCBPeripheral:(CBPeripheral *)peripheral
{
    __block MyPeripheral *myp = nil;
    
    [_connectVC.devicesList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MyPeripheral *my = (MyPeripheral *)obj;
        if ([my.peripheral.identifier isEqual:peripheral.identifier]) {
            myp = my;
        }
    }];
    
    return myp;
}

- (void)startScan
{
    _connectVC.centralManager.delegate = nil; // 清除 他自己的 delegate，我们自己做
    [_connectVC startScan];
}
- (void)stopScan
{
    [_connectVC stopScan];
}


- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    MyPeripheral *myP = [self findMyPeripheralWithCBPeripheral:peripheral];
    [_connectVC connectDevice:myP]; // 调用他们 sdk 自己的方法
}
- (void)disconnectPeripheral:(CBPeripheral *)peripheral
{
    MyPeripheral *myP = [self findMyPeripheralWithCBPeripheral:peripheral];
    [_connectVC disconnectDevice:myP]; // 调用他们 sdk 自己的方法
}

#pragma mark  protocol CBControllerDelegate

- (void)didUpdatePeripheralList:(NSArray *)peripherals
{
//    [peripherals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//        MyPeripheral *my = (MyPeripheral *)obj;
//        
//        if (![_deviceList containsObject:my.peripheral]) {
//            [_deviceList addObject:my.peripheral];
//        }
//    }];
    
//    [self.delegate didUpdatePeripheralList:_deviceList];
}
- (void)didConnectPeripheral:(MyPeripheral *)peripheral
{
    self.connectedPeripheral = peripheral;
    
    [self.delegate didConnectPeripheral:peripheral.peripheral];
}
- (void)didDisconnectPeripheral:(MyPeripheral *)peripheral
{
    [self.delegate didDisconnectPeripheral:peripheral.peripheral];
     self.connectedPeripheral = nil;
}
- (void)didConnectPeripheral:(MyPeripheral *)peripheral failed:(NSError *)error
{
    [self.delegate didConnectPeripheral:peripheral.peripheral failed:error];
}
- (void)didPrepareForPrintWithPeripheral:(MyPeripheral *)peripheral
{
    [self.delegate didPrepareForPrintWithPeripheral:peripheral.peripheral];
}


#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [_connectVC centralManagerDidUpdateState:central];
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    NSLog(@">>>CBCentralManagerwillRestoreState %@",dict);
    
    [self.connectVC centralManager:central willRestoreState:dict];
}



- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self.connectVC centralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.connectVC centralManager:central didConnectPeripheral:peripheral];
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    [self.connectVC centralManager:central didFailToConnectPeripheral:peripheral error:error];
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    [self.connectVC centralManager:central didDisconnectPeripheral:peripheral error:error];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(CBPeripheral *)peripheral
{
    if ([self.connectVC respondsToSelector:@selector(centralManager:didRetrievePeripherals:)]) {
        //        [super centralManager:central didRetrievePeripherals:peripheral];
        [self.connectVC performSelector:@selector(centralManager:didRetrievePeripherals:) withObject:central withObject:peripheral];
    }
}

@end
