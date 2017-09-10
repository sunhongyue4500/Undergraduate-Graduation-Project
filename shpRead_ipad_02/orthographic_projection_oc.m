//
//  orthographic_projection_oc.m
//  shpRead_ipad_02
//
//  Created by shy on 15/4/25.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "orthographic_projection_oc.h"
#import <math.h>



@implementation orthographic_projection_oc

#pragma mark-自定义初始化
-(id)init{

    if(self = [super init]){
        m_no_mask = NO;
        m_earth_radius = 6371288.0 / 2.0;
        
        //设置默认的投影中心点(下面的这个事弧度制)
      //[self set_center:0.69944069773672757795216907547181 andLongitude:2.0348793749001888537353310669809];
        [self set_center:j2h(51.3) andLongitude:j2h(-0.7)];
    }
    return self;
}

#pragma mark-设置投影中心点
-(void)set_center: (double) latitude andLongitude: (double) longitude{
    //记录中心点
    m_center_latitude = latitude;
    m_center_longitude = longitude;
    
    //计算中心点纬度正余弦
    m_sin_center_latitude = sin(m_center_latitude);
    m_cos_center_latitude = cos(m_center_latitude);

}

#pragma mark- 经纬度转换为平面坐标（纬度，经度为弧度制）
-(BOOL)transit_to_xy: (double *) x andY: (double *) y andLat: (double) latitude andLon: (double)longitude{
    BOOL done = YES;
    BOOL visible = YES;
    double radius = m_earth_radius;
    if(radius <= 0.0 )
        done = NO;
    if( (fabs(latitude) > pi/2) || (fabs(longitude) > pi) )
    {
        done = NO;
        visible = NO;
    }
    if(done || m_no_mask)
    {
        double lambda = [self get_lambda:m_center_longitude andLon:longitude];
        double sin_latitude = sin(latitude);
        double cos_latitude = cos(latitude);
        double sin_lambda = sin(lambda);
        double cos_lambda = cos(lambda);
        if((m_sin_center_latitude * sin_latitude + m_cos_center_latitude * cos_latitude * cos_lambda) <= 0.0)
            visible = NO;
        if (visible || m_no_mask)
        {
            *x = radius * cos_latitude * sin_lambda;
            *y = radius * (m_cos_center_latitude * sin_latitude - m_sin_center_latitude * cos_latitude * cos_lambda);
        }
        done = visible;
    }
    return done;
}

#pragma mark-平面坐标转为经纬度
-(BOOL)xy_to_transit: (double *) latitude andLon:(double *) longitude andX: (double) x andY: (double) y{
    bool visible = NO;
    double radius = m_earth_radius;
    
    if(radius > 0.0)
    {
        visible = YES;
        
        double distance_to_center = sqrt(x * x + y * y);
        double sin_c = distance_to_center / radius;
        double cos_c = sqrt(radius * radius - x * x - y * y) / radius;
        double lambda;
        
        if(fabs(sin_c) <= 1.0 )
        {
            if(distance_to_center > 0.0)
            {
                //计算纬度
                if(fabs(m_center_latitude - (pi / 2.0)) < 0.00001)
                {
                    *latitude = asin(cos_c);
                    lambda = atan2(x * sin_c, -y * sin_c);
                }
                else if(fabs(m_center_latitude - (-pi / 2.0)) < 0.00001)
                {
                    *latitude = asin(cos_c);
                    lambda = atan2(x * sin_c, y * sin_c);
                }
                else if(fabs(m_center_latitude - 0.0) < 0.00001)     //if  Equator
                {
                    *latitude = asin(y * sin_c / distance_to_center);
                    lambda = atan2(x * sin_c, distance_to_center * cos_c);
                }
                else
                {
                    *latitude = asin(cos_c * m_sin_center_latitude + y * sin_c * m_cos_center_latitude / distance_to_center);
                    lambda = atan2(x * sin_c, (distance_to_center * m_cos_center_latitude * cos_c - y * m_sin_center_latitude * sin_c));
                }
                
                //计算经度
                *longitude = m_center_longitude + lambda;
                if(fabs(*longitude) > pi)
                {
                    if( *longitude > pi )
                        (*longitude) -=  2.0 * pi;
                    else
                        (*longitude) += 2.0 * pi ;
                }
            }
            else
            {
                *latitude = m_center_latitude;
                *longitude = m_center_longitude;
            }
        }
        else
            visible = NO;
        
        return(visible);
    }
    else
    {
        return NO;
    }

}

#pragma mark- 计算Lambda参数
-(double)get_lambda: (double) central_meridian andLon: (double) longitude{
    double lambda ;
    lambda = longitude - central_meridian;
    if( (longitude < 0.0) && (central_meridian > 0.0) )
    {
        if( lambda < -pi )
            lambda = 2.0 * pi + lambda;
    }
    if( (longitude > 0.0) && (central_meridian < 0.0))
    {
        if( lambda > pi)
            lambda -= 2.0 * pi;
    }
    return  lambda;
}

@end
