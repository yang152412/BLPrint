//
//  BLKWrite.h
//  Gprinter
//
//  Created by Wind on 14/12/20.
//  Copyright (c) 2014年 JiaBo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyPeripheral.h"

/*
 调用Wi-Fi模式
 
 1 [BLKWrite Instance] 设置ServerIP、port
 2 [[BLKWrite Instance] initWiFiClient];
 3 TSC：-(void) writeTscData:(NSData*) data withResponse;
 4 ESC：-(void) writeEscData:(NSData*) data withResponse;
 
 */


@interface BLKWrite : NSObject<MyPeripheralDelegate>

@property (nonatomic, strong) MyPeripheral *connectedPeripheral;
@property (nonatomic, assign) BOOL bWiFiMode; //YES: Wi-Fi模式；NO：蓝牙模式
@property (nonatomic, strong) NSString *serverIP;
@property (nonatomic, assign) int port;


+(BLKWrite*) Instance;

-(void) writeTscData:(NSData*) data withResponse:(BOOL) flag;
-(void) writeEscData:(NSData*) data withResponse:(BOOL) flag;
-(BOOL) isConnecting;

-(void) setPeripheral:(MyPeripheral*) peripheral;

#pragma mark-Wi-Fi Mode

-(void) initWiFiClient;

-(int) PrintWidth;

@end
