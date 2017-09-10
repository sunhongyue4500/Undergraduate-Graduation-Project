//
//  MeasureUtil.m
//  shpRead_ipad_02
//
//  Created by shy on 15/4/17.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "MeasureUtil.h"

#define PI 3.1415926


@implementation MeasureUtil


-(id)init{
    if(self = [super init]){
    
        isFirstTap = NO;
    }
    return self;
}

-(void)setLat:(double)lon1 witLong:(double)lat1 andSetLat:(double)lon2 withLong:(double)lat2{
    
    _lon1 = lon1;
    _lat1 = lat1;

    _lon2 = lon2;
    _lat2 = lat2;
}


//返回千米
-(double)getDistance{
    double er = 6378.137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double lon1 = _lon1;
    double lon2 = _lon2;
    double lat1 = _lat1;
    double lat2 = _lat2;
    double radlat1 = PI*lat1/180.0f;
    double radlat2 = PI*lat2/180.0f;
    //now long.
    double radlong1 = PI*lon1/180.0f;
    double radlong2 = PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west

    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));

    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    return dist;
}

@end
