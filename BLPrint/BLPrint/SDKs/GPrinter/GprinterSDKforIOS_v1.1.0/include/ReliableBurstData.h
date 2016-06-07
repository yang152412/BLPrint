//
//  ReliableBurstData.h
//  ReliableBurstData
//
//  Created by Rick on 14/2/19.
//  Copyright (c) 2014 ISSC Technologies Corporation. All rights reserved.
//

/*!
 *	@file ReliableBurstData.h
 *	@framework ReliableBurstData
 *
 *  @discussion Entry point to the ReliableBurstTransmit.
 *
 *	@copyright 2014 ISSC Technologies Corporation. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol ReliableBurstDataDelegate;
@interface ReliableBurstData : NSObject

/*!
 *  @method                 				transmitSize
 *
 *  @return                 				Max package size to transmit
 */
- (NSUInteger)transmitSize;

/*!
 *  @method                                 reliableBurstTransmit:withTransparentCharacteristic:
 *
 *  @discussion                             Send reliableBurstTransmit with special characteristic
 *
 *  @param data                             Data to transmit
 *  @param transparentDataWriteChar         Characteristic to transmit
 */
- (void)reliableBurstTransmit:(NSData *)data withTransparentCharacteristic:(CBCharacteristic *)transparentDataWriteChar;

/*!
 *  @method canSendReliableBurstTransmit
 *  
 *  @return                                 YES if the data can be sent, or NO if the transmission queue is full. If NO was returned,
 *     										wait for it return YES to send new data.
 */
- (BOOL)canSendReliableBurstTransmit;

/*!
 *
 *
 *  @return                                 YES if the accessory can disconnect now, or NO if the transmission is busy.
 *                                          If NO was returned, wait for it return YES to disconnect.
 *  @discussion
 *  For example:
 *              int count = 0;
                while (![reliableBurstData canDisconnect]) {
                    sleep(1);
                    count++;
                    if (count >= 10) {
                        break;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [manager cancelPeripheralConnection:peripheral];
                });
 */
- (BOOL)canDisconnect;

/*!
 *  @method                                 decodeReliableBurstTransmitEvent:
 *
 *  @param eventData                        The eventData need to decode for reliableBurstTransmit
 *
 *  @discussion                             This method decodes the events of reliable burst transmition, it should parse all the values
 *                                          of air patch characteristic first when receiving notifications.
 *  For example:
 *  - (void)updateAirPatchEvent: (NSData *)returnEvent {
        [reliableBurstData decodeReliableBurstTransmitEvent:returnEvent];
        ...
    }
 */
- (void)decodeReliableBurstTransmitEvent:(NSData *)eventData;

/*!
 *  @method                                 enableReliableBurstTransmit:andAirPatchCharacteristic:
 *
 *  @param peripheral                       CBPeripheral to enable ReliableBurstTransmit
 *  @param airPatchCharacteristic           CBCharacteristic with airPatch characteristic
 *
 *  @discussion                             Ues this method to enable ReliableBurstTransmit.
 *                                          This method have to be called before sending data.
 *  
 *  For example:
 *  - (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE]])
            for (aChar in service.characteristics)
            {
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_AIR_PATCH_CHAR]]) {
                    [reliableBurstData enableReliableBurstTransmit:aPeripheral andAirPatchCharacteristic:aChar];
                }
            }
    }

 */
- (void)enableReliableBurstTransmit:(CBPeripheral *)peripheral andAirPatchCharacteristic:(CBCharacteristic *)airPatchCharacteristic;

/*!
 *  @method                                 isReliableBurstTransmit:
 *
 *  @param transparentDataWriteChar         The parameter should input the CBCharacteristic object of didWriteValueForCharacteristic: delegate
 *
 *  @return                                 YES if writeValue:forCharacteristic:type: with CBCharacteristicWriteWithResponse type is call by ReliableBurstTransmit.
 *
 *  @discussion                             This library will use CBCharacteristicWriteWithResponse type when accessory doesn't
 *                                          support ReliableBurstTransmit feature. This method informs library the data have been sent.
 *  
 *  For example:
 *  - (void) peripheral:(CBPeripheral *)aPeripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    {
        if ([reliableBurstData isReliableBurstTransmit:characteristic]) {
            return;
        }
        // Other code
    }
 *
 */
- (BOOL)isReliableBurstTransmit:(CBCharacteristic *)transparentDataWriteChar;

/*!
 *  @method                                 version
 *
 *  @return                                 Version number with major.minor format.
 */
- (NSString *)version;
@property (nonatomic,weak)id<ReliableBurstDataDelegate>delegate;
@end
@protocol ReliableBurstDataDelegate <NSObject>

/*!
 *  @method                                 reliableBurstData:didSendDataWithCharacteristic:
 *
 *  @discussion                             This method is invoked when the data has been sent.
 *  
 */
- (void)reliableBurstData:(ReliableBurstData *)reliableBurstData didSendDataWithCharacteristic:(CBCharacteristic *)transparentDataWriteChar;

@end
