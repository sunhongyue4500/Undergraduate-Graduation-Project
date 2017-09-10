//
//  SearchHelper.m
//  shpRead_ipad_02
//
//  Created by shy on 15/5/23.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "SearchHelper.h"

@implementation SearchHelper

+(NSString *)convert:(NSString *)str{
    if([str isEqual:@"中国"]){
        return @"中华人民共和国";
    }
    return str;
}

@end
