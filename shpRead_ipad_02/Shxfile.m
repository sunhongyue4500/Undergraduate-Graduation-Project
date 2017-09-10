//
//  Shxfile.m
//  shpRead_ipad_02
//
//  Created by shy on 15/4/12.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "Shxfile.h"

@implementation Shxfile

-(id)init{
    if(self = [super init]){
        offset = [[NSMutableArray alloc] init];
        contentLength = [[NSMutableArray alloc] init];
    }
    return self;
}



#pragma mark-loadShxfile
-(BOOL)loadShxfile:(NSString *)strShxfile{
    //.shx FileLength 和 .shp文件的长度不一致

    
    unsigned int _temp;

    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *dic = [manager attributesOfItemAtPath:strShxfile error:nil];
    
    NSNumber *number = [dic objectForKey:NSFileSize];
    // file size in bytes
    long long fileSize = [number longLongValue];
    
    NSLog(@"size:%zi",fileSize);
    
    //load dbfFile
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:strShxfile];
    //skip 24
    [handle seekToFileOffset:[handle offsetInFile]+24];
    [[handle readDataOfLength:4] getBytes:&fileLength length:4];
    fileLength = NSSwapBigIntToHost(fileLength);
    
    recordCount = (fileLength - 50) / 4;
    //跳过头部
    [handle seekToFileOffset:[handle offsetInFile]+72];

    for(int i=0;i<recordCount;i++){
        //添加偏移量，内容长度
        [[handle readDataOfLength:4] getBytes:&_temp range:NSMakeRange(0, 4)];
        _temp = NSSwapBigIntToHost(_temp);
        [offset addObject:[NSNumber numberWithInt:_temp]];
        
        [[handle readDataOfLength:4] getBytes:&_temp range:NSMakeRange(0, 4)];
        _temp = NSSwapBigIntToHost(_temp);
        [contentLength addObject:[NSNumber numberWithInt:_temp]];
        
    }
    
    return YES;
}


@end
