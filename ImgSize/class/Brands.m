//
//  Brands.m
//  iFace
//
//  Created by APPLE on 14-12-12.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "Brands.h"
//#import "Tools.h"
#import "CTB.h"

@implementation Brands

+ (Brands *)BindEntity:(NSDictionary *)json
{
    Brands *entity = [[Brands alloc] init];
    entity.brandname = [json objectForKey:@"brandname"];
    entity.model_q = [[json objectForKey:@"model_q"] intValue];
    entity.model_list = [json objectForKey:@"model_list"];
    
    return entity;
}

+ (NSArray *)BindList:(NSDictionary *)jsonDic
{
    NSMutableArray *list = [NSMutableArray array];
    NSArray *arr = [jsonDic objectForKey:@"data"];
    for (NSDictionary *dic in arr) {
        [list addObject:[self BindEntity:dic]];
    }
    return list;
}

#pragma mark -根据索引ID获取键值索引ID（p15000、p3000、p15公共方法）
+ (int)getKeyIndexWithID:(Enum_InfraedType)infraedType index:(int)preIndex
{
    NSString *tableName = varString(infraedType);
    NSArray *listName = @[@"P15",@"P3000",@"P15000"];
    if (![listName containsObject:tableName]) {
        tableName = nil;
    }
    
    if (!tableName) {
        return 0;
    }
    NSString *sql = [NSString stringWithFormat:@"select pid from %@ where id=%d",tableName,preIndex];
    sqlite3_stmt *stmt = [DB query:sql];
    
    int index = 0;
    if (stmt) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            index = [DB getInt:stmt index:0];
            break;
        }
    }
    
    sqlite3_finalize(stmt);
    
    return index;
}

#pragma mark - --------拿取所有品牌列表------------------------
+ (NSArray *)QueryAllBrands
{
    NSString *sql = @"select * from Brands";
    return [self QueryBrandsBySQL:sql];
}

#pragma mark 根据设备类型拿取
+ (NSArray *)QueryAllBrandsByDeviceID:(int)deviceID
{
    NSString *sql = [NSString format:@"select * from Brands where device_id = %d",deviceID];
    return [self QueryBrandsBySQL:sql];
}

+ (NSArray *)QueryBrandsBySQL:(NSString *)sql
{
    sqlite3_stmt *stmt = [DB query:sql];
    
    NSMutableArray *list = [NSMutableArray new];
    
    if (stmt) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            Brands *model = [Brands new];
            
            model.ID = [DB getInt:stmt index:0];
            model.device_id = [DB getInt:stmt index:1];
            model.brandname = [DB getString:stmt index:2];
            model.ebrandname = [DB getString:stmt index:3];
            model.model_q = [DB getInt:stmt index:4];
            model.model_list = [DB getString:stmt index:5];
            model.others = [DB getString:stmt index:6];
            
            [list addObject:model];
        }
    }
    
    sqlite3_finalize(stmt);
    
    return list;
}

+ (Brands *)QueryBrandsByID:(int)ID
{
    NSString *sql = [NSString stringWithFormat:@"select * from Brands where ID = %d",ID];
    sqlite3_stmt *stmt = [DB query:sql];
    
    Brands *model = [Brands new];
    
    if (stmt) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            model.ID = [DB getInt:stmt index:0];
            model.device_id = [DB getInt:stmt index:1];
            model.brandname = [DB getString:stmt index:2];
            model.ebrandname = [DB getString:stmt index:3];
            model.model_q = [DB getInt:stmt index:4];
            model.model_list = [DB getString:stmt index:5];
            model.others = [DB getString:stmt index:6];
        }
    }
    
    sqlite3_finalize(stmt);
    
    return model;
}

+ (NSString *)QueryDeviceNameByID:(int)ID
{
    NSString *sql = [NSString stringWithFormat:@"select device_name from device where ID = %d",ID];
    sqlite3_stmt *stmt = [DB query:sql];
    
    NSString *Name = @"";
    
    if (stmt) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            Name = [DB getString:stmt index:0];
        }
    }
    
    sqlite3_finalize(stmt);
    
    return Name;
}

#pragma mark 根据摇控器代号查找品牌
+ (Brands *)QueryBrandLikeMCode:(NSString *)m_code
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM brands WHERE device_id=1 AND model_list LIKE '%%%@,%%' LIMIT 1",m_code];
    sqlite3_stmt *stmt = [DB query:sql];
    
    Brands *model = [Brands new];
    
    if (stmt) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            model.ID = [DB getInt:stmt index:0];
            model.device_id = [DB getInt:stmt index:1];
            model.brandname = [DB getString:stmt index:2];
            model.ebrandname = [DB getString:stmt index:3];
            model.model_q = [DB getInt:stmt index:4];
            model.model_list = [DB getString:stmt index:5];
            model.others = [DB getString:stmt index:6];
        }
    }
    
    sqlite3_finalize(stmt);
    
    return model;
}

#pragma mark - --------其它----------------
+ (NSArray *)hotBrandsWith:(Enum_DownloadType)type
{
    if (type == DownloadType_AC) {
        return @[@"格力",@"美的",@"海尔",@"志高",@"海信",@"新科",@"奥克斯",@"春兰",@"格兰仕",@"松下",@"三菱",@"大金"];
    }
    else if (type == DownloadType_TV) {
        return @[@"长虹",@"康佳",@"创维",@"TCL",@"厦华",@"海信",@"海尔",@"索尼",@"东芝",@"三星",@"LG",@"乐视TV"];
    }
    else if (type == DownloadType_STB) {
        return nil;
    }
    
    return nil;
}

- (NSDictionary *)getPinyin
{
    if (_brandname.length <= 0) return nil;
    NSDictionary *result = @{};
    NSString *logogram = [_brandname phonetic];
    NSString *pinyin = replaceString(logogram, @" ", @"");
    
    logogram = replaceString(logogram, @"（", @"(");
    logogram = replaceString(logogram, @"）", @")");
    NSArray *array = [logogram componentSeparatedByString:@"("];
    if (array.count > 1) {
        logogram = array.firstObject;
    }
    
    NSArray *list = [logogram componentsSeparatedByString:@" "];
    NSString *shortPin = @"";
    if (list.count > 1) {
        for (NSString *str in list) {
            if (str.length > 0) {
                shortPin = [shortPin AppendString:str.firstString];
            }
        }
    }else{
        shortPin = logogram;
    }
    
    result = @{@"full":pinyin,
               @"short":shortPin};
    
    return result;
}

- (NSString *)getFullName
{
    NSString *result = _brandname;
    if (_ebrandname.length > 0) {
        result = [NSString format:@"%@(%@)",_brandname,_ebrandname];
    }
    
    return result;
}

@end
