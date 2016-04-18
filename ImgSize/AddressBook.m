//
//  AddressBook.m
//  iPhonAddressList
//
//  Created by Yinhaibo on 14-1-8.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import "AddressBook.h"
#import "DB.h"
#import "CTB.h"
#import "Tools.h"

@implementation AddressBook

- (id)init
{
    self = [super init];
    if (self) {
        self.mobile = @"";
        self.fullName = @"";
    }
    
    return self;
}

+(ABAddressBookRef)getAddressBookRef
{
    // 初始化并创建通讯录对象，记得释放内存
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    //等待同意后向下执行
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 dispatch_semaphore_signal(sema);
                                             });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    if (addressBook==NULL) {
        [CTB showMsg:@"请在\"设置\"->\"隐私\"->\"通讯录\"中开启访问权限"];
        return NULL;
    }
    return addressBook;
}

#pragma mark - ==========获取通讯录列表======================
+(NSArray *)getDataFromAddressBook
{
    NSMutableArray *arrayData = nil;
    
    //取得本地通信录名柄
    ABAddressBookRef tmpAddressBook =  [self getAddressBookRef];
    if (!tmpAddressBook) {
        return NULL;
    }
    
    //取得本地所有联系人记录
    NSArray* tmpPeoples = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
    
    if (tmpPeoples.count>0) {
        arrayData = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    for(int i=0; i<tmpPeoples.count; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex((__bridge CFArrayRef)(tmpPeoples), i);
        
        AddressBook *contacts = [self getPersonDataBy:person];
        
        BOOL hasMobile = NO;
        if (contacts.mobile.length > 0) {
            hasMobile = YES;
        }
        
        if (hasMobile)
            [arrayData addObject:contacts];
        
    }
    
    //释放内存
    CFRelease(tmpAddressBook);
    
    return arrayData;
}

+(AddressBook *)getPersonDataBy:(ABRecordRef)person
{
    AddressBook *contacts = [[AddressBook alloc] init];
    
    //获取通讯录联系人ID
    contacts.ContactID = ABRecordGetRecordID(person);
    
    //获取的联系人单一属性:姓氏
    contacts.surname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    contacts.midname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    
    //获取的联系人单一属性:名字
    contacts.name = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    contacts.surname = contacts.surname ?: @"";
    contacts.midname = contacts.midname ?: @"";
    contacts.name = contacts.name ?: @"";
    contacts.fullName = [NSString stringWithFormat:@"%@%@%@",contacts.surname,contacts.midname,contacts.name];
    //NSLog(@"name:%@",contacts.fullName);
    
    //获取的联系人单一属性:呢称
    contacts.nickname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNicknameProperty);
    
    //获取的联系人单一属性:公司
    contacts.company = (__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
    
    //获取的联系人单一属性:职务
    contacts.job = (__bridge NSString*)ABRecordCopyValue(person, kABPersonJobTitleProperty);
    
    //获取的联系人单一属性:部门
    contacts.department = (__bridge NSString*)ABRecordCopyValue(person, kABPersonDepartmentProperty);
    
    NSArray *arrayAddress = [self ParseDataRef:person ID:kABPersonAddressProperty];
    NSDictionary *dicAddress = [arrayAddress firstObject];
    contacts.address = [NSString stringWithFormat:@"%@%@%@",[dicAddress objectForKey:@"State"],[dicAddress objectForKey:@"City"],[dicAddress objectForKey:@"Street"]];
    
    //获取的联系人多种属性:主页
    contacts.homePage = [self ParseDataRef:person ID:kABPersonURLProperty];
    
    //获取的联系人单一属性:电子邮件
    contacts.email = [self ParseDataRef:person ID:kABPersonEmailProperty];
    
    //获取的联系人单一属性:生日
    NSDate* tmpBirthday = (__bridge NSDate*)ABRecordCopyValue(person, kABPersonBirthdayProperty);
    contacts.birthday = [self getSystemDate:tmpBirthday];
    
    //获取的联系人单一属性:备注
    contacts.note = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNoteProperty);
    
    //获取的联系人单一属性:电话
    contacts.telePhone = [self ParseDataRef:person ID:kABPersonPhoneProperty];
    
    for (NSString *mobile in contacts.telePhone) {
        if ([CTB isMobile:mobile] && mobile.length>0) {
            contacts.mobile = mobile;
            break;
        }
    }
    
    CFRelease(person);
    
    return contacts;
}

#pragma mark - ========添加联系人========================
+(ABRecordRef)AddContactsWithFirstName:(NSString *)firstName
                       lastName:(NSString *)lastName
                         mobile:(NSDictionary *)mobile
                       nickname:(NSString *)nickname
                       birthday:(NSDate *)birthday
{
    // 新建一个联系人
    // ABRecordRef是一个属性的集合，相当于通讯录中联系人的对象
    // 联系人对象的属性分为两种：
    // 只拥有唯一值的属性和多值的属性。
    // 唯一值的属性包括：姓氏、名字、生日等。
    // 多值的属性包括:电话号码、邮箱等。
    ABRecordRef person = ABPersonCreate();
    birthday = birthday ? birthday : [NSDate date];
    // 电话号码对应的名称
    NSMutableArray *labels = [NSMutableArray arrayWithArray:[mobile allKeys]];
    labels = labels.count>0 ? labels : [NSMutableArray arrayWithObjects:@"iphone",@"home",nil];
    // 电话号码数组
    NSMutableArray *phones = [NSMutableArray array];
    for (NSString *key in labels) {
        [phones addObject:[mobile objectForKey:key]];
    }
    // 保存到联系人对象中，每个属性都对应一个宏，例如：kABPersonFirstNameProperty
    // 设置firstName属性
    ABRecordSetValue(person, kABPersonFirstNameProperty,(__bridge CFStringRef)firstName, NULL);
    // 设置lastName属性
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFStringRef)lastName, NULL);
    // 设置birthday属性
    ABRecordSetValue(person, kABPersonBirthdayProperty,(__bridge CFDateRef)birthday, NULL);
    // ABMultiValueRef类似是Objective-C中的NSMutableDictionary
    ABMultiValueRef mv =ABMultiValueCreateMutable(kABMultiStringPropertyType);
    // 添加电话号码与其对应的名称内容
    for (int i = 0; i < [phones count]; i ++) {
        ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(mv,(__bridge CFStringRef)[phones objectAtIndex:i], (__bridge CFStringRef)[labels objectAtIndex:i], &mi);
    }
    // 设置phone属性
    ABRecordSetValue(person, kABPersonPhoneProperty, mv, NULL);
    // 释放该数组
    if (mv) {
        CFRelease(mv);
    }
    
    return person;
}

+(void)AddContactsWithPerson:(ABRecordRef)person to:(ABAddressBookRef)addressBook
{
    // 初始化一个ABAddressBookRef对象，使用完之后需要进行释放，
    // 这里使用CFRelease进行释放
    // 相当于通讯录的一个引用
    //ABAddressBookRef addressBook = [self getAddressBookRef];
    if (!addressBook) {
        return;
    }
    
    // 将新建的联系人添加到通讯录中
    ABAddressBookAddRecord(addressBook, person, NULL);
}

#pragma mark - ========删除联系人(根据全名)========================
+(void)deleteContactsWithFullName:(NSString *)fullName
{
    // 初始化并创建通讯录对象，记得释放内存
    ABAddressBookRef addressBook = [self getAddressBookRef];
    if (!addressBook) {
        return;
    }
    
    // 获取通讯录中所有的联系人
    NSArray *array = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    // 遍历所有的联系人并删除(这里只删除姓名为张三的)
    for (id obj in array) {
        ABRecordRef people = (__bridge ABRecordRef)obj;
        //获取的联系人单一属性:姓氏(国外习惯将姓氏放在后面)
        NSString *last = (__bridge NSString*)ABRecordCopyValue(people, kABPersonLastNameProperty);
        
        NSString *midname = (__bridge NSString*)ABRecordCopyValue(people, kABPersonMiddleNameProperty);
        
        //获取的联系人单一属性:名字
        NSString *first = (__bridge NSString*)ABRecordCopyValue(people, kABPersonFirstNameProperty);
        
        last = last ?: @"";
        midname = midname ?: @"";
        first = first ?: @"";
        NSString *all = [NSString stringWithFormat:@"%@%@%@",last,midname,first];
        if ([all isEqualToString:fullName]) {
            ABAddressBookRemoveRecord(addressBook, people,NULL);
            [CTB showMsg:@"删除好友成功"];
        }
        
        CFRelease(people);
    }
    
    // 保存修改的通讯录对象
    ABAddressBookSave(addressBook, NULL);
    // 释放通讯录对象的内存
    CFRelease(addressBook);
}

+(void)deleteContactsWithPartName:(NSString *)partName
{
    // 初始化并创建通讯录对象，记得释放内存
    ABAddressBookRef addressBook = [self getAddressBookRef];
    if (!addressBook) {
        return;
    }
    
    // 获取通讯录中所有的联系人
    NSArray *array = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    // 遍历所有的联系人并删除(这里只删除姓名为张三的)
    for (id obj in array) {
        ABRecordRef people = (__bridge ABRecordRef)obj;
        //获取的联系人单一属性:姓氏(国外习惯将姓氏放在后面)
        NSString *last = (__bridge NSString*)ABRecordCopyValue(people, kABPersonLastNameProperty);
        
        NSString *midname = (__bridge NSString*)ABRecordCopyValue(people, kABPersonMiddleNameProperty);
        
        //获取的联系人单一属性:名字
        NSString *first = (__bridge NSString*)ABRecordCopyValue(people, kABPersonFirstNameProperty);
        
        last = last ?: @"";
        midname = midname ?: @"";
        first = first ?: @"";
        NSString *all = [NSString stringWithFormat:@"%@%@%@",last,midname,first];
        if ([all hasPrefix:partName]) {
            ABAddressBookRemoveRecord(addressBook, people,NULL);
        }
        
        CFRelease(people);
    }
    
    // 保存修改的通讯录对象
    ABAddressBookSave(addressBook, NULL);
    // 释放通讯录对象的内存
    CFRelease(addressBook);
}

+(void)deleteContactsWithFullName:(NSString *)fullName from:(NSMutableArray *)list
{
    AddressBook *result = nil;
    for (AddressBook *book in list) {
        if ([book.fullName isEqualToString:fullName]) {
            result = book;
            break;
        }
    }
    
    [list removeObject:result];
}

#pragma mark 删除联系人(根据电话)
+(void)deleteContactsWithTel:(NSString *)phone
{
    // 初始化并创建通讯录对象，记得释放内存
    ABAddressBookRef addressBook = [self getAddressBookRef];
    if (!addressBook) {
        return;
    }
    
    // 获取通讯录中所有的联系人
    NSArray *array = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    // 遍历所有的联系人并删除(这里只删除姓名为张三的)
    for (id obj in array) {
        ABRecordRef people = (__bridge ABRecordRef)obj;
        
        BOOL isExist = NO;
        NSArray *listPhone = [self ParseDataRef:people ID:kABPersonPhoneProperty];
        for (NSString *mobile in listPhone) {
            if ([mobile isEqualToString:phone]) {
                isExist = YES;
                break;
            }
        }
        
        if (isExist) {
            ABAddressBookRemoveRecord(addressBook, people,NULL);
            [CTB showMsg:@"删除好友成功"];
        }
        
        CFRelease(people);
    }
    
    // 保存修改的通讯录对象
    ABAddressBookSave(addressBook, NULL);
    // 释放通讯录对象的内存
    CFRelease(addressBook);
}

#pragma mark - ========更新联系人========================
+ (void)updateAddressBookPersonWithFirstName:(NSString *)firstName
                                    lastName:(NSString *)lastName
                                      mobile:(NSString *)mobile
                                    nickname:(NSString *)nickname
                                    birthday:(NSDate *)birthday
{
    // 初始化并创建通讯录对象，记得释放内存
    ABAddressBookRef addressBook = [self getAddressBookRef];
    if (!addressBook) {
        return;
    }
    // 获取通讯录中所有的联系人
    NSArray *array = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    // 遍历所有的联系人并修改指定的联系人
    for (id obj in array) {
        ABRecordRef people = (__bridge ABRecordRef)obj;
        NSString *fn = (__bridge NSString*)ABRecordCopyValue(people, kABPersonFirstNameProperty);
        NSString *ln = (__bridge NSString*)ABRecordCopyValue(people, kABPersonLastNameProperty);
        //NSLog(@"%@,%@",fn,ln);
        ABMultiValueRef mv = ABRecordCopyValue(people,kABPersonPhoneProperty);
        NSArray *phones = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(mv);
        // firstName同时为空或者firstName相等
        BOOL ff = ([fn length] == 0 && [firstName length] == 0) || ([fn isEqualToString:firstName]);
        // lastName同时为空或者lastName相等
        BOOL lf = ([ln length] == 0 && [lastName length] == 0) || ([ln isEqualToString:lastName]);
        // 由于获得到的电话号码不符合标准，所以要先将其格式化再比较是否存在
        BOOL is = NO;
        for (NSString *p in phones) {
            //红色代码处，我添加了一个类别（给NSString扩展了一个方法），该类别的这个方法主要是用于将电话号码中的"("、")"、""、"-"过滤掉
            NSString *result = [p stringByReplacingOccurrencesOfString:@"、" withString:@""];
            result = [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
            if ([result isEqualToString:mobile]) {
                is = YES;
                break;
            }
        }
        // firstName、lastName、mobile 同时存在进行修改
        if (ff && lf && is) {
            if ([nickname length] > 0) {
                ABRecordSetValue(people,kABPersonNicknameProperty, (__bridge CFStringRef)nickname, NULL);
            }
            if (birthday != nil) {
                ABRecordSetValue(people,kABPersonBirthdayProperty, (__bridge CFTypeRef)(birthday), NULL);
            }
        }
        
    }
    // 保存修改的通讯录对象
    ABAddressBookSave(addressBook, NULL);
    // 释放通讯录对象的内存
    if (addressBook) {
        CFRelease(addressBook);
    }
    
}

+(NSArray *)ParseDataRef:(ABRecordRef)record ID:(ABPropertyID)property
{
    ABMultiValueRef tmp=(ABRecordCopyValue(record, property));
    NSArray *arrayL = [NSArray array];
    for(NSInteger j = 0; ABMultiValueGetCount(tmp); j++)
    {
        
        NSString* tmpIndex = (__bridge NSString*)ABMultiValueCopyValueAtIndex(tmp, j);
        
        if (tmpIndex==NULL) {
            break;
        }
        
        if ([tmpIndex isKindOfClass:[NSString class]]) {
            tmpIndex = [tmpIndex stringByReplacingOccurrencesOfString:@"(" withString:@""];
            tmpIndex = [tmpIndex stringByReplacingOccurrencesOfString:@")" withString:@""];
            tmpIndex = [tmpIndex stringByReplacingOccurrencesOfString:@"-" withString:@""];
            tmpIndex = [tmpIndex stringByReplacingOccurrencesOfString:@" " withString:@""];
            tmpIndex = [tmpIndex stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            arrayL = [arrayL arrayByAddingObject:tmpIndex];
        }else{
//            NSDictionary *dic = (NSDictionary *)tmpIndex;
//            NSLog(@"%@",[dic objectForKey:@"City"]);
//            NSLog(@"%@",[dic objectForKey:@"Country"]);
//            NSLog(@"%@",[dic objectForKey:@"CountryCode"]);
//            NSLog(@"%@",[dic objectForKey:@"Street"]);
//            NSLog(@"%@",[dic objectForKey:@"ZIP"]);
        }
    }
    if (tmp) {
        CFRelease(tmp);
    }
    return arrayL;
}

+(NSString *)getSystemDate:(NSDate *)date
{
    if (date==NULL) {
        date = [NSDate date];
    }
    NSDateFormatter *data_time = [[NSDateFormatter alloc]init];
    [data_time setDateFormat:@"yyyy-MM-dd"];
    return [data_time stringFromDate:date];
}

+(void)FirstUpdateTable
{
    if ([self getTotalRecord] > 0) {
        return;
    }
    NSArray *arrData = [self getDataFromAddressBook];
    for (AddressBook *book in arrData) {
        [self insert:book];
    }
}

#pragma mark - ========建表==================
+ (void)createTable
{
    NSString *sql = @"create table if not exists AddressBook("
    "ContactID integer, "
    
    "name text, "
    "telePhone text, "
    "mobile text"
    ")";
    [DB execSql:sql];
}

+(NSString *)getTelStringWith:(NSArray *)list
{
    NSString *result = @"";
    for (int i=0; i<list.count; i++) {
        NSString *str = [list objectAtIndex:i];
        str = str ? str : @"";
        if (i==0) {
            result = [NSString stringWithFormat:@"%@",str];
        }else{
            result = [NSString stringWithFormat:@"%@,%@",result,str];
        }
    }
    
    return result;
}

+(NSArray *)getTelePhoneList:(NSString *)string
{
    if (!string || string.length<=0) {
        return NULL;
    }
    NSMutableArray *result = [NSMutableArray array];
    NSArray *arrData = [string componentsSeparatedByString:@","];
    for (NSString *mobil in arrData) {
        if (mobil.length>0) {
            [result addObject:mobil];
        }
    }
    return result;
}

#pragma mark 重置数据库
+(void)ReplacementAddressBook:(NSArray *)arrData
{
    NSString *sql = [NSString stringWithFormat:@"delete from AddressBook"];
    [DB execSql:sql];
    arrData = arrData ?: [self getDataFromAddressBook];
    for (AddressBook *book in arrData) {
        [self insert:book];
    }
}

#pragma mark 新增
+ (BOOL)insert:(AddressBook *)entity
{
    if (!entity)
        return NO;
    
    //判断是否已经存在记录
    AddressBook *hasBook = [AddressBook selectByID:entity.ContactID];
    if(hasBook)
        return NO;
    
    //格式化手机号码再入库（暂时只支持每一个人只匹配一个号码)
    NSString *mobile = [Tools formatMobileForStorage:entity.mobile];
    if (![CTB isMobile:mobile])//不是手机号码不入库
        return NO;
    
    NSString *telePhone = [self getTelStringWith:entity.telePhone];
    
    NSString *fullName = entity.fullName;
    if (![fullName isKindOfClass:[NSString class]]) {
        fullName = @"";
    }
    
    fullName = fullName ?: @"";
    
    NSString *sql = [NSString stringWithFormat:@"insert into AddressBook ("
                     "ContactID, "
                     
                     "name, telePhone, mobile"
                     ") values ("
                     "%ld, "
                     "'%@', '%@', '%@')",
                     
                     (long)entity.ContactID,
                     
                     fullName,telePhone,entity.mobile];
    
    [DB execSql:sql];
    
    return YES;
}

#pragma mark 更新数据
+ (void)update:(AddressBook *)entity
{
    if (!entity)
        return;
    
    NSString *telePhone = [self getTelStringWith:entity.telePhone];
    
    NSString *sql = [NSString stringWithFormat:@"update AddressBook set "
                     "ContactID=%d, "
                     
                     "name='%@', telePhone='%@', mobile='%@' "
                     " where ContactID = %d",
                     entity.ContactID,
                     
                     entity.fullName,telePhone,entity.mobile, entity.ContactID];
    
    [DB execSql:sql];
}

#pragma mark - =======获取数据总条数============================
+(NSInteger)getTotalRecord
{
    NSString *sql = [NSString stringWithFormat:@"select count(*) from AddressBook"];
    NSInteger count = [DB getTotalBySql:sql];
    return count;
}

#pragma mark 删除联系人记录
+ (void)deleteRecord:(NSInteger)ContactID
{
    NSString *sql = [NSString stringWithFormat:@"delete from AddressBook where ContactID = %ld", (long)ContactID];
    [DB execSql:sql];
}

+(NSString *)getNameByMobile:(NSString *)mobile
{
    AddressBook *book = [AddressBook selectByMobile:mobile];
    
    return book.fullName;
}

#pragma mark 拿取全部
+(NSArray *)selectAll
{
    NSString *sql = [NSString stringWithFormat:@"select * from AddressBook"];
    NSArray *arrData = [self selectBySql:sql];
    return arrData;
}

+(void)checkSameAddressBook
{
    NSArray *arrData = [self selectAll];
    if (arrData.count <= 0) {
        return;
    }
    for (AddressBook *book in arrData) {
        NSString *sql = [NSString stringWithFormat:@"select * from AddressBook where ContactID = %d", book.ContactID];
        NSArray *arrData = [self selectBySql:sql];//如果该ContactID有超过2个,则执行以下操作
        if (arrData.count>1) {
            [AddressBook deleteRecord:book.ContactID];
        }
    }
}

#pragma mark 根据ContactID拿取
+(AddressBook *)selectByID:(int)ContactID
{
    NSString *sql = [NSString stringWithFormat:@"select * from AddressBook where ContactID = %d", ContactID];
    NSArray *arrData = [self selectBySql:sql];
    if (arrData.count > 0) {
        AddressBook *book = [arrData firstObject];
        return book;
    }
    
    return NULL;
}

#pragma mark 根据手机号码拿取
+(AddressBook *)selectByMobile:(NSString *)mobile
{
    NSString *sql = [NSString stringWithFormat:@"select * from AddressBook where mobile = '%@'", mobile];
    NSArray *arrData = [self selectBySql:sql];
    if (arrData.count > 0) {
        AddressBook *book = [arrData firstObject];
        return book;
    }
    
    return NULL;
}

+(AddressBook *)selectByMobile:(NSString *)mobile from:(NSArray *)list
{
    AddressBook *result = nil;
    for (AddressBook *book in list) {
        if ([book.mobile isEqualToString:mobile]) {
            result = book;
            break;
        }
    }
    
    return result;
}

#pragma mark 根据手机号码拿取ContactID
+(NSInteger)getContactIDByMobile:(NSString *)mobile
{
    NSInteger result = 0;
    NSString *sql = [NSString stringWithFormat:@"select * from AddressBook where mobile = '%@'", mobile];
    NSArray *arrData = [self selectBySql:sql];
    if (arrData.count > 0) {
        AddressBook *book = [arrData firstObject];
        result = book.ContactID;
    }
    
    return result;
}

+(NSInteger)getContactIDByMobile:(NSString *)mobile from:(NSArray *)list
{
    NSInteger result = 0;
    
    for (AddressBook *book in list) {
        if ([book.mobile isEqualToString:mobile]) {
            result = book.ContactID;
        }
    }
    
    return result;
}

#pragma mark 根据名字拿取
+(NSArray *)selectByName:(NSString *)name
{
    NSString *sql = [NSString stringWithFormat:@"select * from AddressBook where name = '%@'", name];
    NSArray *arrData = [self selectBySql:sql];
    
    return arrData;
}

#pragma mark 根据sql拿取数据
+ (NSArray *)selectBySql:(NSString *)sql
{
    sqlite3_stmt *stmt = [DB query:sql];
    
    NSMutableArray *list = [NSMutableArray array];
    if (stmt) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            AddressBook *entity = [[AddressBook alloc] init];
            
            entity.ContactID = [DB getInt:stmt index:0];
            
            entity.fullName = [DB getString:stmt index:1];
            entity.telePhone = [self getTelePhoneList:[DB getString:stmt index:2]];
            entity.mobile = [DB getString:stmt index:3];
            
            [list addObject:entity];
        }
    }
    
    sqlite3_finalize(stmt);//释放资源
    
    return list;
}

+ (NSDictionary *)selectContactIdLists
{
    sqlite3_stmt *stmt = [DB query:@"select * from AddressBook"];
    
    NSMutableDictionary *list = [NSMutableDictionary dictionary];
    if (stmt) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            AddressBook *entity = [[AddressBook alloc] init];
            
            entity.ContactID = [DB getInt:stmt index:0];
            
            entity.fullName = [DB getString:stmt index:1];
            entity.telePhone = [self getTelePhoneList:[DB getString:stmt index:2]];
            entity.mobile = [DB getString:stmt index:3];
            
            //暂时只支持同一个人只匹配一个手机号码
            if([CTB isMobile:entity.mobile])
                [list setObject:entity forKey:[NSNumber numberWithInteger:entity.ContactID]];
        }
    }
    
    sqlite3_finalize(stmt);//释放资源
    
    return list;
}

@end
