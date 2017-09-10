//
//  orthographic_projection_oc.h
//  shpRead_ipad_02
//
//  Created by shy on 15/4/25.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>
#define pi  3.1415926535897932384626433832795
#define j2h(x) (pi*(x)/180.0)

@interface orthographic_projection_oc : NSObject{
    
    @private
    //不进行遮挡变换
    BOOL m_no_mask;
    
    //中心点
    double m_center_latitude;
    double m_center_longitude;
    double m_sin_center_latitude;
    double m_cos_center_latitude;
    
    //地球参数
    double m_earth_radius;

}

//计算Lambda参数
-(double)get_lambda: (double) central_meridian andLon: (double) longitude;

//设置投影中心点
-(void)set_center: (double) latitude andLongitude: (double) longitude;

//经纬度转换为平面坐标
-(BOOL)transit_to_xy: (double *) x andY: (double *) y andLat: (double) latitude andLon: (double)longitude;

//平面坐标转为经纬度
-(BOOL)xy_to_transit: (double*) latitude andLon:(double*) longitude andX: (double) x andY: (double) y;
@end
