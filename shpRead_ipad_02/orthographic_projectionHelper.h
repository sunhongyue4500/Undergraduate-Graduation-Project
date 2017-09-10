//
//  orthographic_projectionHelper.h
//  shpRead_ipad_02
//
//  Created by shy on 15/5/13.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface orthographic_projectionHelper : NSObject

//得到投影中心，返回（纬度，经度）数组
+(NSArray *)getProjectionCenter:(NSString *)centerName;

@end
