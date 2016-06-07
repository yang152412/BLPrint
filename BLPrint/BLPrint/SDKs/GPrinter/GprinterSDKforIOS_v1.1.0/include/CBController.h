//
//  CBController.h
//  BLETR
//
//  Created by user D500 on 12/2/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MyPeripheral.h"

enum {
    LE_STATUS_IDLE = 0,
    LE_STATUS_SCANNING,
    LE_STATUS_CONNECTING,
    LE_STATUS_CONNECTED
};


@interface MultiDevice : NSObject
@property(nonatomic, assign) NSInteger index;//0：ISSC；1：红果
@property(nonatomic, assign) BOOL connected;//是否已经连接
@end


@protocol CBControllerDelegate;
@interface CBController : UIViewController<CBCentralManagerDelegate, CBPeripheralDelegate,ReliableBurstDataDelegate>
{
    CBCentralManager *manager;
    NSMutableArray *devicesList;
    BOOL    notifyState;
    NSMutableArray *_connectedPeripheralList;
    CBUUID *_transServiceUUID;
    CBUUID *_transTxUUID;
    CBUUID *_transRxUUID;
    CBUUID *_disUUID1;
    CBUUID *_disUUID2;
    BOOL    isISSCPeripheral;
}

@property(assign) id<CBControllerDelegate> delegate;
@property (retain) NSMutableArray *devicesList;

- (void) startScan;
- (void) stopScan;
- (void)connectDevice:(MyPeripheral *) myPeripheral;
- (void)disconnectDevice:(MyPeripheral *) aPeripheral;
- (NSMutableData *) hexStrToData: (NSString *)hexStr;
- (BOOL) isLECapableHardware;
- (void)addDiscoverPeripheral:(CBPeripheral *)aPeripheral advName:(NSString *)advName;
- (void)updateDiscoverPeripherals;
- (void)updateMyPeripheralForDisconnect:(MyPeripheral *)myPeripheral;
- (void)updateMyPeripheralForNewConnected:(MyPeripheral *)myPeripheral;
- (void)storeMyPeripheral: (CBPeripheral *)aPeripheral;
- (MyPeripheral *)retrieveMyPeripheral: (CBPeripheral *)aPeripheral;
- (void)removeMyPeripheral: (CBPeripheral *) aPeripheral;
- (void)configureTransparentServiceUUID: (NSString *)serviceUUID txUUID:(NSString *)txUUID rxUUID:(NSString *)rxUUID;
- (void)configureDeviceInformationServiceUUID: (NSString *)UUID1 UUID2:(NSString *)UUID2;
@end

@protocol CBControllerDelegate
@required
- (void)didUpdatePeripheralList:(NSArray *)peripherals;
- (void)didConnectPeripheral:(MyPeripheral *)peripheral;
- (void)didDisconnectPeripheral:(MyPeripheral *)peripheral;
@end