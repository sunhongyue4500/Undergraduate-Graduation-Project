//
//  Mercator_projection.m
//  shpRead_ipad_02
//
//  Created by shy on 15/5/1.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "Mercator_projection.h"
#import <math.h>

@implementation Mercator_projection

-(id)init{
    if(self = [super init]){
        _IterativeTimes = 10;
        _IterativeValue = 0;
        _B0 = 0;
        _L0 = 0;
        _A = 1;
        _B = 1;
    }
    return self;
}

-(void)setAB:(double)a andB:(double)b{
    if(a<=0||b<=0) {
        return;
    }
    _A=a;
    _B=b;
}

-(void)setB0:(double)b0{
    if(b0<-pi/2||b0>pi/2) {
        return;
    }
    _B0=b0;
}

-(void)setL0:(double)l0{
    if(l0<-pi||l0>pi) {
        return; }
    _L0=l0;
}

#pragma mark - 正向投影
-(int)toProj:(double)B andL:(double)L andX:(double *)X andY:(double *)Y{
    double f/*扁率*/,e/*第一偏心率*/,e_/*第二偏心率*/,NB0/*卯酉圈曲率半径*/,K ,dtemp;
    if(L<-pi||L>pi||B<=-pi/2||B>=pi/2) {
        return 1;
    }
    //_A 椭球体长半轴 _B椭球体短半轴
    if(_A<=0||_B<=0) {
        return 1;
    }
    f =(_A-_B)/_A;
    dtemp=1-(_B/_A)*(_B/_A);
    if(dtemp<0)
    {
        return 1;
    }
    e= sqrt(dtemp);
    dtemp=(_A/_B)*(_A/_B)-1;
    if(dtemp<0)
    {
        return 1;
    }
    //求第二偏心率
    e_= sqrt(dtemp);
    NB0=((_A*_A)/_B)/sqrt(1+e_*e_*cos(_B0)*cos(_B0));
    K=NB0*cos(_B0);
    *Y=K*(L-_L0);
    *X=K*log(tan(pi/4+B/2)*pow((1-e*sin(B))/(1+e*sin(B)),e/2));
    return 0;
}

-(int)FromProj:(double)X andY:(double)Y andB:(double *)B andL:(double *)L{
    
    double f/*扁率*/,e/*第一偏心率*/,e_/*第二偏心率*/,NB0/*卯酉圈曲率半径*/,K ,dtemp;
    double E=exp(1);
    if(_A<=0||_B<=0) {
        return 1;
    }
    f =(_A-_B)/_A;
    dtemp=1-(_B/_A)*(_B/_A); if(dtemp<0)
    {
        return 1;
    }
    e= sqrt(dtemp);
    dtemp=(_A/_B)*(_A/_B)-1; if(dtemp<0)
    {
        return 1;
    }
    e_= sqrt(dtemp); NB0=((_A*_A)/_B)/sqrt(1+e_*e_*cos(_B0)*cos(_B0)); K=NB0*cos(_B0);
    *L=Y/K+_L0; *B=_IterativeValue;
    for(int i=0;i<_IterativeTimes;i++) {
        *B=pi/2-2*atan(pow(E,(-X/K))*pow(E,(e/2)*log((1-e*sin(*B))/(1+e*sin(*B)))));
    }
    return 0;
}

@end
