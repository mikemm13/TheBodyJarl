//
//  ViewController.m
//  TheBodyJarl
//
//  Created by Miguel Martin Nieto on 11/07/14.
//  Copyright (c) 2014 ironhack. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>

#define ESTIMOTE_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"

#define VERDE_MAJOR 30201
#define VERDE_MINOR 31759

#define AZUL_MAJOR 8280
#define AZUL_MINOR 59820

#define MORADO_MAJOR 56395
#define MORADO_MINOR 11736

@interface ViewController () <CLLocationManagerDelegate, AVAudioPlayerDelegate, CBPeripheralManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startMonitoringBeacons:(id)sender {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([CLLocationManager isRangingAvailable]) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:ESTIMOTE_UUID];
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"estimotes"];
        [self.beaconRegion setNotifyEntryStateOnDisplay:YES];
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    if (state == CLRegionStateInside) {
        [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    } else {
        [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}



- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    for (CLBeacon *beacon in beacons) {
        NSLog(@"%@, %@, ", beacon.major, beacon.minor);
        if ([beacon.major intValue] == VERDE_MAJOR) {
            CLProximity proximity = beacon.proximity;
            switch (proximity) {
                case CLProximityFar:
                    [self playTheSoundWithName:@"Lucas"];
                    break;
                case CLProximityImmediate:
                    [self playTheSoundWithName:@"Ahorarl"];
                    break;
                case CLProximityNear:
                    [self playTheSoundWithName:@"Ioputarl"];
                    break;
                case CLProximityUnknown:
                    [self playTheSoundWithName:@"Iiihii"];
                    break;
                    
                default:
                    break;
            }
        }
    }
}

- (void)playTheSoundWithName:(NSString *)soundName{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
    NSError *err = nil;
    NSData *soundData = [[NSData alloc] initWithContentsOfFile:filePath options:NSDataReadingMapped error:&err];
    self.player = [[AVAudioPlayer alloc] initWithData:soundData error:&err];
    self.player.numberOfLoops = 0;
    self.player.delegate = self;
    [self.player play];
}

- (IBAction)createBeacon:(id)sender{

    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSLog(@"%d", self.peripheralManager.state);
    
    }


- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000001"];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:69 minor:1 identifier:@"miBeicon"];
    NSDictionary *peripheralData = [region peripheralDataWithMeasuredPower:nil];
    [self.peripheralManager startAdvertising:peripheralData];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

}

@end
