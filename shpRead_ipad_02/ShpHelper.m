//
//  ShpHelper.m
//  shpRead_ipad_02
//
//  Created by shy on 15/4/13.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "ShpHelper.h"


@implementation ShpHelper

#pragma mark-获取数据源路径
+(NSString *)getFilePath:(NSString *)fileName{
    //先从指定位置加载
    NSString *resourceP = [[NSBundle mainBundle] resourcePath];
    NSString *targetPathChina = @"/dituData/shengjie_region";
    NSString *targetCaptitalPath = @"/dituData/shenghui_point";
    NSString *targetWorldCountries = @"/dituData/esriWorkMap/Countries";
    NSString *targetWorldCapitals = @"/dituData/esriWorkMap/Capitals";
    NSString *targetWorldGrids = @"/dituData/esriWorkMap/Grids";
    NSString *targetWorldRivers = @"/dituData/esriWorkMap/Rivers";
    NSString *targetWorldLakes = @"/dituData/esriWorkMap/Lakes";
    NSString *targetWorldContinentBoundary = @"/dituData/esriWorkMap/ContinentBoundary";
    NSString *targetWorldCountryBoundary= @"/dituData/esriWorkMap/CountryBoundary";
    NSString *targetWorldOcean = @"/dituData/esriWorkMap/Ocean";
    NSString *targetWorldOceanBoundary = @"/dituData/esriWorkMap/OceanBoundary";
    //NSString *targetPath = @"/dituData/esriWorkMap/Countries";
    
    if([fileName isEqualToString:@"shengjie"]){
        return  [resourceP stringByAppendingString:targetPathChina];
    }else if([fileName isEqualToString:@"shenghui"]){
        return  [resourceP stringByAppendingString:targetCaptitalPath];
    }else if([fileName isEqualToString:@"Countries"]){
        return  [resourceP stringByAppendingString:targetWorldCountries];
    }else if([fileName isEqualToString:@"Capitals"]){
        return  [resourceP stringByAppendingString:targetWorldCapitals];
    }else if([fileName isEqualToString:@"Grids"]){
        return  [resourceP stringByAppendingString:targetWorldGrids];
    }else if([fileName isEqualToString:@"Rivers"]){
        return  [resourceP stringByAppendingString:targetWorldRivers];
    }else if([fileName isEqualToString:@"Lakes"]){
        return  [resourceP stringByAppendingString:targetWorldLakes];
    }else if([fileName isEqualToString:@"ContinentBoundary"]){
        return  [resourceP stringByAppendingString:targetWorldContinentBoundary];
    }else if([fileName isEqualToString:@"CountryBoundary"]){
        return  [resourceP stringByAppendingString:targetWorldCountryBoundary];
    }else if([fileName isEqualToString:@"Ocean"]){
        return  [resourceP stringByAppendingString:targetWorldOcean];
    }else if([fileName isEqualToString:@"OceanBoundary"]){
        return  [resourceP stringByAppendingString:targetWorldOceanBoundary];
    }
    return  @"";
}

#pragma mark- 判断字符串是否有意义
- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
