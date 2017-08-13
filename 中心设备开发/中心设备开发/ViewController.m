//
//  ViewController.m
//  中心设备开发
//
//  Created by Macx on 2017/8/13.
//  Copyright © 2017年 Macx. All rights reserved.
//

#import "ViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic,strong)CBCentralManager *manager;

@property (nonatomic,strong)CBPeripheral *peripheral;

@property (nonatomic,strong)CBCharacteristic *characteristic;

@property (weak, nonatomic) IBOutlet UITextField *infoTextField;

@end

#define SERVICE_UUID @"0xFFFE"

#define CHAR_UUID @"0xFFFF"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建中心设备
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];

}

#pragma mark - CBCentralManagerDelegate -

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBManagerStatePoweredOn)
    {
        // 扫描外设
        [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
        
    }
}

// 扫描到外设回调
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    // 数据持久化
    self.peripheral = peripheral;
    // 连接外设
    [central connectPeripheral:peripheral options:nil];
}

// 已经连接到外设的回调
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    // 扫描服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
    // 设置代理
    peripheral.delegate = self;
    
    
}
#pragma mark - CBPeripheralDelegate -
// 扫描到服务后的回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
   // 遍历服务对象,获取特征
    for (CBService *service in peripheral.services)
    {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHAR_UUID]] forService:service];
    }
}

// 扫描到特征之后的回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    // 将特征数据持久化,用于数据交互
    self.characteristic = service.characteristics.firstObject;
    
}
// 当特征上的数据发生变化后的回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    self.infoTextField.text = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
}


// 中心设备发送数据
- (IBAction)sendAction:(id)sender
{
    [self.peripheral writeValue:[self.infoTextField.text dataUsingEncoding:NSASCIIStringEncoding] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

// 中心设备接收数据
- (IBAction)receiveAction:(id)sender
{
    [self.peripheral readValueForCharacteristic:self.characteristic];
}

@end
