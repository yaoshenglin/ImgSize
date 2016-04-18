//
//  Access.h
//  iFace
//
//  Created by Yin on 15-4-3.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumTypes.h"

enum {
    Room_Open = 0x21,
    UTF32LittleEndianStringEncoding = 0x9c000100        /* NSUTF32StringEncoding encoding with explicit endianness specified */
};
typedef NSUInteger NSRoomEncoding;

@interface Access : NSObject

@property (retain, nonatomic) NSString *msg;//信息代码
@property (retain, nonatomic) NSString *SN;//门系列号
@property (retain, nonatomic) NSString *PWD;//密码

@property (assign, nonatomic) Byte type;//分类
@property (assign, nonatomic) Byte commond;//命令
@property (assign, nonatomic) Byte parameter;//参数

@property (assign, nonatomic) int len;//分类
@property (retain, nonatomic) NSString *value;//命令

@property (assign, nonatomic) Byte *status;//门状态

//******************
@property (assign, nonatomic) int ID;//内部ID
@property (assign, nonatomic) NSInteger remoteID;//服务器数据库ID
@property (assign, nonatomic) int UserID; //用户ID
@property (assign, nonatomic) UInt16 port;//端口
@property (assign, nonatomic) int count;//数量

@property (retain, nonatomic) NSString *host;//主机
@property (retain, nonatomic) NSString *Name;//主机名
@property (retain, nonatomic) id userInfo;//主机
@property (assign, nonatomic) Enum_DataMark DataMark;//主机
//******************

#pragma mark - ----------数据库操作-------------------
#pragma mark 建表
+ (void)createTable;

#pragma mark 根据sql拿取数据
+ (NSArray *)selectBySql:(NSString *)sql;

#pragma mark 新增
+ (BOOL)insert:(Access *)entity;

#pragma mark 获取全部数据条数
+ (NSInteger)getTotal;

#pragma mark 获取全部数据
+ (NSArray *)getAll;

#pragma mark 根据情况获取数据
+ (NSArray *)getAllBy:(Enum_DataMark)mark;
#pragma mark 拿取设备类型信息
+ (NSArray *)getListAccess;
#pragma mark 根据SN拿取设备信息
+ (NSArray *)getAccessBySN:(NSString *)SN;

#pragma mark 更新数据
+ (BOOL)update:(Access *)entity;
#pragma mark 重置数据(更新主机时)
+ (void)reSetAllData;

#pragma mark 删除数据
+ (void)delete:(Access *)entity;
+ (void)deleteByID:(int)ID;
+ (void)deleteByMark:(Enum_DataMark)mark;
+ (void)deleteAll;

#pragma mark - ----------其它-------------------
+ (Access *)parseData:(NSData *)data;

- (void)parseData:(NSData *)data;
- (NSData *)getData;
- (int)getDoorCount;
- (Enum_DataMark)getDataMark;
- (void)handleUpdate;

@end
