//
//  GPrinterController.m
//  BLPrint
//
//  Created by YJ on 16/6/7.
//  Copyright © 2016年 YJ. All rights reserved.
//

#import "GPrinterController.h"
#import "BLKWrite.h"

@implementation GPrinterController

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
//        connectedDeviceInfo = [NSMutableArray new];
//        connectingList = [NSMutableArray new];
//        
//        deviceInfo = [[DeviceInfo alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self startScan];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startScan];
}

- (void)startScan {
    [super startScan];
}

- (void)stopScan {
    [super stopScan];
}

- (void)updateDiscoverPeripherals {
    [super updateDiscoverPeripherals];
    
    [self.delegate didUpdatePeripheralList:self.devicesList];
}

- (void)updateMyPeripheralForDisconnect:(MyPeripheral *)myPeripheral {
    NSLog(@"updateMyPeripheralForDisconnect");//, %@", myPeripheral.advName);
    [[BLKWrite Instance] setPeripheral:nil];
    [self.delegate didDisconnectPeripheral:myPeripheral];
}

- (void)updateMyPeripheralForNewConnected:(MyPeripheral *)myPeripheral {
    
    [[BLKWrite Instance] setPeripheral:myPeripheral];
    [self storeMyPeripheral:myPeripheral.peripheral];
    
    [self.delegate didConnectPeripheral:myPeripheral];
}


#pragma mark - centralmanager
- (CBCentralManager *)centralManager
{
    return manager;
}


@end
