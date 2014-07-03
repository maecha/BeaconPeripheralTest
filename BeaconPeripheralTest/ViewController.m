//
//  ViewController.m
//  BeaconPeripheralTest
//
//  Created by 前田 誠也 on 2014/07/04.
//  Copyright (c) 2014年 Seiya Maeda. All rights reserved.
//

// 送信側ペリフェラル peripheral

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
// Peripheral1にはCoreBluetoothフレームワークを読み込ませる必要がある（CBPeripheralManagerを使用するため）
#import <CoreBluetooth/CoreBluetooth.h>

#define UUID @"096781F6-8F73-41D2-A768-FB45AE14BDC9"
#define MAJOR 3
#define MINOR 10
// Beacon信号に含まれず、領域識別のための内部管理用の識別子
#define IDENTIFER @"info.maezono.beacontest"

@interface ViewController () <CBPeripheralManagerDelegate>

@property(nonatomic, strong) NSUUID *proximityUUID;
@property(nonatomic, strong) CBPeripheralManager *peripheralManager;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:UUID];
    
    // CBPeripheralManagerを作成
    //self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    // アドバタイズ開始処理
    // CBPeripheralManagerState の状態は Bluetoothの状態（電源のOn,Offやアプリケーションに実行権限があるかなど）を確認してくれる。
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        [self startAdvertising];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startAdvertising
{
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                                           major: MAJOR
                                                                           minor: MINOR
                                                                      identifier: IDENTIFER];
    
    NSDictionary *beaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    
    [self.peripheralManager  startAdvertising:beaconPeripheralData];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    
    if (error) {
        
        NSLog(@"Failed to start advertising with error:%@", error);
    }
    else {
        
        NSLog(@"Start advertising");
        
    }
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    NSString *stateStr;
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
        {
            stateStr = @"PoweredOff";
            break;
        }
        case CBPeripheralManagerStatePoweredOn:
        {
            stateStr = @"PoweredOn";
            
            [self startAdvertising];
            
            break;
        }
        case CBPeripheralManagerStateResetting:
        {
            stateStr = @"Resetting";
            break;
        }
        case CBPeripheralManagerStateUnauthorized:
        {
            stateStr = @"Unauthorized";
            break;
        }
        case CBPeripheralManagerStateUnknown:
        {
            stateStr = @"Unknown";
            break;
        }
        case CBPeripheralManagerStateUnsupported:
        {
            stateStr = @"Unsupported";
            break;
        }
        default:
        {
            stateStr = nil;
            break;
        }
    }
    
    NSLog(@"stateStr = %@", stateStr);
    
}

@end
