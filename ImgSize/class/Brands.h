//
//  Brands.h
//  iFace
//
//  Created by APPLE on 14-12-12.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DB.h"
#import "EnumTypes.h"
#import "EnumInfraredType.h"

@interface Brands : NSObject

@property (nonatomic) NSInteger ID;//数据库ID
@property (nonatomic) NSInteger device_id;
@property (nonatomic) NSInteger model_q;//遥控型号数
@property (retain, nonatomic) NSString *brandname;//品牌名称
@property (retain, nonatomic) NSString *ebrandname;
@property (retain, nonatomic) NSString *model_list;//型号列表
@property (retain, nonatomic) NSString *others;

//********************
@property (retain, nonatomic) id userInfo;
//********************

+ (Brands *)BindEntity:(NSDictionary *)json;
+ (NSArray *)BindList:(NSDictionary *)jsonDic;

#pragma mark -根据索引ID获取键值索引ID（p15000、p3000、p15公共方法）
+ (int)getKeyIndexWithID:(Enum_InfraedType)infraedType index:(int)preIndex;;

#pragma mark - --------拿取所有品牌列表------------------------
+ (NSArray *)QueryAllBrands;
#pragma mark 根据设备类型拿取
+ (NSArray *)QueryAllBrandsByDeviceID:(int)deviceID;
+ (Brands *)QueryBrandsByID:(int)ID;//根据ID查询
#pragma mark 根据摇控器代号查找品牌
+ (Brands *)QueryBrandLikeMCode:(NSString *)m_code;
+ (NSString *)QueryDeviceNameByID:(int)ID;//根据ID查询类型名

#pragma mark - --------其它----------------
+ (NSArray *)hotBrandsWith:(Enum_DownloadType)type;
- (NSDictionary *)getPinyin;//获取名称的拼音
- (NSString *)getFullName;//完整名字(括号后面是英文名)

@end
