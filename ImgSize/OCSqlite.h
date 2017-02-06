//
//  OCSqlite.h
//  ImgSize
//
//  Created by xy on 2017/1/16.
//  Copyright © 2017年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

enum fieldtype
{
    ftInt,ftFloat,ftDouble,ftString,ftBlob,ftBool,ftDate,ftTime,ftDateTime,ftBinary
};

/*
 字段类
 作用：主要用于与数据库中的字段属性进行对应
 字段名，字段类型，字段值，字段索引号
 */
@interface OCField : NSObject
{
    NSString* fieldName;
    id fieldValue;
    enum fieldtype mtype;
    int seq_column;
}

-(NSString*)toString;
-(NSInteger)toInteger;
-(NSDate*)toDate;
-(NSString*)toDateString;
-(NSString*)toTimeString;
-(NSString*)toDateTimeString;
-(NSNumber*)toNumber;

-(enum fieldtype)getFieldType;

@property (nonatomic) int seq_column;

@end

/*
 数据集类
 作用：
 类似于数据源的集合，带游标，可访问数据源中的数据
 */
@interface OCDataset : NSObject
{
    NSMutableArray* records;
    NSInteger cursor;
}

-(void)clear;
-(NSInteger)count;
-(BOOL)next;
-(BOOL)first;
-(BOOL)move:(NSInteger) index;
-(OCField*)fieldbyname:(NSString*) fieldname;
-(OCField*)indexOffield:(NSInteger) index;

@end

@interface OCSqlite : NSObject
{
    sqlite3* db;
    OCDataset* dataset;
}

-(id)init;

-(BOOL)ConnectToDB:(NSString*) dbfilepath;
-(void)DisconnectDB;

-(BOOL)startTranslation;
-(BOOL)commitTranslation;
-(BOOL)rollbackTranslation;

-(BOOL)excesql:(NSString*) ddlsql;
-(BOOL)query:(NSString*) qysql;

@property (nonatomic,readonly) OCDataset* dataset;

@end
