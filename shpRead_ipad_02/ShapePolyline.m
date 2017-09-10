//
//  ShapePolyline.m
//  shpRead_ipad_02
//
//  Created by shy on 15/4/12.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "ShapePolyline.h"

@implementation ShapePolyline


@synthesize numParts;
@synthesize numPoints;


-(id)init{
    if(self = [super init]){
        m_Parts = [[NSMutableArray alloc] init];
        m_Points = [[NSMutableArray alloc] init];
    }
    return self;
}


@end
