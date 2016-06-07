//
//  ViewController.m
//  BLPrint
//
//  Created by YJ on 16/6/7.
//  Copyright © 2016年 YJ. All rights reserved.
//

#import "ViewController.h"
#import "PrinterConnectViewController.h"
#import "PrinterUtil.h"
#import "Order.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
//        PrinterConnectViewController *controller = (PrinterConnectViewController *)[[segue destinationViewController] topViewController];
//        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

- (IBAction)print:(id)sender
{
    Order *order = [Order getTestData];
    [[PrinterUtil sharedInstance] printOrder:order];
}

@end
