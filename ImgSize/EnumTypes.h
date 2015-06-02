//
//  EnumTypes.h
//  iFace
//
//  Created by APPLE on 14-9-9.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#ifndef iFace_EnumTypes_h
#define iFace_EnumTypes_h

//手机设备类型
typedef NS_ENUM(NSInteger, Enum_iPhoneType) {
    iPhone_Online   = 1,    //远程模式（在线模式）
    iPhone_WP       = 2,    //WP
    iPhone_Android  = 3,    //Android
    iPhone_iOS      = 4     //iOS
};

//当前工作模式
typedef NS_ENUM(NSInteger, Enum_WorkingMode) {
    WorkingMode_Online      = 1,            //远程模式（在线模式）
    WorkingMode_Offline     = 2             //离线模式（局域网模式）
};

//当前工作模式
typedef NS_ENUM(NSInteger, Enum_NoticeType) {
    Notice_AddFamily        = 1,            //添加家庭成员
    Notice_RemoveFamily     = 2,            //移除家庭成员
    Notice_UPAdmin          = 3,            //变更管理员
    Notice_OpenTask         = 4,            //开启智能任务OR定时任务
    Notice_Reset            = 5             //主机复位
};

//密码操作模式
typedef NS_ENUM(NSInteger, Enum_PWDType) {
    PWDType_Add     = 1,            //添加密码
    PWDType_Alter   = 2,            //修改密码
    PWDType_Check   = 3,            //验证密码
    PWDType_Delete  = 4             //删除密码
};

//发送数据类型Tag
typedef NS_ENUM(long, Enum_SendTag) {
    SendTag_Default         =  0,           //发送默认绑定
    SendTag_Heart           =  1,           //发送绑定心跳包
    SendTag_ReadControl     =  2,           //发送绑定读取主机
    SendTag_ReadSlave       =  3,           //发送绑定读取从机
    SendTag_OpenSlave       =  4,           //发送绑定开启从机
    SendTag_CloseSlave      =  5,           //发送绑定关闭从机
    SendTag_UploadConfig    =  6,           //发送上传主机配置信息
    SendTag_InfraredStudy   =  7,           //发送添加红外学习指令
    SendTag_InfraredAction  =  8,           //发送红外指令
    SendTag_ReadDoor        =  9,           //读取门禁状态
    SendTag_OpenDoor        = 10,           //发送开门指令
    SendTag_ConnectDoor     = 11,           //发送连接门指令
    SendTag_ReadTemp        = 12            //读取主机温度
};

//超时时间
typedef NS_ENUM(NSInteger, Enum_ReceiveTimeOut) {
    
    TimeOut_Never       = -1,          //默认不设置超时
    TimeOut_Online      = 5,          //远程模式超时（单位：秒）
    TimeOut_Offline     = 2           //离线模式超时（单位：秒）
};

//从机设备状态
typedef NS_ENUM(NSInteger, Enum_SlaveStatus) {
    SlaveStatus_None    = 0,            //未知状态
    SlaveStatus_Open    = 1,            //开启
    SlaveStatus_Close   = 2             //关闭
};

//从机设备类型
typedef NS_ENUM(NSInteger, Enum_DeviceType) {
    DeviceType_None             = 0,            //未知设备
    DeviceType_Switch           = 1 << 0,       //未定义名称的开关
    DeviceType_Outlet           = 1 << 1,       //未定义名称的插座
    DeviceType_Infrared         = 1 << 2,       //未定义名称的红外设备（摇控）
    DeviceType_DoorControl      = 1 << 3,       //未定义名称的门禁设备（门禁）
    DeviceType_ElectricFan      = 1 << 4,       //电风扇
    DeviceType_TV               = 1 << 5,       //电视机
    DeviceType_Lamp             = 1 << 6,       //灯
    DeviceType_WaterDispenser   = 1 << 7,       //饮水机
    DeviceType_RiceCooker       = 1 << 8,       //电饭锅
    DeviceType_Conditioner      = 1 << 9,       //空调
    DeviceType_Sound            = 1 << 10,      //音响
    DeviceType_STB              = 1 << 11       //机顶盒
};

//开关类型
typedef NS_ENUM(NSInteger, Enum_SwitchType) {
    SwitchType_None     = 0,        //未知
    SwitchType_Switch   = 1<< 0,    //开关
    SwitchType_Outlet   = 1<< 1,    //插座
    SwitchType_IrDA     = 1<< 2,    //红外
    SwitchType_Gate     = 1<< 3,    //门禁
    SwitchType_Lock     = 1<< 4,    //门锁
};

//数据返回类型
typedef NS_ENUM(NSInteger, Enum_DataResult)
{
    DataResult_None             =  0,            //未知状态
    DataResult_ReadControlID    =  1,            //读取主机ID返回
    DataResult_OpenSlave        =  2,            //开启从机返回
    DataResult_CloseSlave       =  3,            //关闭从机返回
    DataResult_ReadForOpen      =  4,            //读状态为开机返回
    DataResult_ReadForClose     =  5,            //读状态为关机返回
    DataResult_IntoStudy        =  6,            //下发学习指令返回
    DataResult_ReceiveCode      =  7,            //接收到遥控编码返回
    DataResult_UploadConfig     =  8,            //上传配置成功返回
    DataResult_ControlHeart     =  9,            //主机心跳包返回
    DataResult_InfraredAction   = 10,            //执行红外指令返回
    DataResult_ReadTemp         = 11             //读取主机温度返回
};

//下载红外类型
typedef NS_ENUM(NSInteger, Enum_DownloadType)
{
    DownloadType_AC         = 1,           //空调
    DownloadType_TV         = 2,           //电视
    DownloadType_STB        = 3,           //机顶盒
    DownloadType_DVD        = 4,           //DVD/VCD
    DownloadType_FAN        = 5,           //电风扇
    DownloadType_ACL        = 6            //空气净化器
};

// 数据标识 (1、添加2、更新 3、删除)
typedef NS_ENUM(NSInteger, Enum_DataMark)
{
    DataMark_None       = 0,           //无操作(表示已经提交过的状态)
    DataMark_Add        = 1,           //添加
    DataMark_Update     = 2,           //更新
    DataMark_Delete     = 3            //删除
};

typedef NS_ENUM(NSInteger, Enum_User)
{
    User_Friend     = 0,    //饭友
    User_Hotel      = 1,    //饭店
};

typedef NS_ENUM(NSInteger, enum_OperationType) {
    OperationType_Add       = 0,    //添加
    OperationType_Using     = 1,    //使用
    OperationType_Update    = 2,    //更新
};

#pragma mark 星期(Week)
typedef NS_OPTIONS(NSInteger, Week) {
    Week_None       = 0,      // 0
    Week_Sunday     = 1,      // 1  1 1
    Week_Monday     = 1 << 1, // 2  2 10 转换成 10进制 2
    Week_Tuesday    = 1 << 2, // 4  3 100 转换成 10进制 4
    Week_Wednesday  = 1 << 3, // 8  4 1000 转换成 10进制 8
    Week_Thursday   = 1 << 4, // 16 5 10000 转换成 10进制 16
    Week_Friday     = 1 << 5, // 32 6 100000 转换成 10进制 32
    Week_Saturday   = 1 << 6, // 64 7 1000000 转换成 10进制 64
    Week_All        = Week_Monday | Week_Tuesday | Week_Wednesday| Week_Thursday| Week_Friday| Week_Saturday| Week_Sunday, // 127
};

#pragma mark 分享类型（Enum_ShareType）
typedef NS_ENUM(NSInteger,Enum_ShareType)
{
    Share_WX            = 1,    //微信朋友圈
    Share_QQ            = 2,    //QQ空间
    Share_Sina          = 4,    //新浪微博
};

#endif
