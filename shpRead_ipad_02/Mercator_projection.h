//
//  Mercator_projection.h
//  shpRead_ipad_02
//
//  Created by shy on 15/5/1.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>
#define pi  3.1415926535897932384626433832795
#define j2h(x) (pi*(x)/180.0)
#define h2j(x) (180.0*(x)/pi)

@interface Mercator_projection : NSObject{
    @public
    int _IterativeTimes;    //反向转换程序中的迭代次数
    int _IterativeValue;    //反向转换程序中的迭代初始值
    double _A;              //椭球体长半轴，米
    double _B;              //椭球体段半轴，米
    double _B0;             //标准纬度 弧度
    double _L0;             //标准经度 弧度
}

-(void)setAB:(double)a andB:(double)b;
-(void)setB0:(double)b0;
-(void)setL0:(double)l0;

-(int)toProj:(double)B andL:(double)L andX:(double *)X andY:(double *)Y;
-(int)FromProj:(double)X andY:(double)Y andB:(double *)B andL:(double *)L;

@end
