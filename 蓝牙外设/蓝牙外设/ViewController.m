//
//  ViewController.m
//  蓝牙外设
//
//  Created by Macx on 2017/8/13.
//  Copyright © 2017年 Macx. All rights reserved.
//

#import "ViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBPeripheralManagerDelegate>

@property (nonatomic,strong)CBPeripheralManager *manager;

@property (weak, nonatomic) IBOutlet UITextField *infoTextField;

@end

#define SERVICE_UUID @"0xFFFE"

#define CHAR_UUID @"0xFFFF"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 建立外设管理器（CBPeripheralManager）
    self.manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    
}

#pragma mark  -CBPeripheralManagerDelegate -

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    /*
     CBManagerStateUnknown = 0, //未知
     CBManagerStateResetting,   //重置
     CBManagerStateUnsupported, //不支持
     CBManagerStateUnauthorized,//未授权
     CBManagerStatePoweredOff,  //关机
     CBManagerStatePoweredOn,   //开机,正常状态
     */
    if (peripheral.state == CBManagerStatePoweredOn)
    {
        // 创建服务和特征
        CBUUID *serviceUUID = [CBUUID UUIDWithString:SERVICE_UUID];
        
        CBMutableService *service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
        
        CBUUID *charUUID = [CBUUID UUIDWithString:CHAR_UUID];
        
        CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc]
                                                   initWithType:charUUID
                                                   properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite
                                                   value:nil
                                                   permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable ];
        
        // 将服务和特征绑定
        service.characteristics = @[characteristic];
        
        //将服务放到外设中
        [peripheral addService:service];
        
        // 开始广播
        [peripheral startAdvertising:@{
                                       CBAdvertisementDataServiceUUIDsKey:@[serviceUUID]
                                       }];
    }
    
}

// 中心设备向外设 读取 数据回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    request.value = [self.infoTextField.text dataUsingEncoding:NSASCIIStringEncoding];
    
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}
// 中心设备向外设 发送 数据回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    self.infoTextField.text = [[NSString alloc] initWithData:requests.firstObject.value encoding:NSASCIIStringEncoding];
}


@end
