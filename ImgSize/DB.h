//
//  DB.h
//  AppCaidan
//
//  Created by zzx on 13-9-9.
//  Copyright (c) 2013年 zzx. All rights reserved.
//

#import <sqlite3.h>

@interface DB : NSObject {

}

+ (void)open:(NSString *)fileName;
+ (BOOL)execSql:(NSString *)sql name:(NSString *)tableName;
+ (sqlite3_stmt *)query:(NSString *)sql;

//执行插入事务语句
+(void)execInsertTransactionSql:(NSArray *)listSQL;

+ (NSString *)getString:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (int)getInt:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (double)getDouble:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (bool)getBoolean:(sqlite3_stmt *)stmt index:(int)theIndex;

+ (int)getAllTotalFrom:(NSString *)sql;
+(NSInteger)getTotalRecord:(NSString *)tableName;

//增加列
+(void)addColumn:(NSString *)name type:(NSString *)type table:(NSString *)table;

+(BOOL)deleteTable:(NSString *)tableName;//删除表


@end
