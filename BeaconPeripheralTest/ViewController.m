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
#define MEASURED_POWER -59
// Beacon信号に含まれず、領域識別のための内部管理用の識別子
#define IDENTIFER @"info.maezono.beacontest"

@interface ViewController () <CBPeripheralManagerDelegate, UITextFieldDelegate>

@property(nonatomic, strong) NSUUID *proximityUUID;
@property(nonatomic, strong) CBPeripheralManager *peripheralManager;

@property (nonatomic, weak) IBOutlet UILabel *stateLabel;
@property (nonatomic, weak) IBOutlet UITextField *uuidTextField;
@property (nonatomic, weak) IBOutlet UITextField *majorNumTextField;
@property (nonatomic, weak) IBOutlet UITextField *minorNumTextField;
@property (nonatomic, weak) IBOutlet UIButton *startAdvertisingButton;
@property (nonatomic, weak) IBOutlet UIButton *stopAdvertisingButton;

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
    
    // 各信号の情報をテキストフィールドへ適用させる
    self.uuidTextField.text = UUID;
    self.majorNumTextField.text = [NSString stringWithFormat:@"%d", MAJOR];
    self.minorNumTextField.text = [NSString stringWithFormat:@"%d", MINOR];
    
    // 停止ボタン無効化
    self.stopAdvertisingButton.enabled = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startAdvertising
{
    NSLog(@"startAdvertising...");
    
    // 文字列をUUIDに変換
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:self.uuidTextField.text];
    
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID: uuid
                                                                           major: [self.majorNumTextField.text intValue]
                                                                           minor: [self.minorNumTextField.text intValue]
                                                                      identifier: IDENTIFER];
    
    NSLog(@"%@ - %d - %d", uuid, [self.majorNumTextField.text intValue], [self.minorNumTextField.text intValue]);
    
    NSDictionary *beaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    
    [self.peripheralManager  startAdvertising:beaconPeripheralData];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    
    if (error) {
        
        [self resetLabelAndTextFields];
        
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
            
            //[self startAdvertising];
            
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
    
    self.stateLabel.text = stateStr;
    
    NSLog(@"stateStr = %@", stateStr);
    
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // キーボードを隠す
    [self.view endEditing:YES];
    
    return YES;
}

#pragma mark - IBAction job

// アドバタイズ開始
-(IBAction)startAdvertising:(id)sender{
    
    // アドバタイズ開始処理
    // CBPeripheralManagerState の状態は Bluetoothの状態（電源のOn,Offやアプリケーションに実行権限があるかなど）を確認してくれる。
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        
        // 開始ボタン無効化
        self.startAdvertisingButton.enabled = NO;
        // 停止ボタン有効化
        self.stopAdvertisingButton.enabled = YES;
        
        [self startAdvertising];
    }
    
}

// アドバタイズ停止
-(IBAction)stopAdvertising:(id)sender{
    
    // アドバタイズ停止
    self.peripheralManager.delegate = nil;
    [self.peripheralManager stopAdvertising];
    [self resetLabelAndTextFields];
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:nil];
    
    // 開始ボタン有効化
    self.startAdvertisingButton.enabled = YES;
    // 停止ボタン無効化
    self.stopAdvertisingButton.enabled = NO;
    
}

#pragma mark -

- (void)resetLabelAndTextFields {
    
    self.stateLabel.text = @"---";
    self.uuidTextField.text = UUID;
    self.majorNumTextField.text = self.majorNumTextField.text;
    self.minorNumTextField.text = self.minorNumTextField.text;
    
}

@end
