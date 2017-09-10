//
//  orthographic_projectionHelper.m
//  shpRead_ipad_02
//
//  Created by shy on 15/5/13.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "orthographic_projectionHelper.h"

@implementation orthographic_projectionHelper

+(NSArray *)getProjectionCenter:(NSString *)centerName{
    //default beijign
    NSArray *center  = @[@"39.908535",@"116.397481"];

    if ([centerName isEqualToString:@"西安"]){
        center = @[@"34.271577",@"108.946669"];
    }else if([centerName isEqualToString:@"努克"]){
        center = @[@"64.11",@"-51.43"];
    }else if([centerName isEqualToString:@"伦敦"]){
        center = @[@"51.30",@"0.5"];
    }else if([centerName isEqualToString:@"纽约"]){
        center = @[@"40.43",@"-74"];
    }else if ([centerName isEqualToString:@"开罗"]) {
        center = @[@"30.06",@"31.25"];
    }else if ([centerName isEqualToString:@"堪培拉"]){
        center = @[@"-35.17",@"149.07"];
    }else if ([centerName isEqualToString:@"巴西利亚"]){
        center = @[@"-16.05",@"-48.10"];
    }else if ([centerName isEqualToString:@"夏威夷"]){
        center = @[@"19.46",@"-155.33"];
    }else if ([centerName isEqualToString:@"南极洲"]){
        center = @[@"-85",@"10"];
    }
    return center;
}

@end
