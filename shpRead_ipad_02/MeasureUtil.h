//
//  MeasureUtil.h
//  shpRead_ipad_02
//
//  Created by shy on 15/4/17.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface MeasureUtil : NSObject{
    @public
    //起始点，终止点
    CGPoint begin_point;
    CGPoint end_point;
    
    //经纬度
    double _lon1;
    double _lat1;
    double _lon2;
    double _lat2;

    //测距第一次点击标志
    BOOL isFirstTap;
    
}


-(void)setLat:(double)lat1 witLong:(double)lon1 andSetLat:(double)lat2 withLong:(double)lon2;

-(double)getDistance;

@end
