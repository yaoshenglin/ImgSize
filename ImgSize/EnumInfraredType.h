//
//  EnumInfraredType.h
//  iFace
//
//  Created by vvxt on 12-15-14.
//  Copyright (c) 2013年 vvxt. All rights reserved.
//

//PS：以下枚举索引值不能变更！

//开关（2）： 0=开，1=关
//运转模式（5）： 0=自动 ，1=制冷， 2=除湿， 3=送风， 4=制热
//温度（15）： 16-30度  0=16 。。。。 14=30
//风速（4）： 0=自动，1=风速1，2=风速2，3=风速3
//风向（5）： 0=自动，1=风向1，2=风向2，3=风向3，4=风向4
//键值（5）： 0=开关，1=运转模式，2=温度，3=风量，4=风向

#import <Foundation/Foundation.h>

#pragma mark 开和关
typedef NS_ENUM(NSInteger, Enum_OnOff) {
    Close   = 0,
    Open    = 1
};

#pragma mark 5种运转模式
typedef NS_ENUM(NSInteger, Enum_RunMode) {
    RunModeAuto = 0,
    Cold = 1,
    Wet = 2,
    Wind = 3,
    Hot = 4
};

#pragma mark 16-30度
typedef NS_ENUM(NSInteger, Enum_Temperature) {
    T16 = 0,
    T17 = 1,
    T18 = 2,
    T19 = 3,
    T20 = 4,
    T21 = 5,
    T22 = 6,
    T23 = 7,
    T24 = 8,
    T25 = 9,
    T26 = 10,
    T27 = 11,
    T28 = 12,
    T29 = 13,
    T30 = 14
};

#pragma mark 4种风速
typedef NS_ENUM(NSInteger, Enum_WindSpeed) {
    SpeedAuto = 0,
    Speed1 = 1,
    Speed2 = 2,
    Speed3 = 3
};

#pragma mark 5种风向
typedef NS_ENUM(NSInteger, Enum_WindDirection) {
    DirectionAuto = 0,
    Direction1 = 1,
    Direction2 = 2,
    Direction3 = 3,
    Direction4 = 4
};

#pragma mark 5种键值
typedef NS_ENUM(NSInteger, Enum_Keys) {
    KeysAuto = 0,
    RunMode = 1,
    Temperature = 2,
    WindSpeed = 3,
    WindDirection = 4
};

#pragma mark 红外类型枚举值
typedef NS_ENUM(NSInteger, Enum_InfraedType) {
    P15000 = 0,
    P3000 = 1,
    P15 = 2
};