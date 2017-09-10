//
//  Dbffile.h
//  shpRead_ipad_02
//
//  Created by shy on 15/4/12.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dbffile : NSObject{
    @public
    //列数
    int columnCount;
    //记录的条数
    int recordCount;
    //属性列的名称
    NSMutableArray *colomuName;
    //每个字段的长度
    NSMutableArray *colomuLength;
    //每个字段的类型
    NSMutableArray *colomuType;
    //保存属性数据信息
    NSMutableArray *attrData;
    //保存所有的标签信息
    NSMutableArray *labelDisplay;
    
    NSData *m_data;
    NSString *m_strShapefile;
}

-(BOOL)loadDbffile:(NSString *)strDbffile;

@end
