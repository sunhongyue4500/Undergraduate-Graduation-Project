//
//  ShapePolyline.h
//  shpRead_ipad_02
//
//  Created by shy on 15/4/12.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Shapefile.h"

@interface ShapePolyline : Shapefile
{

@private
	
	long numParts;
	long numPoints;
	
@public
	
    //长度为 NumPoints 的数组,按顺序存储构成 PolyLine 的所有 Part 的点。组成序号为 2 的 Part 的点紧接着序号为 1 的,依此类推。数组 Parts 中存储着每个 Part 起点的数组索引。在 points 数组中,各Part之间没有分隔符。
	NSMutableArray* m_Points;
	//长度为Numparts的数组，存储每个环的首点在m_Points中的索引，数组索引从0开始
    NSMutableArray* m_Parts;
	double m_nBoundingBox[4];
	double m_nEast;
	double m_nNorth;

}


@property (readwrite) long numParts;
@property (readwrite) long numPoints;

@end
