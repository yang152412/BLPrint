//
//  PrinterConnectViewController.m
//  BLPrint
//
//  Created by YJ on 16/6/7.
//  Copyright © 2016年 YJ. All rights reserved.
//

#import "PrinterConnectViewController.h"
#import "PrinterUtil.h"

@interface PrinterConnectViewController ()

@property (nonatomic, strong) NSMutableArray *devicesList;

@end

@implementation PrinterConnectViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    _devicesList = [[NSMutableArray alloc] init];
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginScan:) name:kBluetoothManagerNotificationDidBeginScan object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndScan:) name:kBluetoothManagerNotificationDidEndScan object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePerpheralList:) name:kBluetoothManagerNotificationDidUpdatePeripheralList object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPreparePerpheral:) name:kPrinterManagerDidPreparePerpheralNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectPerpheral:) name:kPrinterManagerDidDisconnectPerpheralNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectPerpheralError:) name:kPrinterManagerDidConnectPerpheralFailedNotification object:nil];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[PrinterUtil sharedInstance] startScan];
}

#pragma mark - printer method
- (void)didBeginScan:(NSNotification *)notification
{
    [_devicesList removeAllObjects];
    [self.tableView reloadData];
}

- (void)didEndScan:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)didUpdatePerpheralList:(NSNotification *)notification
{
    for (CBPeripheral *p in [PrinterUtil sharedInstance].peripheralList) {
        BOOL hasAdded = NO;
        for (CBPeripheral *hasP in _devicesList) {
            if ([hasP.identifier isEqual:p.identifier]) {
                hasAdded = YES;
                break;
            }
        }
        if (!hasAdded) {
            [_devicesList addObject:p];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_devicesList.count - 1 inSection:1];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        }
    }
}

- (void)didPreparePerpheral:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)didDisconnectPerpheral:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)didConnectPerpheralError:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)bluetoothDidUpdateState:(NSNotification *)notification
{
    CBCentralManager *manager = notification.userInfo[kBluetoothManagerNotificationUserInfoCentralKey];
    switch (manager.state) {
        case CBCentralManagerStateUnsupported:
            
            break;
        case CBCentralManagerStatePoweredOn:
            
            break;
        case CBCentralManagerStatePoweredOff:
            
            break;
        default:
            break;
    }
}

#pragma mark - tableview
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
    switch (section) {
        case 0:
            title = @"";
            break;
        case 1:
            title = @"可连接打印机";
            break;
            
        default:
            break;
    }
    return title;
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"[ConnectViewController] numberOfRowsInSection,device count = %d", [devicesList count]);
    switch (section) {
        case 0:
            return 1;
        case 1:
            return [_devicesList count];
        default:
            return 0;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"connectedList"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"connectedList"];
            }
            cell.textLabel.text = @"打印机";
            cell.detailTextLabel.text = @"扫描";
            cell.accessoryView = nil;
        }
            break;
            
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"devicesList"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"devicesList"];
                
                cell.textLabel.numberOfLines = 0;
            }
            CBPeripheral *tmpPeripheral = [_devicesList objectAtIndex:indexPath.row];
            cell.textLabel.text = tmpPeripheral.name;
            
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            switch (tmpPeripheral.state) {
                case CBPeripheralStateConnected:
                    cell.detailTextLabel.text = @"已连接";
                    cell.detailTextLabel.textColor = [UIColor blueColor];
                    break;
                case CBPeripheralStateConnecting:
                    cell.detailTextLabel.text = @"连接中...";
                    break;
                default:
                    cell.detailTextLabel.text = @"连接";
                    break;
            }
        }
            break;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            [[PrinterUtil sharedInstance] stopScan];
            [[PrinterUtil sharedInstance] startScan];
        }
            break;
        case 1:
        {
            CBPeripheral *p = _devicesList[indexPath.row];
            [[PrinterUtil sharedInstance] connectPeriperhal:p];
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
