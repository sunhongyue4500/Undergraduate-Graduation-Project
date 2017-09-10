//
//  MapRenderer.m
//  shpRead_ipad_02
//
//  Created by shy on 15/5/12.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "MapRenderer.h"
#import "ShpHelper.h"

@implementation MapRenderer

+(double)getFontSize:(int) MapDisplayType{
    if(MapDisplayType == ChinaMap){
        return 9.0;
    }else{
        return 9.0;
    }
}

+(double)getLineWidth:(int)_drawPattern{
    switch (_drawPattern) {
        case drawdefault:
            return 0.2;
        case drawPolyline:
        case drawPolygon:
            return 0.3;
        case drawPoint:
            return 0.1;
        case drawDistance:
            return 2.0;
        default:
            break;
    }
    return -1;
}

+(double)getPointRadius{
    return 4;
}

+(double)getPointRecognizedRadius:(int)mapDisplayType{
    if(mapDisplayType == ChinaMap){
        return 0.4;
    }
    return 1;
}

+(UIColor *)getColor{
    return [UIColor colorWithRed:19/255.0f green:190/255.0f blue:236/255.0f alpha:1.0];
}

+(UIColor *)getPolylineRandomColor{
    return [UIColor colorWithRed:(arc4random()%256)/255.0f green:(arc4random()%256)/255.0f blue:(arc4random()%256)/255.0f alpha:0.5];
}

+(UIColor *)getColorByNumber:(int)number{
    UIColor *temp;
    switch (number) {
        case 1:
            //淡粉
            temp = [UIColor colorWithRed:255/255.0f green:140/255.0f blue:105/255.0f alpha:0.5];
            break;
        case 2:
            //淡紫
            temp = [UIColor colorWithRed:221/255.0f green:160/255.0f blue:221/255.0f alpha:0.5];
            break;
            
        case 3:
            //淡绿 YellowGreen
            temp = [UIColor colorWithRed:154/255.0f green:205/255.0f blue:50/255.0f alpha:0.5];
            break;
        
        case 4:
            temp = [UIColor colorWithRed:67/255.0f green:110/255.0f blue:238/255.0f alpha:0.5];
        default:
            break;
    }
    return temp;
}


+(UIColor *)getColorByCode:(int)code{
    UIColor *temp;
    if(code == heilongjiang || code == liaoning || code == beijing || code == jiangsu || code == ningxia || code == henan || code == xinjiang || code == sichuan || code == taiwan || code == hunan || code == fujian || code == hongkong || code == hainan || code == Macau){
    
        temp = [MapRenderer getColorByNumber:1];
    }else if(code == jilin || code == tianjin || code == shan1xi || code == shandong || code == shanghai || code == gansu || code == chongqing || code == jiangxi || code == yunan){
        temp = [MapRenderer getColorByNumber:2];
    }else if(code == Nei || code == hubei || code == zhejiang || code == qinghai || code == guangxi ){
        temp = [MapRenderer getColorByNumber:3];
    }else{
        temp = [MapRenderer getColorByNumber:4];
    }
    return temp;
}

@end
