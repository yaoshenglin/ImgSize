//
//  Access.m
//  iFace
//
//  Created by Yin on 15-4-3.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import "Access.h"
#import "CTB.h"
#import "DB.h"

@implementation Access

+ (NSArray *)getAllKeys
{
    NSArray *listKey = @[@"ID",@"remoteID",@"count",@"SN",@"Name",@"PWD",@"host",@"port",@"DataMark"];
    return listKey;
}

#pragma mark - ----------数据库操作-------------------
#pragma mark 建表
+ (void)createTable
{
    //NSArray *listType = @[@"integer primary key",@"bool",@"bool",@"bool",@"text",@"text",@"integer"];
    NSDictionary *dicData = @{@"array":[self getAllKeys],
                              @"ID":@"integer primary key",
                              @"remoteID":@"integer",
                              @"count":@"integer",
                              @"SN":@"text",
                              @"Name":@"text",
                              @"PWD":@"text",
                              @"host":@"text",
                              @"port":@"integer",
                              @"DataMark":@"integer"};
    NSString *sql = [DB createSqlWith:dicData table:@"Access"];
    
    [DB execSql:sql];
    
    [DB CheckTableWith:sql table:@"Access"];
}

#pragma mark 根据sql拿取数据
+ (NSArray *)selectBySql:(NSString *)sql
{
    sqlite3_stmt *stmt = [DB query:sql];
    
    NSMutableArray *list = [NSMutableArray array];
    if (stmt) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            Access *entity = [[Access alloc] init];
            
            entity.ID = [DB getInt:stmt index:0];
            entity.remoteID = [DB getInt:stmt index:1];
            entity.count = [DB getInt:stmt index:2];
            
            entity.SN = [DB getString:stmt index:3];
            entity.Name = [DB getString:stmt index:4];
            entity.PWD = [DB getString:stmt index:5];
            entity.host = [DB getString:stmt index:6];
            entity.port = [DB getInt:stmt index:7];
            entity.DataMark = [DB getInt:stmt index:8];
            
            [list addObject:entity];
        }
    }
    
    sqlite3_finalize(stmt);//释放资源
    
    return list;
}

#pragma mark 新增
+ (BOOL)insert:(Access *)entity
{
    if (!entity)
        return NO;
    
    NSArray *listKey = [self getAllKeys];
    listKey = [listKey subarrayWithRange:NSMakeRange(1, listKey.count-1)];
    NSString *sql = [NSString stringWithFormat:@"insert into Access (%@) values (%@)",[DB getInsertColumnsWith:listKey],[DB getValueWith:listKey]];
    
    sqlite3_stmt *stmt = [DB query:sql];
    if (stmt) {
        bindInt(stmt, 1, entity.remoteID);
        bindInt(stmt, 2, entity.count);
        bindText(stmt, 3, entity.SN);
        bindText(stmt, 4, entity.Name);
        bindText(stmt, 5, entity.PWD);
        bindText(stmt, 6, entity.host);
        bindInt(stmt, 7, entity.port);
        bindInt(stmt, 8, entity.DataMark);
        
        sqlite3_step(stmt);
    }
    
    sqlite3_finalize(stmt);
    
    return YES;
}

#pragma mark 获取全部数据条数
+ (NSInteger)getTotal
{
    NSInteger count = [DB getTotalByTable:@"Access"];
    return count;
}

#pragma mark 获取全部数据
+ (NSArray *)getAll
{
    NSString *sql = [NSString stringWithFormat:@"select * from Access"];
    NSArray *list = [Access selectBySql:sql];
    return list;
}

#pragma mark 根据情况获取数据
+ (NSArray *)getAllBy:(Enum_DataMark)mark
{
    NSString *sql = [NSString stringWithFormat:@"select * from Access where DataMark=%d",mark];
    NSArray *list = [Access selectBySql:sql];
    return list;
}

#pragma mark 拿取有效设备信息
+ (NSArray *)getListAccess
{
    NSString *sql = [NSString stringWithFormat:@"select * from Access where DataMark != %d",DataMark_Delete];
    NSArray *list = [Access selectBySql:sql];
    return list;
}

#pragma mark 根据SN拿取设备信息
+ (NSArray *)getAccessBySN:(NSString *)SN
{
    NSString *sql = [NSString stringWithFormat:@"select * from Access where SN = '%@'",SN];
    NSArray *list = [Access selectBySql:sql];
    return list;
}

#pragma mark 更新数据
+ (BOOL)update:(Access *)entity
{
    if (!entity) return NO;
    
    NSArray *listKey = [self getAllKeys];
    listKey = [listKey subarrayWithRange:NSMakeRange(1, listKey.count-1)];
    NSString *sql = [NSString stringWithFormat:@"update Access set %@ where ID = %d",[DB getUpdateColumnsWith:listKey],entity.ID];
    sqlite3_stmt *stmt = [DB query:sql];
    if (stmt) {
        bindInt(stmt, 1, entity.remoteID);
        bindInt(stmt, 2, entity.count);
        bindText(stmt, 3, entity.SN);
        bindText(stmt, 4, entity.Name);
        bindText(stmt, 5, entity.PWD);
        bindText(stmt, 6, entity.host);
        bindInt(stmt, 7, entity.port);
        bindInt(stmt, 8, entity.DataMark);
        
        int result = sqlite3_step(stmt);
        if(result==SQLITE_ERROR)//执行update动作
        {
            NSLog(@"update error");
        }
    }
    
    sqlite3_finalize(stmt);
    
    return YES;
}

+ (void)reSetAllData
{
    NSArray *listAll = [self getAll];
    for (Access *access in listAll) {
        if (access.DataMark == DataMark_Delete) {
            [Access delete:access];
        }else{
            access.DataMark = DataMark_Add;
            [Access update:access];
        }
    }
}

#pragma mark 删除数据
+ (void)delete:(Access *)entity
{
    if (!entity) return;
    
    NSString *sql = [NSString stringWithFormat:@"delete from Access where ID = %d", entity.ID];
    
    [DB execSql:sql];
}

+ (void)deleteByID:(int)ID
{
    NSString *sql = [NSString stringWithFormat:@"delete from Access where ID = %d", ID];
    
    [DB execSql:sql];
}

+ (void)deleteByMark:(Enum_DataMark)mark
{
    NSString *sql = [NSString stringWithFormat:@"delete from Access where DataMark = %d", mark];
    
    [DB execSql:sql];
}

+ (void)deleteAll
{
    NSString *sql = @"delete from Access";
    
    [DB execSql:sql];
}

#pragma mark - ----------其它-------------------
- (instancetype)init
{
    if (self = [super init]) {
        Byte byte[4] = {0x00,0x00,0x00,0x00};
        _status = byte;
        _SN = @"";
        _PWD = @"";
    }
    
    return self;
}

- (void)parseData:(NSData *)data
{
    if (!data) {
        return;
    }
    
    Byte *gBuffer = (Byte *)[data bytes];
    Byte b = gBuffer[0];
    
    if (b != 0x7e || b != gBuffer[data.length-1]) {
        return;
    }
    
    NSData *dataSN = [data subdataWithRange:NSMakeRange(5, 16)];
    NSString *SN = [dataSN stringUsingEncode:NSASCIIStringEncoding];
    if (SN.length != 16) {
        return;
    }
    
    _msg = [data stringWithRange:NSMakeRange(1, 4)];
    _SN = SN;
    _PWD = [data stringWithRange:NSMakeRange(21, 4)].description;
    
    _type = gBuffer[25];
    _commond = gBuffer[26];
    _parameter = gBuffer[27];
    
    NSString *lenString = [data stringWithRange:NSMakeRange(28, 4)];
    char *errMsg;
    _len = strtoul([lenString UTF8String],&errMsg,16);
    _value = [data stringWithRange:NSMakeRange(32, _len)];
    
    if (strlen(errMsg)) {
        NSLog(@"lenString : %@",lenString);
    }
    
    BOOL isStatus = _type == 0x31 && _commond == 0x0e && _parameter == 0x00;
    if (_len >= 4 && isStatus) {
        _status = (Byte *)[[data subdataWithRange:NSMakeRange(40, 4)] bytes];
        //继电器状态
        Byte *relayStatus = (Byte *)[[data subdataWithRange:NSMakeRange(49, 8)] bytes];
        if (relayStatus[0] == 0x01) {
            NSLog(@"门1继电器开");
        }else{
            NSLog(@"门1继电器关");
        }
        
        if (relayStatus[1] == 0x01) {
            NSLog(@"门2继电器开");
        }else{
            NSLog(@"门2继电器关");
        }
    }
}

+ (Access *)parseData:(NSData *)data
{
    Access *door = [[Access alloc] init];
    [door parseData:data];
    
    if (!door.SN) {
        return nil;
    }
    
    return door;
}

- (NSData *)getData
{
    NSDictionary *dic = @{@"Name":_Name,
                          @"Count":@(_count),
                          @"IP":_host,
                          @"Port":@(_port),
                          @"PWD":_PWD};
    NSData *data = [dic archivedData];
    return data;
}

- (int)getDoorCount
{
    int num = 0;
    if (_SN.length < 6) {
        return num;
    }
    
    //"KF-9020T20921083"
    
    num = [[_SN substringWithRange:NSMakeRange(5, 1)] intValue];
    
    return num;
}

- (Enum_DataMark)getDataMark
{
    if (_remoteID == 0) {
        return DataMark_Add;
    }
    
    return _DataMark;
}

- (void)handleUpdate
{
    if (self.DataMark != DataMark_Delete) {
        if (_remoteID <= 0) return;
        self.DataMark = DataMark_None;
        [Access update:self];
    }
    else if (self.DataMark == DataMark_Delete) {
        [Access delete:self];
    }
}

@end
