//
//  DB.h
//  AppCaidan
//
//  Created by zzx on 13-9-9.
//  Copyright (c) 2013年 zzx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface DB : NSObject {

}

+ (sqlite3 *)getDB;
+ (void)open:(NSString *)fileName;
+ (sqlite3 *)openFromPath:(NSString *)path;
+ (void)close;

#pragma mark - 拼接建表语句
+ (NSString *)createSqlWithKey:(NSArray *)listKey Type:(NSArray *)listType table:(NSString *)tableName;
+ (NSString *)createSqlWith:(NSDictionary *)dicData table:(NSString *)tableName;
#pragma mark 拼接列名字(逗号隔开)
+ (NSString *)getInsertColumnsWith:(NSArray *)list;
+ (NSString *)getUpdateColumnsWith:(NSArray *)list;
#pragma mark 拼接值域(?)
+ (NSString *)getValueWith:(NSArray *)list;
+ (BOOL)execSql:(NSString *)sql;
+ (BOOL)CheckTableWith:(NSString *)sql table:(NSString *)tableName;
//+ (BOOL)execSql:(NSString *)sql name:(NSString *)tableName;
+ (sqlite3_stmt *)query:(NSString *)sql;
+ (BOOL)checkColumn:(NSString *)name table:(NSString *)table;

+(NSString *)getDBFileNameByHost:(NSString *)host;

+(NSString *)setInsertSql:(NSArray *)list to:(NSString *)table1 from:(NSString *)table2;

//执行插入事务语句
+(void)execInsertTransactionSql:(NSArray *)listSQL;

#pragma mark - --------数据库事务操作-------------------
int beginTransaction(void);
int commitTransaction(void);
int rollbackTransaction(void);

#pragma mark - --------绑定数据--------------------
int bindInt(sqlite3_stmt *stmt,int loc,int value);
int bindDouble(sqlite3_stmt *stmt,int loc,double value);
int bindText(sqlite3_stmt *stmt,int loc,NSString *value);
int bindBlob(sqlite3_stmt *stmt,int loc,NSData *data);
+ (void)bindData:(NSDictionary *)dic stmt:(sqlite3_stmt *)stmt;

#pragma mark - --------拿取数据--------------------
+ (NSString *)getString:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (int)getInt:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (long)getLong:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (double)getDouble:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (bool)getBoolean:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (NSData *)getData:(sqlite3_stmt *)stmt index:(int)theIndex;

+(NSInteger)getTotalByTable:(NSString *)tableName;
+ (int)getTotalBySql:(NSString *)sql;

#pragma mark 增加列
+(void)addColumnWith:(NSArray *)array table:(NSString *)table;
+(void)addColumn:(NSString *)name type:(NSString *)type table:(NSString *)table;

+(BOOL)deleteTable:(NSString *)tableName;//删除表
+ (BOOL)deleteAllData:(NSString *)tableName;//删除表中全部数据
+(BOOL)rename:(NSString *)aTable to:(NSString *)bTable;

#pragma mark 根据sql语句获取所有列名
+(NSArray *)getColumnBy:(NSString *)sql from:(NSString *)tableName;
#pragma mark 根据表名,列数据生成建表语句
//列对象:@{@"cid":@(0),@"name":@"column",@"type":@"integer"}
+ (NSString *)getCreateSql:(NSString *)table columns:(NSArray *)listColumns;
#pragma mark 根据已存在表查询建表语句
+ (NSString *)getCreateSql:(NSString *)table;
#pragma mark 查询所有列
+(NSArray *) GetAllColumnFrom:(NSString*)TableName;
#pragma mark 检查列是否存在
+(BOOL) CheckColumn:(NSString*)TableName ColumnName:(NSString*) ColumnName;
#pragma mark 检查表是否存在
+(BOOL)CheckTable:(NSString*)TableName;
#pragma mark 获取所有的表名
+(NSArray*)GetAllTable;
#pragma mark 查询所有表建表语句
+ (NSDictionary *)getAllTableSQL;

#pragma mark 将路径path中的表插入到路径path1数据库中
+ (void)insertToPath:(NSString *)path1 from:(NSString *)path;

@end

@interface NSString (NSString)

- (BOOL)isBelong:(NSString *)string;

@end
