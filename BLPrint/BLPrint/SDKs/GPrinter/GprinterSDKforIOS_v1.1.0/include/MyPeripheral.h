//
//  MyPeripheral.h
//  BLETR
//
//  Created by D500 user on 13/5/30.
//  Copyright (c) 2013年 ISSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ReliableBurstData.h"

#define AIR_PATCH_COMMAND_VENDOR_MP_ENABLE      0x03
#define AIR_PATCH_COMMAND_XMEMOTY_READ          0x08
#define AIR_PATCH_COMMAND_XMEMOTY_WRITE         0x09
#define AIR_PATCH_COMMAND_E2PROM_READ           0x0a
#define AIR_PATCH_COMMAND_E2PROM_WRITE          0x0b
#define AIR_PATCH_COMMAND_READ                  0x24

#define AIR_PATCH_SUCCESS   0x00

#define AIR_PATCH_ACTION_CHANGE_DEVICE_NAME     0X01
#define AIR_PATCH_ACTION_READ_ADVERTISE_DATA1   0X02
#define AIR_PATCH_ACTION_READ_ADVERTISE_DATA2   0X03
#define AIR_PATCH_ACTION_UPDATE_ADVERTISE_DATA  0X04
#define AIR_PATCH_ACTION_CHANGE_DEVICE_NAME_MEMORY     0X05
#define AIR_PATCH_ACTION_READ                   0X24

#define ADVERTISE_DATA_TYPE_COMPLETE_DEVICE_NAME 0X09
#define ADVERTISE_DATA_TYPE_SHORTEN_DEVICE_NAME  0X08

enum {
    MYPERIPHERAL_CONNECT_STATUS_IDLE = 0,
    MYPERIPHERAL_CONNECT_STATUS_CONNECTING,
    MYPERIPHERAL_CONNECT_STATUS_CONNECTED,
};

enum {
    UPDATE_PARAMETERS_STEP_PREPARE = 0,
    UPDATE_PARAMETERS_STEP_CHECK_RESULT,
};
typedef struct _AIR_PATCH_COMMAND_FORMAT
{
    unsigned char commandID;
    char parameters[19];
}__attribute__((packed)) AIR_PATCH_COMMAND_FORMAT;

typedef struct _AIR_PATCH_EVENT_FORMAT
{
    char    status;
    unsigned char commandID;
    char parameters[16];
}__attribute__((packed)) AIR_PATCH_EVENT_FORMAT;


typedef struct _WRITE_EEPROM_COMMAND_FORMAT
{
    unsigned char addr[2];
    unsigned char length;
    char    data[16];
}__attribute__((packed)) WRITE_EEPROM_COMMAND_FORMAT;

typedef struct _CONNECTION_PARAMETER_FORMAT
{
    unsigned char status;
    unsigned short minInterval;
    unsigned short maxInterval;
    unsigned short latency;
    unsigned short connectionTimeout;
}__attribute__((packed)) CONNECTION_PARAMETER_FORMAT;


@protocol MyPeripheralDelegate;
@interface MyPeripheral : NSObject
{
@private
    char    advData[25];
    char    deviceName[16];
    NSMutableArray *queuedTask;
}
@property(assign) id<MyPeripheralDelegate> transDataDelegate;
@property(assign) id<MyPeripheralDelegate> proprietaryDelegate;
@property(assign) id<MyPeripheralDelegate> deviceInfoDelegate;

@property (retain) CBPeripheral *peripheral;
@property(copy) NSString *advName;
@property(assign) uint8_t connectStaus;
@property (assign) BOOL canSendData;

//DIS
@property(retain) CBCharacteristic *manufactureNameChar;
@property(retain) CBCharacteristic *modelNumberChar;
@property(retain) CBCharacteristic *serialNumberChar;
@property(retain) CBCharacteristic *hardwareRevisionChar;
@property(retain) CBCharacteristic *firmwareRevisionChar;
@property(retain) CBCharacteristic *softwareRevisionChar;
@property(retain) CBCharacteristic *systemIDChar;
@property(retain) CBCharacteristic *certDataListChar;
@property(retain) CBCharacteristic *specificChar1;
@property(retain) CBCharacteristic *specificChar2;

//Proprietary
@property(retain) CBCharacteristic *airPatchChar;
@property(retain) CBCharacteristic *transparentDataWriteChar;
@property(retain) CBCharacteristic *transparentDataReadChar;
@property(retain) CBCharacteristic *connectionParameterChar;
@property(assign) uint8_t   updateConnectionParameterStep;
@property(readonly) ReliableBurstData *transmit;

@property(assign) CONNECTION_PARAMETER_FORMAT connectionParameter;
@property(assign) CONNECTION_PARAMETER_FORMAT backupConnectionParameter;


@property(assign) BOOL    vendorMPEnable;
@property(assign) short   airPatchAction;
@property(assign) BOOL    isNotifying;


- (CONNECTION_PARAMETER_FORMAT *)retrieveBackupConnectionParameter;
- (void)updateBackupConnectionParameter:(CONNECTION_PARAMETER_FORMAT *)parameter;
- (BOOL)compareBackupConnectionParameter:(CONNECTION_PARAMETER_FORMAT *)parameter;

- (void)checkConnectionParameterStatus;
- (void)sendVendorMPEnable;
- (void)updateAirPatchEvent: (NSData *)returnEvent;
- (void)writeE2promValue: (short)address length:(short)length data:(char *)data;
- (void)readE2promValue: (short)address length:(short)length;
- (void)writeMemoryValue: (short)address length:(short)length data:(char *)data;
- (void)readMemoryValue: (short)address length:(short)length;
- (CBCharacteristicWriteType)sendTransparentData:(NSData *)data type:(CBCharacteristicWriteType)type;
- (void)setTransDataNotification:(BOOL)notify;

- (NSError *)setMaxConnectionInterval:(unsigned short)maxInterval connectionTimeout:(unsigned short)connectionTimeout connectionLatency:(unsigned short)connectionLatency;
- (void)checkIsAllowUpdateConnectionParameter;
- (void)changePeripheralName: (NSString *)name;

- (void)readManufactureName;
- (void)readModelNumber;
- (void)readSerialNumber;
- (void)readHardwareRevision;
- (void)readFirmwareRevision;
- (void)readSoftwareRevison;
- (void)readSystemID;
- (void)readCertificationData;
- (void)readSpecificUUID1;
- (void)readSpecificUUID2;

@end


@protocol MyPeripheralDelegate<NSObject>
@optional
- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateConnectionParameterAllowStatus:(BOOL)status;
- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateConnectionParameterStatus:(BOOL)status interval:(unsigned short)interval timeout:(unsigned short)timeout  latency:(unsigned short)latency;

- (void)MyPeripheral:(MyPeripheral *)peripheral didChangePeripheralName:(NSError *)error;

- (void)MyPeripheral:(MyPeripheral *)peripheral didReceiveTransparentData:(NSData *)data;
- (void)MyPeripheral:(MyPeripheral *)peripheral didReceiveMemoryAddress:(NSData *)address length:(short)length data:(NSData *)data;
- (void)MyPeripheral:(MyPeripheral *)peripheral didWriteMemoryAddress:(NSError *)error;
- (void)MyPeripheral:(MyPeripheral *)peripheral didSendTransparentDataStatus:(NSError *) error;
- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateTransDataNotifyStatus:(BOOL)notify;

- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateManufactureName:(NSString *)name error:(NSError *)error;
- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateModelNumber:(NSString *)modelNumber error:(NSError *)error;

- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateSerialNumber:(NSString *)serialNumber error:(NSError *)error;
- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateHardwareRevision:(NSString *)hardwareRevision error:(NSError *)error;
- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateFirmwareRevision:(NSString *)firmwareRevision error:(NSError *)error;
- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateSoftwareRevision:(NSString *)softwareRevision error:(NSError *)error;
- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateSystemId:(NSData *)systemId error:(NSError *)error;
- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateIEEE_11073_20601:(NSData *)IEEE_11073_20601 error:(NSError *)error;
- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateSpecificUUID1:(NSData *)value error:(NSError *)error;
- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateSpecificUUID2:(NSData *)value error:(NSError *)error;
@end
