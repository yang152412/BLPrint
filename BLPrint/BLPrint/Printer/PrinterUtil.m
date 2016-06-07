//
//  PrinterUtil.m
//  partner
//
//  Created by 杨世昌 on 16/5/26.
//  Copyright © 2016年 杨世昌. All rights reserved.
//

#import "PrinterUtil.h"

#import "PrinterScanProtocol.h"
#import "BLGPrinterSDKModel.h"

// GPrinter SDK
#import "BLKWrite.h"
#import "EscCommand.h"
//#import "ConnectViewController.h"
#import "PrinterFormatText.h"

#import "Toast.h"
#import "NSString+Util.h"

#import "Order.h"

@interface PrinterUtil () <PrinterScanDelegate,CBCentralManagerDelegate>

@property (nonatomic, assign) BOOL isAutoConnect;

@property (nonatomic, strong) id autoPrintObject;

@property (nonatomic, strong) CBCentralManager *centralManager; // 只负责 监听状态

@property (nonatomic, strong) NSMutableArray<id<PrinterScanProtocol>> *sdkScanObjects;
@property (nonatomic, strong) NSMutableArray<id<CBPeripheralDelegate>> *sdkPeripheralObjects;

@end

@implementation PrinterUtil
@synthesize //connectVC = _connectVC,
peripheralList = _peripheralList;

#pragma mark - 单例
+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _peripheralList = [[NSMutableArray alloc] init];
        _sdkScanObjects = [[NSMutableArray alloc] init];
        _sdkPeripheralObjects = [[NSMutableArray alloc] init];
        
        self.isAutoConnect = YES;
        [self initCBCentralManager];
        
        [self initGPrinter];
    }
    return self;
}

- (void)initCBCentralManager
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             //重设centralManager恢复的IdentifierKey
                             @"DDBluetoothRestore",CBCentralManagerOptionRestoreIdentifierKey,
                             nil];
    NSArray *backgroundModes = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"UIBackgroundModes"];
    if ([backgroundModes containsObject:@"bluetooth-central"]) {
        //后台模式
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
    }
    else {
        //非后台模式
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
}

- (void)initGPrinter {
    
    BLGPrinterSDKModel *gprinter = [[BLGPrinterSDKModel alloc] init];
    gprinter.delegate = self;
    [_sdkScanObjects addObject:gprinter];
}

#pragma mark - getter/setter

- (CBCentralManagerState)centralManagerState
{
    return _centralManager.state;
}

#pragma mark - 打印判断
- (BOOL)canPrint
{
    // 蓝牙打开，设备正在连接 或者 有上次保存的连接数据，可以做自动连接
    if ((self.centralManager.state == CBCentralManagerStatePoweredOn ||
         self.centralManager.state == CBCentralManagerStateUnknown) &&
        (self.connectedPerpheral.state == CBPeripheralStateConnected ||
         ![NSString isEmptyString:[self lastPeripheralUUIDString]])) {
        return YES;
    } else {
        return NO;
    }
}

- (void)showCanNotPrintReason
{
    BOOL showDeviceReason = NO;
    switch (self.centralManager.state) {
        case CBCentralManagerStatePoweredOn:
            
            break;
        case CBCentralManagerStatePoweredOff:
            showDeviceReason = YES;
            [Toast showMessage:@"未打开蓝牙，请到设置中打开蓝牙"];
            break;
        case CBCentralManagerStateUnsupported:
            showDeviceReason = YES;
            [Toast showMessage:@"当前设备不支持蓝牙，无法打印"];
            break;
        default:
            break;
    }
    
    if (showDeviceReason == NO && self.connectedPerpheral.state != CBPeripheralStateConnected) {
        [Toast showMessage:@"未连接打印机，请到设置中连接打印机"];
    }
}

#pragma mark - 扫描打印机
- (void)startScan
{
    if (self.centralManager.state == CBCentralManagerStatePoweredOff) {
        return;
    }
    [_peripheralList removeAllObjects];
    
//    UIWindow *window = APP_DELEGATE.window;
//    if (![window viewWithTag:121212]) {
//        self.connectVC.view.frame = CGRectZero;
//        self.connectVC.view.tag = 121212;
//        
//        [window addSubview:self.connectVC.view];
//    }
//    
//    [self.connectVC startScan];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [self.centralManager scanForPeripheralsWithServices:nil options:scanForPeripheralsWithOptions];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopScan];
        [self connectTimeout];
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothManagerNotificationDidBeginScan
                                                        object:nil userInfo:nil];
}

- (void)stopScan
{
//    [self.connectVC.view removeFromSuperview];
    
//    [self.connectVC stopScan];
    
    [self.centralManager stopScan];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothManagerNotificationDidEndScan
                                                        object:nil userInfo:nil];
}

#pragma mark - 链接打印机

- (void)connectPeriperhal:(CBPeripheral *)peripheral
{
    if (peripheral.state == CBPeripheralStateConnecting ||
        peripheral.state == CBPeripheralStateConnected) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPrinterManagerWillConnectPerpheralNotification
                                                        object:nil userInfo:nil];

    [_sdkScanObjects enumerateObjectsUsingBlock:^(id<PrinterScanProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj connectPeripheral:peripheral];
    }];
    
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    [_centralManager connectPeripheral:(CBPeripheral  *)peripheral options:connectOptions];
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral
{
    [_sdkScanObjects enumerateObjectsUsingBlock:^(id<PrinterScanProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj disconnectPeripheral:peripheral];
    }];
    [_centralManager cancelPeripheralConnection:(CBPeripheral *)peripheral];
}

// 自动链接上一次 打印机
- (void)autoConnectLastPeripheral
{
    if ([self lastPeripheralUUIDString]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPrinterManagerWillConnectPerpheralNotification
                                                            object:nil userInfo:nil];
        
        
        self.isAutoConnect = YES;
        
        //            NSArray *peripherals = [_connectVC.centralManager retrievePeripheralsWithIdentifiers:@[[self lastPeripheralUUIDString]]];
        
        NSArray *peripherals = [_centralManager retrievePeripheralsWithIdentifiers:@[[self lastPeripheralUUIDString]]];
        if (peripherals.count > 0) {
            for (CBPeripheral *p in peripherals) {
                //                    [_connectVC retrieveMyPeripheral:p];
                
                [self connectPeriperhal:p];
            }
        } else {
            [self startScan];
        }
        
    }
}


- (void)disconnectCurrentPeripheral
{
    [self disconnectPeripheral:self.connectedPerpheral];
}

- (void)connectTimeout
{
    if (self.isAutoConnect) {
        
        if (self.connectedPerpheral == nil) {
            // 自动连接超时
            [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothManagerNotificationAutoConnectPeripheralTimeout
                                                                object:nil userInfo:nil];
            
        }
        
        self.isAutoConnect = NO;
    }
}

#pragma mark - 添加 deviceList 方法
- (void)addPeripheralToList:(CBPeripheral *)peripheral
{
    __block BOOL isAdded = NO;
    [_peripheralList enumerateObjectsUsingBlock:^(CBPeripheral * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqual:peripheral.identifier]) {
            isAdded = YES;
            *stop = YES;
        }
    }];
    
    if (!isAdded) {
        [_peripheralList addObject:peripheral];
    }
}



- (void)didUpdatePeripheralList:(NSArray *)peripherals
{
//    [peripherals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (![_peripheralList containsObject:obj]) {
//            [_peripheralList addObject:obj];
//        }
//    }];
    
    if (self.connectedPerpheral) {
        __block BOOL isExit = NO;
        [_peripheralList enumerateObjectsUsingBlock:^(CBPeripheral * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.identifier isEqual:self.connectedPerpheral.identifier]) {
                isExit = YES;
            }
        }];
        
        if (!isExit) {
            [_peripheralList insertObject:self.connectedPerpheral atIndex:0];
        }
    }

    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothManagerNotificationDidUpdatePeripheralList
                                                        object:nil
                                                      userInfo:nil];
    
    if (self.isAutoConnect) {
        [peripherals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CBPeripheral *my = (CBPeripheral *)obj;
            if ([self isLastPeriperhal:my]) {
                [self connectPeriperhal:my];
                
//                [self stopScan];
            }
        }];
    }
    
    
}

#pragma mark  protocol ScanDelegate

- (void)didConnectPeripheral:(CBPeripheral *)peripheral
{
//    self.myPerpheral = peripheral;
    
    _connectedPerpheral = peripheral;
    [self savePeripheral];
    
    // 去掉自动连接的判断
    if (self.isAutoConnect) {
        self.isAutoConnect = NO;
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPrinterManagerDidConnectPerpheralNotification
                                                        object:nil
                                                      userInfo:@{kPrinterManagerUserInfoConnectedPerpheralKey:_connectedPerpheral}];
}
- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral
{
//    self.myPerpheral = nil;
    _connectedPerpheral = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPrinterManagerDidDisconnectPerpheralNotification
                                                        object:nil
                                                      userInfo:@{kPrinterManagerUserInfoConnectedPerpheralKey:peripheral}];
}

- (void)didConnectPeripheral:(CBPeripheral *)peripheral failed:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPrinterManagerDidConnectPerpheralFailedNotification
                                                        object:nil
                                                      userInfo:@{kPrinterManagerUserInfoConnectedPerpheralKey:peripheral}];
}

- (void)didPrepareForPrintWithPeripheral:(CBPeripheral *)peripheral
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPrinterManagerDidPreparePerpheralNotification
                                                        object:nil
                                                      userInfo:@{kPrinterManagerUserInfoConnectedPerpheralKey:peripheral}];
    
    if (self.autoPrintObject) {
        // 立即执行，没反应。延迟执行吧
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doPrintOrder:self.autoPrintObject];
        });
        
    }
}

#pragma mark - 打印机 CB delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kBluetoothManagerNotificationCentralManagerDidUpdateState
                                                       object:nil
                                                     userInfo:@{kBluetoothManagerNotificationUserInfoCentralKey:central}];
    
//    [self.connectVC centralManagerDidUpdateState:central];
    
    [_sdkScanObjects enumerateObjectsUsingBlock:^(id<PrinterScanProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj centralManagerDidUpdateState:central];
    }];
}


- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    NSLog(@">>>CBCentralManagerwillRestoreState %@",dict);
    
//    [self.connectVC centralManager:central willRestoreState:dict];
    [_sdkScanObjects enumerateObjectsUsingBlock:^(id<PrinterScanProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj respondsToSelector:@selector(centralManager:willRestoreState:)]) {
            [obj centralManager:central willRestoreState:dict];
        }
    }];
}



- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self addPeripheralToList:peripheral];
    [self didUpdatePeripheralList:_peripheralList];
    
//    [self.connectVC centralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    [_sdkScanObjects enumerateObjectsUsingBlock:^(id<PrinterScanProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)]) {
            [obj centralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
        }
    }];
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//    [self.connectVC centralManager:central didConnectPeripheral:peripheral];
    [_sdkScanObjects enumerateObjectsUsingBlock:^(id<PrinterScanProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj respondsToSelector:@selector(centralManager:didConnectPeripheral:)]) {
            [obj centralManager:central didConnectPeripheral:peripheral];
        }
    }];
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
//    [self.connectVC centralManager:central didFailToConnectPeripheral:peripheral error:error];
    [_sdkScanObjects enumerateObjectsUsingBlock:^(id<PrinterScanProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj respondsToSelector:@selector(centralManager:didFailToConnectPeripheral:error:)]) {
            [obj centralManager:central didFailToConnectPeripheral:peripheral error:error];
        }
    }];
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
//    [self.connectVC centralManager:central didDisconnectPeripheral:peripheral error:error];
    [_sdkScanObjects enumerateObjectsUsingBlock:^(id<PrinterScanProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj respondsToSelector:@selector(centralManager:didDisconnectPeripheral:error:)]) {
            [obj centralManager:central didDisconnectPeripheral:peripheral error:error];
        }
    }];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(CBPeripheral *)peripheral
{
//    if ([self.connectVC respondsToSelector:@selector(centralManager:didRetrievePeripherals:)]) {
//        //        [super centralManager:central didRetrievePeripherals:peripheral];
//        [self.connectVC performSelector:@selector(centralManager:didRetrievePeripherals:) withObject:central withObject:peripheral];
//    }
    
    [_sdkScanObjects enumerateObjectsUsingBlock:^(id<PrinterScanProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(centralManager:didRetrievePeripherals:)]) {
            [obj performSelector:@selector(centralManager:didRetrievePeripherals:) withObject:central withObject:peripheral];
        }
    }];
}

#pragma mark - save 打印机
- (void)savePeripheral
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.connectedPerpheral.identifier.UUIDString forKey:@"DDPeripheral"];
    [userDefaults synchronize];
}

- (NSString *)lastPeripheralUUIDString
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UUIDString = [userDefaults objectForKey:@"DDPeripheral"];
    return UUIDString;
}

- (BOOL)isLastPeriperhal:(CBPeripheral *)peripheral
{
    NSString *UUIDString = [self lastPeripheralUUIDString];
    
    if ([peripheral.identifier.UUIDString isEqualToString:UUIDString]) {
        return YES;
    }
    return NO;
}

- (void)removeLastPeripheral
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"DDPeripheral"];
    [userDefaults synchronize];
}



#pragma mark - 打印
+ (void)initPrinter {
    
}

+ (void)resetPrinter {

}

+ (void)wakeUpPrinter {

}

#pragma mark - 打印

- (BOOL)printOrder:(id)order {
    if (![order isKindOfClass:[Order class]]) {
        return NO;
    }
    
    if (!self.connectedPerpheral) {
        [self autoConnectLastPeripheral];
        self.autoPrintObject = order;// 自动打印
        return YES;
    }
    
    [self doPrintOrder:order];
    
    return YES;
}

- (void)doPrintOrder:(id)order {
    [self gPrinterDoPrintWithOrder:order];
    
    // 清除对象
    self.autoPrintObject = nil;
}

- (NSString *)formatDateString:(NSTimeInterval)dateInterval {
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:dateInterval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd HH:mm";
    return [formatter stringFromDate:date];
}


#pragma mark - GPrinter SDK
- (void)gPrinterDoPrintWithOrder:(Order *)order {
    //获取打印机纸张宽度
    int width = [[BLKWrite Instance] PrintWidth];
    NSLog(@"PrintWidth:%d mm", width);
    
    EscCommand *escCmd = [[EscCommand alloc] init];
    [escCmd setHasResponse:YES];
    /*
     一定会发送的设置项
     */
    //打印机初始化，清空缓存
    [escCmd addInitializePrinter];
    
    [escCmd addSetJustification:1]; // 0左对齐,1中间对齐,2右对齐
    
    //title
    NSString *title = [NSString stringWithFormat:@"*****#%@ 叮咚小区******",order.order_code];
    [escCmd addText:title];
    [escCmd addText:@"\n"];// 换行
    
    [escCmd addText:@"\n"];// 换行
    
    // 商户名
    NSString *shopName = [NSString stringWithFormat:@"%@",order.merchant_name];
    [escCmd addText:shopName];
    [escCmd addText:@"\n"];// 换行
    
    // 预约时间
    NSString *appointmentTime = [NSString stringWithFormat:@"预约时间: %@",[self formatDateString:order.reserved_time_start]];
    [escCmd addText:appointmentTime];
    [escCmd addText:@"\n"];// 换行
    
    // 下单时间
    NSString *orderTime = [NSString stringWithFormat:@"下单时间: %@",[self formatDateString:order.create_time]];
    [escCmd addText:orderTime];
    [escCmd addText:@"\n"];// 换行
    
    // 分割线
    [escCmd addText:kSeperaterLine];
    [escCmd addText:@"\n"];// 换行
    
    // 设置 左对齐
    [escCmd addSetJustification:0]; // 0左对齐,1中间对齐,2右对齐
    
    // 商品 数量 名称
    NSString *countString = [[PrinterFormatText getTextsWithLeft:@"商品" middle:@"数量" right:@"小计"] firstObject];
    [escCmd addText:countString];
    [escCmd addText:@"\n"];// 换行
    
    // 分割线
    [escCmd addText:kSeperaterLine];
    [escCmd addText:@"\n"];// 换行
    
    // 商品
    
    for (int i = 0; i < order.products.count; i++) {
        Product *product = order.products[i];
        NSString *name = product.name;
        NSString *count = [NSString stringWithFormat:@"X%ld",(long)product.count];
        NSString *money = [NSString stringWithFormat:@"%.2f",product.count*product.price];
        
        NSArray *pStringArr = [PrinterFormatText getTextsWithLeft:name middle:count right:money];
        for (NSString *lineStr in pStringArr) {
            [escCmd addText:lineStr];
            [escCmd addText:@"\n"];// 换行
        }
    }
    
    // 分割线
    [escCmd addText:kSeperaterLine];
    [escCmd addText:@"\n"];// 换行
    
    // 合计
    NSString *payState = order.pay_type == 1 ? @"未支付" : @"已支付";
    NSString *totalTitle = [NSString stringWithFormat:@"合计 (%@) ",payState];
    NSString *totalStr = [NSString stringWithFormat:@"%@",order.money];
    NSString *total = [[PrinterFormatText getTextsWithLeft:totalTitle middle:@"" right:totalStr] firstObject];
    [escCmd addText:total];
    [escCmd addText:@"\n"];// 换行
    
    // 分割线
    [escCmd addText:kSeperaterLine];
    [escCmd addText:@"\n"];// 换行
    
    if (![NSString isEmptyString:order.order_note]) {
        // 设置 左对齐
        [escCmd addSetJustification:0]; // 0左对齐,1中间对齐,2右对齐
        // 备注
        NSString *mark = [NSString stringWithFormat:@"顾客备注:%@",order.order_note];
        [escCmd addText:mark];
        [escCmd addText:@"\n"];// 换行
        
        // 星号，结束
        [escCmd addText:kFinishLine];
        [escCmd addText:@"\n"];// 换行
    }
    
    [escCmd addPrintMode: 0x1B];
    [escCmd addPrintAndFeedLines:4];
    
    NSData *commandData = [escCmd getCommand];
    NSLog(@" \n print data = %@ \n ",commandData);
    
    
//    PrinterSetting *setting = [[AppConfigManager shareInstance] printerSetting];
    // 打印联数，可以设置一次打印几联
    int printUnit = 1;
    
    if (printUnit > 1) {
        NSMutableData *mutData = [[NSMutableData alloc] initWithData:commandData];
        for (int i = 1; i<printUnit; i++) {
            [mutData appendData:commandData];
        }
        [[BLKWrite Instance] writeEscData:mutData withResponse:escCmd.hasResponse];
    } else {
        [[BLKWrite Instance] writeEscData:commandData withResponse:escCmd.hasResponse];
    }
    
}

@end
