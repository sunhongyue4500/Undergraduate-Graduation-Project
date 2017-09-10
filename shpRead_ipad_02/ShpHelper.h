//
//  ShpHelper.h
//  shpRead_ipad_02
//
//  Created by shy on 15/4/13.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
    ShapefileTypeUnknown = -1,
    ShapefileTypePoint = 1,
    ShapefileTypePolyLine = 3,
    ShapefileTypePolygon = 5,
    ShapefileTypeMultiPoint = 8,
    ShapefileTypePointZ = 11,
    ShapefileTypePolyLineZ = 13,
    ShapefileTypePolygonZ = 15,
    ShapefileTypeMultiPointZ = 18,
    ShapefileTypePointM = 21,
    ShapefileTypePolyLineM = 23,
    ShapefileTypePolygonM = 25,
    ShapefileTypeMultiPointM = 28,
    ShapefileTypeMultiPatch = 31,
    
};

typedef NSUInteger ShapefileType;

enum{
    //平面投影
    TwoDimentionsProjectionPattern = 1,
    //方位正射投影
    OrthographicProjectionPattern = 2,
    //Mecator投影
    MercatroProjectionPattern = 3
};

typedef NSUInteger ProjectionPattern;

enum{
    ChinaMap = 1,
    WorldMap = 2
};

typedef NSUInteger MapDisplayType;

@interface ShpHelper : NSObject

+(NSString *)getFilePath:(NSString *)fileName;
- (BOOL) isBlankString:(NSString *)string;

@end
