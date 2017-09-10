//
//  Shapefile.h
//  shpRead_ipad_02
//
//  Created by shy on 15/4/12.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Shxfile;

@interface Shapefile : NSObject
{
    @public
	//上下左右边界
	long extendLeft;
	long extendTop;
	long extendRight;
	long extendBottom;
	
    //文件长度，版本
	long fileLength;
	long m_nVersion;
    
    //记录数，文件类型
	int recordCount;
	long m_nWidth;
	long shapefileType;
	
	NSString *m_strShapefile;
	NSData *m_data;
	
    Shxfile *shp_shxFile;
    
    //保存数据
	NSMutableArray *m_objList;
	
}

@property (readwrite) long extendLeft;
@property (readwrite) long extendBottom;
@property (readwrite) long extendRight;
@property (readwrite) long extendTop;
@property (readwrite) long fileLength;
@property (readwrite) int recordCount;
@property (readwrite) long shapefileType;
-(BOOL)loadShapefile:(NSString *)strShapefile;
-(void *)parsePoint:(void *)pMain;
-(void *)parsePolyline:(void *)pMain;

@end