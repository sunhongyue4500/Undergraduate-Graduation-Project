//
//  Dbffile.m
//  shpRead_ipad_02
//
//  Created by shy on 15/4/12.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "Dbffile.h"

@implementation Dbffile

-(id)init{
    if(self = [super init])
    {
        attrData = [[NSMutableArray alloc] init];
        colomuType = [[NSMutableArray alloc] init];
        labelDisplay = [[NSMutableArray alloc] init];
    }
    return  self;
}


-(BOOL)loadDbffile:(NSString *)strDbffile{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *dic = [manager attributesOfItemAtPath:strDbffile error:nil];

    NSNumber *number = [dic objectForKey:NSFileSize];
    // file size in bytes
    long long fileSize = [number longLongValue];
    
    NSLog(@"size:%zi",fileSize);
    
    //load dbfFile
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:strDbffile];
    
    int versionInfo = 0;
    [[handle readDataOfLength:1] getBytes:&versionInfo length:1];
    
    int year,month,day;
    [[handle readDataOfLength:1] getBytes:&year length:1];
    
    [[handle readDataOfLength:1] getBytes:&month length:1];
    
    [[handle readDataOfLength:1] getBytes:&day length:1];
    
    //文件中的记录条数，即行数

    [[handle readDataOfLength:4] getBytes:&recordCount length:4];
    //文件头的长度
    int headLength = 0;
    [[handle readDataOfLength:2] getBytes:&headLength length:2];
    //每行的长度
    int rowLength = 0;
    [[handle readDataOfLength:2] getBytes:&rowLength length:2];
    //获取列数
    columnCount = (headLength - 33) / 32;
    
    //跳过20个字节
    [handle seekToFileOffset:[handle offsetInFile]+20];
    
    
    
    //用一个数组来保存列的名称
    colomuName = [[NSMutableArray alloc] initWithCapacity:columnCount];
    colomuLength = [[NSMutableArray alloc] initWithCapacity:columnCount];
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //读取每一个字段定义
    for (int i=0; i<columnCount; i++) {

        NSData *data = [handle readDataOfLength:11];

        NSString *nametest = [[NSString alloc] initWithData:data encoding:encoding];
        NSLog(@"name:%@",nametest);
        [colomuName addObject:nametest];
        
        //读取字段的数据类型，为ASCII码值
        char fieldType;
        [[handle readDataOfLength:1] getBytes:&fieldType length:1];
        //添加列的类型
        [colomuType addObject:[NSNumber numberWithChar:fieldType]];
        
        //跳过4个字节
        [handle seekToFileOffset:[handle offsetInFile]+4];
        //读取字段对应的值在后面的记录中的长度
        int filedLength = 0;
        [[handle readDataOfLength:1] getBytes:&filedLength length:1];
        [colomuLength addObject:[NSNumber numberWithInt:filedLength]];
        //字段的精度
        Byte filedAccuracy;
        [[handle readDataOfLength:1] getBytes:&filedAccuracy length:1];
        //跳过2个字节
        [handle seekToFileOffset:[handle offsetInFile]+2];
        //工作区ID
        Byte workStationId;
        [[handle readDataOfLength:1] getBytes:&workStationId length:1];
        //跳过11个字节
        [handle seekToFileOffset:[handle offsetInFile]+11];
        
    }
    
    //读取终止字段
    Byte stopField;
    [[handle readDataOfLength:1] getBytes:&stopField length:1];
    if(stopField == 0x0D){
        NSLog(@"..............................");
    }
    
    NSLog(@"%i",stopField);
    NSLog(@"name:%@",colomuName);
    NSLog(@"length:%@",colomuLength);
    
    //文件头读完读取数据信息
    int colomuLengthtemp = 0;
    char colomuTypetemp;

    for(int i=0;i<recordCount;i++){
        //读取每一条记录
        NSMutableArray *rowArray = [[NSMutableArray alloc] init];
        //跳过一个字节
        [handle seekToFileOffset:[handle offsetInFile]+1];
        //[[handle readDataOfLength:1] getBytes:&stopField length:1];
        //读取每一个字段
        for(int j=0;j<columnCount;j++){
            colomuLengthtemp = [[colomuLength objectAtIndex:j] intValue];
        
            colomuTypetemp = [[colomuType objectAtIndex:j] charValue];

            NSString * strTemp = [[NSString alloc] initWithData:[handle readDataOfLength:colomuLengthtemp] encoding:encoding];
            [rowArray addObject:strTemp];
        }
        [attrData addObject:rowArray];
    }
    
    
    return YES;
}

@end
