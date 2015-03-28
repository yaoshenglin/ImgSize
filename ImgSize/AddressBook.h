//
//  AddressBook.h
//  iPhonAddressList
//
//  Created by Yinhaibo on 14-1-8.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AddressBook : NSObject<UIAlertViewDelegate>

@property (nonatomic) int ContactID;
@property (retain,nonatomic) NSString *surname;//姓氏
@property (retain,nonatomic) NSString *midname;//
@property (retain,nonatomic) NSString *name;//名字
@property (retain,nonatomic) NSString *fullName;//完整名字
@property (retain,nonatomic) NSString *company;//公司
@property (retain,nonatomic) NSArray *telePhone;//电话(可能存在多个,有可能是固话、小灵通等)
@property (retain,nonatomic) NSArray *homePage;//主页
@property (retain,nonatomic) NSArray *email;//电子邮件
@property (retain,nonatomic) NSString *birthday;//生日
@property (retain,nonatomic) NSString *note;//备注
@property (retain,nonatomic) NSString *nickname;//呢称
@property (retain,nonatomic) NSString *job;//职务
@property (retain,nonatomic) NSString *department;//部门
@property (retain,nonatomic) NSString *address;//

//mobile.length==0,说明该好友的telePhone中不存在可用的手机号码
@property (retain, nonatomic) NSString *mobile;//自定义的(可用手机号码)

+(ABAddressBookRef)getAddressBookRef;
+(NSArray *)getDataFromAddressBook;//获取全部联系人
+(AddressBook *)getPersonDataBy:(ABRecordRef)person;

+(void)createTable;
#pragma mark 新增
+ (BOOL)insert:(AddressBook *)entity;;
#pragma mark 更新数据
+ (void)update:(AddressBook *)entity;
#pragma mark 删除数据
+ (void)deleteRecord:(NSInteger)ContactID;

#pragma mark 重置数据库
+(void)ReplacementAddressBook:(NSArray *)arrData;

+(NSString *)getNameByMobile:(NSString *)mobile;
#pragma mark 拿取全部
+(NSArray *)selectAll;
+(NSMutableDictionary *)selectContactIdLists;

+(void)checkSameAddressBook;

+(void)FirstUpdateTable;

#pragma mark 根据手机号码拿取ContactID
+(NSInteger)getContactIDByMobile:(NSString *)mobile;
+(NSInteger)getContactIDByMobile:(NSString *)mobile from:(NSArray *)list;

+ (AddressBook *)selectByID:(int)ContactID;
+ (AddressBook *)selectByMobile:(NSString *)mobile;
+(AddressBook *)selectByMobile:(NSString *)mobile from:(NSArray *)list;
+ (NSArray *)selectByName:(NSString *)name;

/*
 以下方法是直接从通讯中操作,而不是从本地数据库中操作
 */
#pragma mark - ========添加联系人========================
+(ABRecordRef)AddContactsWithFirstName:(NSString *)firstName
                       lastName:(NSString *)lastName
                         mobile:(NSDictionary *)mobile
                       nickname:(NSString *)nickname
                       birthday:(NSDate *)birthday;
+(void)AddContactsWithPerson:(ABRecordRef)person to:(ABAddressBookRef)addressBook;
#pragma mark 删除联系人(根据全名)
+(void)deleteContactsWithFullName:(NSString *)fullName;
+(void)deleteContactsWithPartName:(NSString *)partName;
+(void)deleteContactsWithFullName:(NSString *)fullName from:(NSMutableArray *)list;
#pragma mark 删除联系人(根据电话)
+(void)deleteContactsWithTel:(NSString *)phone;

@end
