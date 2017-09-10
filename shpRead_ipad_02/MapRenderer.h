//
//  MapRenderer.h
//  shpRead_ipad_02
//
//  Created by shy on 15/5/12.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum{
    drawdefault = 1,
    drawPolyline = 2,
    drawPolygon = 3,
    drawPoint = 4,
    drawDistance = 5
};
typedef NSUInteger drawPattern;

//定义省份四色
enum ShengFenColorType{
    heilongjiang = 23,//23
    liaoning = 21,    //21
    beijing = 11,     //11
    jiangsu = 32,     //32
    ningxia = 64,     //64
    henan = 41,       //41
    xinjiang = 65,    //65
    sichuan = 51,     //51
    taiwan =71,       //71
    hunan = 46,       //46
    fujian = 35,      //35
    hongkong = 81,    //81
    hainan = 43,      //43
    Macau = 82,       //82
    
    
    jilin = 22,                  //22
    tianjin = 12,            //12
    shan1xi =14,             //14
    shandong = 37,           //37
    shanghai = 31,       //31
    gansu = 62,          //62
    chongqing = 50,      //50
    jiangxi = 36,        //36
    yunan = 53,          //53
    
    
    //3
    //内蒙
    Nei = 15,                //15
    hubei = 42,            //42
    zhejiang = 33,         //33
    qinghai = 63,          //63
    guangxi = 45,          //45
    
    //4
    hebei = 13,             //13
    anhui = 34,         //34
    shan3xi = 61,       //61
    xizang = 54,        //54
    guizhou = 52,       //52
    guangdong = 44,     //44

};



@interface MapRenderer : NSObject{
    double lineWidth;
    UIColor *color;

}


+(double)getFontSize:(int) MapDisplayType;
+(UIColor *)getColor;
+(UIColor *)getColorByCode:(int)code;
+(UIColor *)getColorByNumber:(int)number;
+(double)getLineWidth:(int)_drawPattern;
+(double)getPointRadius;
+(double)getPointRecognizedRadius:(int)mapDisplayType;


@end
