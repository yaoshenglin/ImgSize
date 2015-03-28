//
//  DB.m
//  AppCaidan
//
//  Created by zzx on 13-9-9.
//  Copyright (c) 2013年 zzx. All rights reserved.
//

#import "DB.h"
#import "Tools.h"
#import "CTB.h"

@implementation DB

static sqlite3 *db;
//建表
+ (void)open:(NSString *)fileName
{
    if(db) return;
    
    NSString *database_path = [Tools getFilePath:fileName];
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
        
        [CTB alertWithMessage:@"请删除本程序重新安装或者安装最新版本" Delegate:nil tag:1];
        NSLog(@"数据库打开失败");
        return;
    }
    
    [Tools addSkipBackupAttributeToItemAtFilePath:database_path];
}

+ (BOOL)execSql:(NSString *)sql name:(NSString *)tableName
{
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        NSLog(@"数据库操作失败:%@",sql);
        return NO;
    }
    return YES;
}

+ (sqlite3_stmt *)query:(NSString *)sql
{
    sqlite3_stmt *stmt;
    
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库查询数据失败,errorCode:%d,%@", result,sql);
    }
    
    return stmt;
}

//执行插入事务语句
+(void)execInsertTransactionSql:(NSArray *)listSQL
{
    //使用事务，提交插入sql语句
    @try{
        char *errorMsg;
        if (sqlite3_exec(db, "BEGIN", NULL, NULL, &errorMsg)==SQLITE_OK)
        {
            //NSLog(@"启动事务成功");
            sqlite3_free(errorMsg);
            sqlite3_stmt *stmt;
            for (int i = 0; i<listSQL.count; i++)
            {
                if (sqlite3_prepare_v2(db,[[listSQL objectAtIndex:i] UTF8String], -1, &stmt,NULL)==SQLITE_OK)
                {
                    if (sqlite3_step(stmt)!=SQLITE_DONE) sqlite3_finalize(stmt);
                }
            }
            if (sqlite3_exec(db, "COMMIT", NULL, NULL, &errorMsg)==SQLITE_OK)   NSLog(@"提交事务成功");
            sqlite3_free(errorMsg);
        }else {
            NSLog(@"%s",errorMsg);
            sqlite3_free(errorMsg);
        }
    }
    @catch(NSException *e)
    {
        char *errorMsg;
        if (sqlite3_exec(db, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)
        {
            //NSLog(@"回滚事务成功");
        }else{
            NSLog(@"回滚事务失败");
        }
        sqlite3_free(errorMsg);
    }
    @finally{}
}

#pragma mark - ========拿取数据=====================
+ (NSString *)getString:(sqlite3_stmt *)stmt index:(int)theIndex
{
    char *val = (char*)sqlite3_column_text(stmt, theIndex);
    if (val==NULL) {
        return NULL;
    }
    NSString *result = [[NSString alloc]initWithUTF8String:val];
    return result;
}

+ (int)getInt:(sqlite3_stmt *)stmt index:(int)theIndex
{
    int result = sqlite3_column_int(stmt, theIndex);
    return result;
}

+ (double)getDouble:(sqlite3_stmt *)stmt index:(int)theIndex
{
    double result = sqlite3_column_double(stmt, theIndex);
    return result;
}

+ (bool)getBoolean:(sqlite3_stmt *)stmt index:(int)theIndex
{
    NSString *str = [DB getString:stmt index:theIndex];
    BOOL result = [[str uppercaseString] isEqualToString:@"TRUE"] || [[str uppercaseString] isEqualToString:@"YES"] || [[str uppercaseString] isEqualToString:@"1"];
    return result;
}

+(NSInteger)getTotalRecord:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"select count(*) from %@",tableName];
    NSInteger count = [DB getAllTotalFrom:sql];
    return count;
}

+ (int)getAllTotalFrom:(NSString *)sql
{
    int count = 0;
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        
        if (sqlite3_step(stmt)) {
            count = sqlite3_column_int(stmt, 0);
        }
    }else{
        NSLog(@"数据库查询数据失败,errorCode:%d,%@", result,sql);
    }
    
    sqlite3_finalize(stmt);//释放资源
    return count;
}

+(void)addColumn:(NSString *)name type:(NSString *)type table:(NSString *)table
{
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@",name,table];
    sqlite3_stmt *stmt = [self query:sql];
    if (!stmt) {
        sql = [NSString stringWithFormat:@"alter table %@ add column %@ %@",table,name,type];
        if (![self execSql:sql name:table]) {
            NSLog(@"增加列'%@'失败",name);
        }
    }
    
    sqlite3_finalize(stmt);//释放资源
}

+(BOOL)deleteTable:(NSString *)tableName
{
    NSString *str = [NSString stringWithFormat:@"drop table %@",tableName];
    sqlite3_stmt *stmt=nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result != SQLITE_OK) {
        NSLog(@"删除数据库操作失败");
        return NO;
    }
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    return YES;
}

@end
